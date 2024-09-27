use flutter_rust_bridge::frb;
use music_api::CLIENT;
use reqwest::header::{HeaderValue, USER_AGENT};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use tokio::{self, io::AsyncWriteExt as _};

use crate::api::{
    cache::file_cache::cache_file_from_uri, APP_RHYME_FOLDER, EXTERNAL_API_FILE,
    EXTERNAL_API_FOLDER,
};

#[derive(Serialize, Deserialize, Clone)]
#[frb]
pub struct ExternalApiConfig {
    pub file_path: String,
    #[serde(default)]
    pub url: Option<String>,
    #[serde(default)]
    pub last_hash: Option<String>,
}

impl ExternalApiConfig {
    pub async fn from_url(
        url: &str,
        document_folder: &str,
        custom_cache_root: Option<String>,
    ) -> Result<Self, anyhow::Error> {
        let extern_api_cache_path = cache_file_from_uri(
            document_folder,
            url,
            EXTERNAL_API_FOLDER,
            Some(EXTERNAL_API_FILE.to_string()),
            custom_cache_root,
        )
        .await?;

        let last_hash = Some(Self::calculate_hash(
            &tokio::fs::read(&extern_api_cache_path).await?,
        ));

        Ok(ExternalApiConfig {
            url: Some(url.to_string()),
            file_path: extern_api_cache_path,
            last_hash,
        })
    }

    pub async fn from_path(
        path: &str,
        document_folder: &str,
        custom_cache_root: Option<String>,
    ) -> Result<Self, anyhow::Error> {
        let path = cache_file_from_uri(
            document_folder,
            path,
            EXTERNAL_API_FOLDER,
            Some(EXTERNAL_API_FILE.to_string()),
            custom_cache_root,
        )
        .await?;
        Ok(ExternalApiConfig {
            url: None,
            file_path: path.to_string(),
            last_hash: None,
        })
    }

    pub async fn fetch_update(&self) -> Result<Option<ExternalApiConfig>, anyhow::Error> {
        if let Some(url) = &self.url {
            let response = CLIENT
                .get(url)
                .header(USER_AGENT, HeaderValue::from_static(&APP_RHYME_FOLDER))
                .send()
                .await?;

            let content = response.bytes().await?;
            let new_hash = Self::calculate_hash(&content);

            if self.last_hash.as_ref() != Some(&new_hash) {
                let mut file = tokio::fs::File::create(&self.file_path).await?;
                file.write_all(&content).await?;
                let mut self_clone = self.clone();
                self_clone.last_hash = Some(new_hash);
                Ok(Some(self_clone))
            } else {
                Ok(None)
            }
        } else {
            Ok(None)
        }
    }

    fn calculate_hash(content: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(content);
        format!("{:x}", hasher.finalize())
    }
}

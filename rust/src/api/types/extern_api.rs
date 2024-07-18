use crate::api::ROOT_PATH;
use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use music_api::util::CLIENT;
use reqwest::header::{HeaderValue, USER_AGENT};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use tokio::{self, io::AsyncWriteExt as _};

#[derive(Serialize, Deserialize, Clone)]
#[frb(non_opaque)]
pub struct ExternApi {
    pub url: Option<String>,
    pub local_path: String,
    #[serde(default)]
    pub last_hash: Option<String>,
    // deprecated:
    #[serde(skip_serializing, default)]
    pub last_modified_time: Option<DateTime<Utc>>,
}

impl ExternApi {
    pub async fn from_url(url: &str) -> Result<Self, anyhow::Error> {
        let response = CLIENT.get(url).send().await?;

        let cache_path_lock = ROOT_PATH.read().await;
        let extern_api_cache_path = cache_path_lock.clone().join("extern_api_cache");
        let content = response.bytes().await?;
        let mut file = tokio::fs::File::create(&extern_api_cache_path).await?;
        file.write_all(&content).await?;

        let last_hash = Some(Self::calculate_hash(&content));

        Ok(ExternApi {
            url: Some(url.to_string()),
            local_path: extern_api_cache_path.to_string_lossy().to_string(),
            last_modified_time: None,
            last_hash,
        })
    }

    pub async fn from_path(path: &str) -> Result<Self, anyhow::Error> {
        Ok(ExternApi {
            url: None,
            local_path: path.to_string(),
            last_modified_time: None,
            last_hash: None,
        })
    }

    pub async fn fetch_update(self) -> Result<Option<ExternApi>, anyhow::Error> {
        let mut extern_api = self;
        if let Some(url) = &extern_api.url {
            let response = CLIENT
                .get(url)
                .header(USER_AGENT, HeaderValue::from_static("AppRhyme"))
                .send()
                .await?;

            let content = response.bytes().await?;
            let new_hash = Self::calculate_hash(&content);

            if extern_api.last_hash.as_ref() != Some(&new_hash) {
                let cache_path_lock = ROOT_PATH.read().await;
                let extern_api_cache_path = cache_path_lock.clone().join("extern_api_cache");
                let mut file = tokio::fs::File::create(&extern_api_cache_path).await?;
                file.write_all(&content).await?;
                extern_api.last_hash = Some(new_hash);
            } else {
                return Ok(None);
            }
        }
        Ok(Some(extern_api))
    }

    fn calculate_hash(content: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(content);
        format!("{:x}", hasher.finalize())
    }
}

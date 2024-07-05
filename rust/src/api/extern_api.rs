use chrono::{DateTime, Utc};
use flutter_rust_bridge::frb;
use music_api::util::CLIENT;
use reqwest::header::{HeaderMap, HeaderValue, LAST_MODIFIED, USER_AGENT};
use serde::{Deserialize, Serialize};
use tokio::{self, io::AsyncWriteExt as _};

use super::ROOT_PATH;
#[derive(Serialize, Deserialize, Debug)]
#[frb(non_opaque)]
pub struct ExternApi {
    pub url: Option<String>,
    pub local_path: String,
    pub last_modified_time: Option<DateTime<Utc>>,
}

impl ExternApi {
    pub async fn from_url(url: &str) -> Result<Self, anyhow::Error> {
        let response = CLIENT.get(url).send().await?;
        let headers: &HeaderMap = response.headers();

        let last_modified_time = headers
            .get(LAST_MODIFIED)
            .and_then(|last_modified| last_modified.to_str().ok())
            .and_then(|last_modified_str| DateTime::parse_from_rfc2822(last_modified_str).ok())
            .map(|datetime| datetime.with_timezone(&Utc));
        let cache_path_lock = ROOT_PATH.read().await;
        let extern_api_cache_path = cache_path_lock.clone().join("extern_api_cache.evc");
        // 使用tokio::fs把文件异步保存到这里
        let content = response.bytes().await?;
        let mut file = tokio::fs::File::create(&extern_api_cache_path).await?;
        file.write_all(&content).await?;

        Ok(ExternApi {
            url: Some(url.to_string()),
            local_path: extern_api_cache_path.to_string_lossy().to_string(),
            last_modified_time,
        })
    }

    pub async fn from_path(path: &str) -> Result<Self, anyhow::Error> {
        Ok(ExternApi {
            url: None,
            local_path: path.to_string(),
            last_modified_time: None,
        })
    }

    #[frb]
    pub async fn fetch_update(self) -> Result<Option<ExternApi>, anyhow::Error> {
        let mut extern_api = self;
        if let Some(url) = &extern_api.url {
            let response = CLIENT
                .get(url)
                .header(USER_AGENT, HeaderValue::from_static("AppRhyme"))
                .send()
                .await?;
            let headers: &HeaderMap = response.headers();

            let last_modified_time = headers
                .get("last-modified")
                .and_then(|last_modified| last_modified.to_str().ok())
                .and_then(|last_modified_str| DateTime::parse_from_rfc2822(last_modified_str).ok())
                .map(|datetime| datetime.with_timezone(&Utc));

            // 如果服务器的文件更新时间比本地的新，就更新本地文件
            if last_modified_time > extern_api.last_modified_time {
                let cache_path_lock = ROOT_PATH.read().await;
                let extern_api_cache_path = cache_path_lock.clone().join("extern_api_cache");
                // 使用tokio::fs把文件异步保存到这里
                let content = response.text().await?;
                let mut file = tokio::fs::File::create(&extern_api_cache_path).await?;
                file.write_all(content.as_bytes()).await?;
                extern_api.last_modified_time = last_modified_time;
            } else {
                return Ok(None);
            }
        }
        Ok(Some(extern_api))
    }
}

use serde::{Deserialize, Serialize};
use tokio::fs;

use super::ROOT_PATH;

#[flutter_rust_bridge::frb]
#[derive(Serialize, Deserialize)]
pub struct Config {
    #[serde(default = "default_user_agreement")]
    pub user_agreement: bool,
    #[serde(default)]
    pub extern_api_path: Option<String>,
}

fn default_user_agreement() -> bool {
    false
}

impl Default for Config {
    fn default() -> Self {
        Config {
            extern_api_path: None,
            user_agreement: false,
        }
    }
}

impl Config {
    pub async fn save(&self) -> Result<(), anyhow::Error> {
        let root_path = ROOT_PATH.read().await;
        let path = root_path.clone().join("config.json");
        fs::write(path, serde_json::to_string(&self)?).await?;
        Ok(())
    }
    pub async fn load() -> Result<Self, anyhow::Error> {
        let root_path = ROOT_PATH.read().await;
        let path = root_path.clone().join("config.json");
        if !path.exists() {
            let config = Config::default();
            config.save().await?;
            Ok(config)
        } else {
            Ok(serde_json::from_str::<Self>(
                &fs::read_to_string(path).await?,
            )?)
        }
    }
}

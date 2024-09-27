use std::{path::PathBuf, str::FromStr};

use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use tokio::fs;

use crate::api::{APP_RHYME_FOLDER, CONFIG_FILE};

use super::external_api::ExternalApiConfig;

#[derive(Serialize, Deserialize, Clone, Default)]
#[frb(non_opaque)]
pub struct Config {
    /// 用户是否同意使用协议
    #[frb(non_final)]
    #[serde(default = "default_false")]
    pub user_agreement: bool,
    /// 音质相关设置
    #[frb(non_final)]
    #[serde(default)]
    pub quality_config: QualityConfig,
    /// 音源设置
    #[frb(non_final)]
    #[serde(default)]
    pub external_api: Option<ExternalApiConfig>,
    /// 更新设置
    #[frb(non_final)]
    #[serde(default)]
    pub update_config: UpdateConfig,
    /// 储存设置
    #[frb(non_final)]
    #[serde(default)]
    pub storage_config: StorageConfig,
    /// 窗口设置(桌面系统only)
    #[frb(non_final)]
    #[serde(default)]
    pub window_config: Option<WindowConfig>,
}

#[derive(Serialize, Deserialize, Clone)]
#[frb]
pub enum QualityOption {
    Highest,
    High,
    Medium,
    Low,
}

impl QualityOption {
    #[frb(sync)]
    fn to_string(&self) -> String {
        match self {
            QualityOption::Highest => "最高".to_string(),
            QualityOption::High => "高".to_string(),
            QualityOption::Medium => "中".to_string(),
            QualityOption::Low => "低".to_string(),
        }
    }
    #[frb(sync)]
    fn from_string(quality: &str) -> Self {
        match quality {
            "最高" => QualityOption::Highest,
            "高" => QualityOption::High,
            "中" => QualityOption::Medium,
            "低" => QualityOption::Low,
            _ => QualityOption::Medium,
        }
    }
}

#[derive(Serialize, Deserialize, Clone)]
#[frb(non_opaque)]
pub struct QualityConfig {
    // wifi下自动选择的音质
    #[frb(non_final)]
    #[serde(default = "wifi_auto_quality")]
    pub wifi_auto_quality: QualityOption,
    // 移动网络下自动选择的音质
    #[frb(non_final)]
    #[serde(default = "mobile_auto_quality")]
    pub mobile_auto_quality: QualityOption,
}

impl Default for QualityConfig {
    fn default() -> Self {
        Self {
            wifi_auto_quality: wifi_auto_quality(),
            mobile_auto_quality: mobile_auto_quality(),
        }
    }
}

#[derive(Serialize, Deserialize, Clone)]
#[frb(non_opaque)]
pub struct UpdateConfig {
    // 是否自动检查版本更新
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub version_auto_update: bool,
    // 是否自动检查自定义音源更新
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub external_api_auto_update: bool,
}

impl Default for UpdateConfig {
    fn default() -> Self {
        Self {
            version_auto_update: true,
            external_api_auto_update: true,
        }
    }
}

#[derive(Serialize, Deserialize, Clone)]
#[frb(non_opaque)]
pub struct StorageConfig {
    // 添加歌单时是否保存封面
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub save_pic: bool,
    // 自定义的歌曲/图片数据缓存路径
    #[frb(non_final)]
    #[serde(default)]
    pub custom_cache_root: Option<String>,
    // 自定义的歌单数据库路径
    #[frb(non_final)]
    #[serde(default)]
    pub custom_db: Option<String>,
}

impl Default for StorageConfig {
    fn default() -> Self {
        Self {
            save_pic: true,
            custom_cache_root: None,
            custom_db: None,
        }
    }
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[frb(non_opaque)]
pub struct WindowConfig {
    /// 启动时窗口的宽度
    #[frb(non_final)]
    pub width: i32,
    /// 启动时窗口的高度
    #[frb(non_final)]
    pub height: i32,
    /// 窗口的最小宽度
    #[frb(non_final)]
    pub min_width: i32,
    /// 窗口的最小高度
    #[frb(non_final)]
    pub min_height: i32,
    /// 窗口的最大宽度
    #[frb(non_final)]
    pub fullscreen: bool,
}

#[frb(sync)]
impl Default for WindowConfig {
    fn default() -> Self {
        Self {
            width: 1280,
            height: 860,
            min_width: 1100,
            min_height: 600,
            fullscreen: false,
        }
    }
}

fn wifi_auto_quality() -> QualityOption {
    QualityOption::Highest
}
fn mobile_auto_quality() -> QualityOption {
    QualityOption::Medium
}
fn default_true() -> bool {
    true
}

fn default_false() -> bool {
    false
}

impl Config {
    pub async fn update(self) -> Result<Self, anyhow::Error> {
        Ok(self)
    }

    pub async fn save(&self, document_folder: &str) -> Result<(), anyhow::Error> {
        let storage_folder = match &self.storage_config.custom_cache_root {
            Some(custom_cache_root) => PathBuf::from_str(custom_cache_root)?,
            None => PathBuf::from_str(document_folder)?,
        }
        .join(APP_RHYME_FOLDER);

        if !storage_folder.exists() {
            fs::create_dir_all(&storage_folder).await?;
        }

        fs::write(
            storage_folder.join(CONFIG_FILE),
            serde_json::to_string(&self)?,
        )
        .await?;

        Ok(())
    }

    pub async fn load(document_folder: &str) -> Result<Self, anyhow::Error> {
        let config_file_path = PathBuf::from_str(document_folder)?
            .join(APP_RHYME_FOLDER)
            .join(CONFIG_FILE);

        // if the config file does not exist, create a new one and save it
        let mut self_ = if !config_file_path.exists() {
            let config = Config::default();
            config.save(document_folder).await?;
            config
        } else {
            serde_json::from_str::<Self>(&fs::read_to_string(config_file_path).await?)?
        };

        self_ = self_.update().await?;

        Ok(self_)
    }

    #[frb(sync)]
    pub fn get_storage_folder(&self, document_folder: &str) -> Result<String, anyhow::Error> {
        Ok(match &self.storage_config.custom_cache_root {
            Some(custom_cache_root) => PathBuf::from_str(custom_cache_root)?,
            None => PathBuf::from_str(document_folder)?,
        }
        .join(APP_RHYME_FOLDER)
        .to_string_lossy()
        .to_string())
    }

    #[frb(sync)]
    pub fn get_sql_url(&self, document_folder: &str) -> Result<String, anyhow::Error> {
        Ok(match &self.storage_config.custom_db {
            Some(custom_db) => custom_db.clone(),
            None => format!(
                "sqlite:///{}",
                PathBuf::from_str(document_folder)?
                    .join(APP_RHYME_FOLDER)
                    .join("rhyme.db")
                    .to_string_lossy()
                    .to_string(),
            ),
        })
    }
}

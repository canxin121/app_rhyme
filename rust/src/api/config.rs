use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use tokio::fs;

use super::{extern_api::ExternApi, CONFIG, ROOT_PATH};

#[derive(Serialize, Deserialize, Clone)]
#[frb(non_opaque)]
pub struct Config {
    // 用户是否同意使用协议
    #[frb(non_final)]
    #[serde(default = "default_false")]
    pub user_agreement: bool,
    // 自定义音源
    #[frb(non_final)]
    pub extern_api: Option<ExternApi>,
    // 是否自动检查版本更新
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub version_auto_update: bool,
    // 是否自动检查自定义音源更新
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub extern_api_auto_update: bool,
    // wifi下自动选择的音质
    #[frb(non_final)]
    #[serde(default = "wifi_auto_quality")]
    pub wifi_auto_quality: String,
    // 移动网络下自动选择的音质
    #[frb(non_final)]
    #[serde(default = "mobile_auto_quality")]
    pub mobile_auto_quality: String,
    // 添加歌单时是否保存封面
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub save_pic_when_add_music_list: bool,
    // 添加歌单时是否保存歌词
    #[frb(non_final)]
    #[serde(default = "default_true")]
    pub save_lyric_when_add_music_list: bool,
    // 自定义的应用数据缓存路径
    #[frb(non_final)]
    #[serde(default)]
    pub export_cache_root: Option<String>,
    // 上一次的应用数据缓存路径
    #[frb(non_final)]
    #[serde(default)]
    pub last_export_cache_root: Option<String>,
    // deprecated fields
    // 使用skip_serializing来避免序列化, 但是仍然可以反序列化
    // 从而实现在save时废弃这个字段，而在load时又可以兼容
    #[serde(default, skip_serializing)]
    pub extern_api_path: Option<String>,
}
fn wifi_auto_quality() -> String {
    "最高".to_string()
}
fn mobile_auto_quality() -> String {
    "中等".to_string()
}
fn default_true() -> bool {
    true
}

fn default_false() -> bool {
    false
}

impl Config {
    #[frb(ignore)]
    pub fn default(app_cache_root: &str) -> Self {
        let config = Config {
            extern_api_path: None,
            user_agreement: false,
            extern_api: None,
            version_auto_update: true,
            extern_api_auto_update: true,
            wifi_auto_quality: wifi_auto_quality(),
            mobile_auto_quality: mobile_auto_quality(),
            save_pic_when_add_music_list: true,
            save_lyric_when_add_music_list: true,
            export_cache_root: None,
            last_export_cache_root: Some(app_cache_root.to_string()),
        };
        config
    }
    // 解决deprecated
    pub async fn update(mut self) -> Result<Self, anyhow::Error> {
        // 1. handle deprecated field `extern_api_path`
        // 将extern_api_path转换为extern_api，而extern_api_path将通过save被废弃
        if let Some(extern_api_path) = self.extern_api_path.clone() {
            self.extern_api = Some(ExternApi::from_path(&extern_api_path).await?);
        }
        self.save().await?;
        Ok(self)
    }

    pub async fn save(&self) -> Result<(), anyhow::Error> {
        // 同步到全局变量
        {
            let mut global_config = CONFIG.write().await;
            *global_config = Some(self.clone());
        }

        let root_path = ROOT_PATH.read().await;
        let path = root_path.clone().join("config.json");
        fs::write(path, serde_json::to_string(&self)?).await?;
        Ok(())
    }

    pub async fn load() -> Result<Self, anyhow::Error> {
        let root_path = ROOT_PATH.read().await;
        let path = root_path.clone().join("config.json");
        let mut self_ = if !path.exists() {
            let config = Config::default(root_path.to_str().unwrap());
            config.save().await?;
            config
        } else {
            serde_json::from_str::<Self>(&fs::read_to_string(path).await?)?
        };

        // 加载之后更新一次，以便于处理deprecated
        self_ = self_.update().await?;

        // 同步到全局变量
        {
            let mut global_config = CONFIG.write().await;
            *global_config = Some(self_.clone());
        }
        Ok(self_)
    }
}

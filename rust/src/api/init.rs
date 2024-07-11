use std::path::PathBuf;

use music_api::SqlFactory;
use tokio::fs::create_dir_all;

use crate::api::{CONFIG, ROOT_PATH};

use super::{cache::del_old_data, config::Config};

#[flutter_rust_bridge::frb(init)]
pub async fn init() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn init_backend(store_root: String) -> Result<Config, anyhow::Error> {
    // 构造储存根目录
    let mut store_root = PathBuf::from(store_root.to_string());
    store_root.push("AppRhyme");
    if !store_root.exists() {
        create_dir_all(store_root.clone()).await?;
    }

    // 初始化全局的储存根目录
    {
        let mut root_path = ROOT_PATH.write().await;
        *root_path = store_root.clone();
    }
    let config = Config::load().await?;
    // 初始化全局的配置
    {
        let mut global_config = CONFIG.write().await;
        *global_config = Some(config.clone());
    }
    // 构造数据库路径, 优先使用export_cache_root
    let db_path = match config.export_cache_root.as_ref() {
        Some(export_root) => {
            let mut export_root = PathBuf::from(export_root);
            export_root.push("MusicData.db");
            // 检测export_root是否存在，不存在的话就和None一样返回
            if export_root.exists() {
                export_root
            } else {
                store_root.push("MusicData.db");
                store_root
            }
        }
        None => {
            store_root.push("MusicData.db");
            store_root
        }
    };

    if config.export_cache_root.is_some() {
        del_old_data().await?;
    }

    let db_path_str = db_path.to_str().unwrap().to_string();
    SqlFactory::init_from_path(&db_path_str).await.unwrap();

    Ok(config)
}

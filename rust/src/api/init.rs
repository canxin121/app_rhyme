use std::path::PathBuf;

use music_api::SqlFactory;
use tokio::{
    fs::{create_dir_all, File},
    io::AsyncWriteExt as _,
};

use crate::api::ROOT_PATH;

use super::config::Config;

#[flutter_rust_bridge::frb(init)]
pub async fn init() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn init_backend(store_root: String) -> Result<Config, anyhow::Error> {
    flutter_rust_bridge::setup_default_user_utils();
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

    // 构造数据库路径
    let mut db_path = store_root.clone();
    db_path.push("MusicData.db");
    let db_path_str = db_path.to_str().unwrap().to_string();
    if !db_path.exists() {
        File::create(db_path)
            .await
            .unwrap()
            .shutdown()
            .await
            .unwrap();
    };

    SqlFactory::init_from_path(&db_path_str).await.unwrap();

    Config::load().await
}

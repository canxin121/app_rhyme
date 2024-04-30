use std::path::PathBuf;

use music_api::{install_default_drivers, MusicList};
use sqlx::{Any, AnyPool, Pool};
use tokio::{fs::{create_dir_all, File}, io::AsyncWriteExt as _};

use super::{config::Config, music_sdk::SqlMusicFactoryW, ROOT_PATH};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
#[flutter_rust_bridge::frb]
pub async fn init_store(store_root: &str) -> Result<(SqlMusicFactoryW, Config), anyhow::Error> {
    // 初始化全局的储存根目录
    let mut store_root = PathBuf::from(store_root.to_string());
    store_root.push("AppRhyme");
    if(!store_root.exists()){
        create_dir_all(store_root.clone()).await?;
    }

    println!("cache root : {:?}", store_root);
    {
        let mut root_path = ROOT_PATH.write().await;
        *root_path = store_root.clone();
    }

    // 初始化sql储存
    install_default_drivers();
    let mut path = store_root.clone();
    path.push("MusicData.db");
    let path_str = path.to_str().unwrap().to_string();
    let should_create = !path.exists();
    if should_create {
        File::create(path).await.unwrap().shutdown().await.unwrap();
    };

    let database_url = format!("sqlite:{}", path_str);
    let pool: Pool<Any> = AnyPool::connect(&database_url)
        .await
        .expect("Failed to connect to the database");
    let factory = SqlMusicFactoryW::build(pool);
    if should_create {
        factory.init_create_table().await?;
        factory.create_music_list_table(&vec![MusicList{name:"我的喜欢".to_string(),art_pic:"".to_string(),desc:"音乐".to_string()}]).await?
    }

    // let url_store = UrlStore::load().await?;
    let config = Config::load().await?;
    Ok((factory, config))
}

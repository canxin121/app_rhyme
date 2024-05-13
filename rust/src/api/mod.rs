use std::path::PathBuf;

use tokio::sync::RwLock;

pub mod cache;
pub mod init;
pub mod mirror;
pub mod music_sdk;
pub mod config;
pub mod http_helper;

lazy_static::lazy_static! {
    pub static ref ROOT_PATH:RwLock<PathBuf> = RwLock::new(PathBuf::new());
}

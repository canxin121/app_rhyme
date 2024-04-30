use std::path::PathBuf;

use tokio::sync::RwLock;

pub mod cache;
pub mod init;
pub mod mirror;
pub mod music_sdk;
pub mod config;

lazy_static::lazy_static! {
    pub static ref ROOT_PATH:RwLock<PathBuf> = RwLock::new(PathBuf::new());
}

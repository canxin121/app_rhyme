use std::path::PathBuf;

use tokio::sync::RwLock;
use types::config::Config;

pub mod cache;
pub mod init;
pub mod music_api;
pub mod types;
pub mod utils;
pub mod plugin;

lazy_static::lazy_static! {
    pub static ref ROOT_PATH:RwLock<PathBuf> = RwLock::new(PathBuf::new());
    pub static ref CONFIG: RwLock<Option<Config>> = RwLock::new(None);
}


use std::path::PathBuf;

use flutter_rust_bridge::frb;

use super::CONFIG;
#[frb(ignore)]
pub(crate) async fn get_root_path() -> Result<PathBuf, anyhow::Error> {
    let global_config = CONFIG.read().await;
    let mut result = None;
    if let Some(config) = global_config.as_ref() {
        if let Some(export_cache_root) = config.export_cache_root.as_ref() {
            result = Some(PathBuf::from(export_cache_root));
        }
    }
    if result.is_none() {
        let root_path = super::ROOT_PATH.read().await;
        result = Some(root_path.clone());
    }
    result.ok_or(anyhow::anyhow!("Failed to get root path"))
}

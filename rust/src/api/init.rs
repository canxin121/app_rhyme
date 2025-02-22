use super::{music_api::fns::set_db, types::config::Config, APP_RHYME_FOLDER, DB_FILE};
use std::{path::PathBuf, str::FromStr};

#[flutter_rust_bridge::frb(init)]
pub async fn init() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn init_backend(document_folder: String) -> Result<Config, anyhow::Error> {
    let config = Config::load(&document_folder).await?;
    let db_url = config.storage_config.custom_db.clone().unwrap_or(format!(
        "sqlite://{}",
        PathBuf::from_str(&document_folder)?
            .join(APP_RHYME_FOLDER)
            .join(DB_FILE)
            .to_string_lossy()
            .to_string()
    ));

    set_db(&db_url).await?;
    Ok(config)
}

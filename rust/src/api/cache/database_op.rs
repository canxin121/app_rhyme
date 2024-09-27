use std::{path::PathBuf, str::FromStr};

use flutter_rust_bridge::frb;
use music_api::data::interface::json::DatabaseJson;

use crate::api::{music_api::fns::set_db, APP_RHYME_FOLDER, DATABASE_JSON_CACHE};

#[frb]
pub async fn move_database(
    document_folder: String,
    custom_root: Option<String>,
    new_db_url: String,
) -> Result<(), anyhow::Error> {
    let database_json = DatabaseJson::get_from_db().await?;
    database_json
        .save_to(
            &PathBuf::from_str(&custom_root.unwrap_or(document_folder))?
                .join(APP_RHYME_FOLDER)
                .join(DATABASE_JSON_CACHE)
                .to_string_lossy()
                .to_string(),
        )
        .await?;
    set_db(&new_db_url).await?;
    database_json.apply_to_db().await?;
    Ok(())
}

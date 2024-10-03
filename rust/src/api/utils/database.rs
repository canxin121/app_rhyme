use std::{path::PathBuf, str::FromStr};

use flutter_rust_bridge::frb;

#[frb]
pub async fn verify_sqlite_url(sqlite_url: String) -> Result<(), anyhow::Error> {
    if sqlite_url == "sqlite::memory:" {
        return Ok(());
    }
    let db_file: PathBuf = PathBuf::from_str(&sqlite_url.split("//").last().ok_or(
        anyhow::anyhow!("Invalid database url, use 'sqlite://path/to/database.db'"),
    )?)?;
    if !db_file.exists() {
        return Err(anyhow::anyhow!("Database file does not exist"));
    }
    Ok(())
}

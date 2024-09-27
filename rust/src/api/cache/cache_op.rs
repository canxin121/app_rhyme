use std::{path::PathBuf, str::FromStr as _};

use flutter_rust_bridge::frb;

use crate::api::{APP_RHYME_FOLDER, DB_FILE, MUSIC_FOLDER, PIC_FOLDER};

use super::fs_util::{copy_directory, copy_file};

pub async fn move_cache_data(
    document_path: &str,
    old_custom_cache_root: Option<String>,
    new_custom_cache_root: Option<String>,
) -> Result<(), anyhow::Error> {
    copy_data(
        document_path,
        old_custom_cache_root.clone(),
        new_custom_cache_root,
    )
    .await?;
    del_old_cache_data(document_path, old_custom_cache_root).await?;
    Ok(())
}

pub(crate) async fn copy_data(
    document_path: &str,
    old_custom_cache_root: Option<String>,
    new_custom_cache_root: Option<String>,
) -> Result<(), anyhow::Error> {
    let old_storage_folder = match old_custom_cache_root.as_ref() {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_path)?,
    }
    .join(APP_RHYME_FOLDER);

    let new_storage_folder = match new_custom_cache_root.as_ref() {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_path)?,
    }
    .join(APP_RHYME_FOLDER);

    let old_pic_path = old_storage_folder.clone().join(PIC_FOLDER);
    let old_music_path = old_storage_folder.clone().join(MUSIC_FOLDER);
    let old_db_path = old_storage_folder.clone().join(DB_FILE);

    let new_pic_path = new_storage_folder.clone().join(PIC_FOLDER);
    let new_music_path = new_storage_folder.clone().join(MUSIC_FOLDER);
    let new_db_path = new_storage_folder.clone().join(DB_FILE);

    if old_pic_path.exists() {
        copy_directory(&old_pic_path, &new_pic_path).await?;
    }

    if old_music_path.exists() {
        copy_directory(&old_music_path, &new_music_path).await?;
    }

    if old_db_path.exists() {
        copy_file(&old_db_path, &new_db_path).await?;
    }

    Ok(())
}

#[frb]
pub async fn del_old_cache_data(
    document_path: &str,
    old_custom_cache_root: Option<String>,
) -> Result<(), anyhow::Error> {
    let storage_folder = match old_custom_cache_root.as_ref() {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_path)?,
    }
    .join(APP_RHYME_FOLDER);

    let pic_path = storage_folder.clone().join(PIC_FOLDER);
    let music_path = storage_folder.clone().join(MUSIC_FOLDER);
    let db_path = storage_folder.clone().join(DB_FILE);

    if pic_path.exists() {
        tokio::fs::remove_dir_all(pic_path).await?;
    }

    if music_path.exists() {
        tokio::fs::remove_dir_all(music_path).await?;
    }

    if db_path.exists() {
        tokio::fs::remove_file(db_path).await?;
    }
    Ok(())
}

use super::file_cache::{cache_file_from_content, cache_file_from_uri};
use crate::api::{
    types::playinfo::PlayInfo, utils::path_util::url_encode_special_chars, APP_RHYME_FOLDER,
    MUSIC_FOLDER, PLAYINFO_FOLDER,
};
use flutter_rust_bridge::frb;
use std::{path::PathBuf, str::FromStr};

fn format_music_file_name(name: &str, artists: &str, playinfo: &PlayInfo) -> String {
    url_encode_special_chars(&format!(
        "{}_{}.{}",
        name,
        artists,
        playinfo
            .quality
            .format
            .clone()
            .unwrap_or("unknown".to_string())
    ))
}

async fn format_music_meta_file_path(
    document_folder: &str,
    custom_cache_root: Option<String>,
    name: &str,
    artists: &str,
) -> Result<PathBuf, anyhow::Error> {
    Ok(match custom_cache_root {
        Some(custom_cache_root) => PathBuf::from_str(&custom_cache_root)?,
        None => PathBuf::from_str(document_folder)?,
    }
    .join(APP_RHYME_FOLDER)
    .join(MUSIC_FOLDER)
    .join(PLAYINFO_FOLDER)
    .join(url_encode_special_chars(&format!(
        "{}_{}.json",
        name, artists
    ))))
}

#[frb]
pub async fn has_cache_music(
    document_folder: &str,
    custom_cache_root: Option<String>,
    name: String,
    artists: String,
) -> bool {
    format_music_meta_file_path(document_folder, custom_cache_root, &name, &artists)
        .await
        .ok()
        .map(|path| path.exists())
        .unwrap_or(false)
}

/// get cached music playinfo and lyric
#[frb]
pub async fn get_cache_music(
    document_folder: &str,
    custom_cache_root: Option<String>,
    name: String,
    artists: String,
) -> Option<(PlayInfo, String)> {
    let playinfo = {
        let path = format_music_meta_file_path(document_folder, custom_cache_root, &name, &artists)
            .await
            .ok()?;

        if path.exists() {
            let content_str = tokio::fs::read_to_string(path).await.ok()?;
            let playinfo: PlayInfo = serde_json::from_str(&content_str).ok()?;
            Some(playinfo)
        } else {
            None
        }
    }?;
    let lyric_path = PathBuf::from(&playinfo.uri);
    let lyric_path = lyric_path.with_extension("lrc");
    let lyric = tokio::fs::read_to_string(lyric_path).await.ok()?;
    Some((playinfo, lyric))
}

pub async fn cache_music(
    document_folder: &str,
    custom_cache_root: Option<String>,
    name: String,
    artists: String,
    playinfo: &PlayInfo,
    lyric: Option<String>,
) -> Result<(), anyhow::Error> {
    let mut playinfo = playinfo.clone();

    // cache music file
    let cached_music_path = cache_file_from_uri(
        document_folder,
        &playinfo.uri,
        MUSIC_FOLDER,
        Some(url_encode_special_chars(&format_music_file_name(
            &name, &artists, &playinfo,
        ))),
        custom_cache_root.clone(),
    )
    .await?;

    playinfo.uri = cached_music_path;

    // cache lyric file
    if let Some(lyric) = lyric {
        let lyric_filename = PathBuf::from(&playinfo.uri).with_extension("lrc");
        cache_file_from_content(
            document_folder,
            lyric,
            MUSIC_FOLDER,
            lyric_filename.to_string_lossy().to_string(),
            custom_cache_root.clone(),
        )
        .await?;
    }

    // save music meta info
    let music_meta_json_path =
        format_music_meta_file_path(document_folder, custom_cache_root, &name, &artists).await?;
    if let Some(parent) = music_meta_json_path.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let playinfo_json = serde_json::to_string(&playinfo)?;
    tokio::fs::write(music_meta_json_path, playinfo_json).await?;
    Ok(())
}

pub async fn delete_music_cache(
    document_folder: &str,
    custom_cache_root: Option<String>,
    name: &str,
    artists: &str,
) -> Result<(), anyhow::Error> {
    let path =
        format_music_meta_file_path(document_folder, custom_cache_root, name, artists).await?;
    if path.exists() {
        let file_content = tokio::fs::read_to_string(&path).await?;
        let playinfo: PlayInfo = serde_json::from_str(&file_content)?;

        let music_path = PathBuf::from_str(&playinfo.uri)?;
        if music_path.exists() {
            tokio::fs::remove_file(&music_path).await?;
        }

        let mut lyric_path = music_path.clone();
        lyric_path.set_extension("lrc");
        if lyric_path.exists() {
            tokio::fs::remove_file(&lyric_path).await?;
        }

        tokio::fs::remove_file(path).await?;
    }
    Ok(())
}

use std::path::PathBuf;

use flutter_rust_bridge::frb;
use music_api::data::interface::music_aggregator::Music;

use crate::api::{
    types::playinfo::PlayInfo,
    utils::path_util::{get_root_path, url_encode_special_chars},
    CONFIG,
};
const PLAYINFO_FOLDER: &str = "PlayInfo";
const MUSIC_FOLDER: &str = "Music";

use super::file_cache::{cache_file_from_content, cache_file_from_uri};

fn format_music_file_name(music_info: &Music, playinfo: &PlayInfo) -> String {
    format!(
        "{}_{}.{}",
        music_info.name,
        music_info
            .artists
            .iter()
            .map(|a| a.name.clone())
            .collect::<Vec<String>>()
            .join(","),
        playinfo
            .quality
            .format
            .clone()
            .unwrap_or("unknown".to_string().replace("\r", ""))
    )
}

async fn format_music_meta_file_path(music_info: &Music) -> Result<PathBuf, anyhow::Error> {
    let file_name = format!(
        "{}_{}.json",
        music_info.name,
        music_info
            .artists
            .iter()
            .map(|a| a.name.clone())
            .collect::<Vec<String>>()
            .join(","),
    );

    let file_name = url_encode_special_chars(&file_name);
    let mut path = get_root_path().await?;
    path.push(MUSIC_FOLDER);
    path.push(PLAYINFO_FOLDER);
    path.push(file_name);
    Ok(path)
}

#[frb]
pub async fn has_cache_music(music: &Music) -> bool {
    format_music_meta_file_path(music)
        .await
        .ok()
        .map(|path| path.exists())
        .unwrap_or(false)
}

/// get cached music lyric and playinfo
#[frb]
pub async fn get_cache_music(music: &Music) -> Option<(PlayInfo, String)> {
    let playinfo = {
        let path = format_music_meta_file_path(music).await.ok()?;

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
    music: &Music,
    playinfo: &PlayInfo,
    lyric: Option<String>,
) -> Result<(), anyhow::Error> {
    let mut playinfo = playinfo.clone();
    let config = CONFIG.read().await;
    let config = config.as_ref().ok_or(anyhow::anyhow!("Config not found"))?;

    // cache music file
    let cached_music_path = cache_file_from_uri(
        &playinfo.uri,
        MUSIC_FOLDER,
        Some(url_encode_special_chars(&format_music_file_name(
            music, &playinfo,
        ))),
        config.export_cache_root.clone(),
    )
    .await?;

    playinfo.uri = cached_music_path;

    // cache lyric file
    if let Some(lyric) = lyric {
        let lyric_filename = PathBuf::from(&playinfo.uri).with_extension("lrc");
        cache_file_from_content(
            lyric,
            MUSIC_FOLDER,
            lyric_filename.to_string_lossy().to_string(),
            config.export_cache_root.clone(),
        )
        .await?;
    }

    // save music meta info
    let music_meta_json_path = format_music_meta_file_path(&music).await?;
    println!("save music_meta_json_path: {:?}", music_meta_json_path);
    if let Some(parent) = music_meta_json_path.parent() {
        std::fs::create_dir_all(parent)?;
    }

    let playinfo_json = serde_json::to_string(&playinfo)?;
    tokio::fs::write(music_meta_json_path, playinfo_json).await?;
    Ok(())
}

pub async fn delete_music_cache(music_info: &Music) -> Result<(), anyhow::Error> {
    let path = format_music_meta_file_path(music_info).await?;
    if path.exists() {
        let file = std::fs::File::open(&path)?;
        let reader = std::io::BufReader::new(file);
        let playinfo: PlayInfo = serde_json::from_reader(reader)?;
        let music_path = PathBuf::from(&playinfo.uri);
        let _ = tokio::fs::remove_file(&music_path).await;
        let mut lyric_path = music_path.clone();
        lyric_path.set_extension("lrc");
        let _ = tokio::fs::remove_file(lyric_path).await;
        tokio::fs::remove_file(path).await?;
    }
    Ok(())
}

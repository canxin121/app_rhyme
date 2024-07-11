use std::path::PathBuf;

use flutter_rust_bridge::frb;
use music_api::MusicInfo;

use crate::api::utils::get_root_path;

use super::{cache::cache_file, type_bind::PlayInfo, CONFIG};
#[frb(ignore)]
async fn gen_file_name(music_info: &MusicInfo) -> Result<PathBuf, anyhow::Error> {
    let file_name = format!(
        "{}_{}_{}.json",
        music_info.name,
        music_info.artist.join(","),
        music_info.duration.unwrap_or(0)
    );
    let mut path = get_root_path().await?;
    path.push("Music");
    path.push("MetaData");
    path.push(file_name);
    Ok(path)
}

#[frb(ignore)]
async fn gen_music_path(filename: &str) -> Result<PathBuf, anyhow::Error> {
    let mut path = get_root_path().await?;
    path.push("Music");
    path.push(filename);
    Ok(path)
}

pub async fn has_cache_playinfo(music_info: &MusicInfo) -> Result<bool, anyhow::Error> {
    let path = gen_file_name(music_info).await?;
    Ok(path.exists())
}

pub async fn get_cache_playinfo(music_info: &MusicInfo) -> Result<PlayInfo, anyhow::Error> {
    let path = gen_file_name(music_info).await?;
    if path.exists() {
        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let cache: PlayInfo = serde_json::from_reader(reader)?;
        Ok(cache)
    } else {
        Err(anyhow::anyhow!("File not found"))
    }
}

pub async fn cache_music(music_info: &MusicInfo, playinfo: &PlayInfo) -> Result<(), anyhow::Error> {
    let mut playinfo = playinfo.clone();
    let config = CONFIG.read().await;
    let config = config.as_ref().ok_or(anyhow::anyhow!("Config not found"))?;
    let music_filename = format!(
        "{}_{}_{}.{}",
        music_info.name,
        music_info.artist.join(","),
        music_info.duration.unwrap_or(0),
        playinfo
            .quality
            .format
            .clone()
            .unwrap_or("unknown".to_string().replace("\r", ""))
    );
    let music_path = cache_file(
        &playinfo.uri,
        "Music",
        Some(music_filename),
        config.export_cache_root.clone(),
    )
    .await?;
    playinfo.uri = music_path;

    let path = gen_file_name(&music_info).await?;
    // 如果file的父目录不存在，就创建
    if let Some(parent) = path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    let file = std::fs::File::create(&path)?;
    let writer = std::io::BufWriter::new(file);
    serde_json::to_writer(writer, &playinfo)?;
    Ok(())
}

pub async fn delete_music_cache(music_info: &MusicInfo) -> Result<(), anyhow::Error> {
    let path = gen_file_name(music_info).await?;
    if path.exists() {
        let file = std::fs::File::open(&path)?;
        let reader = std::io::BufReader::new(file);
        let playinfo: PlayInfo = serde_json::from_reader(reader)?;
        let _ = tokio::fs::remove_file(playinfo.uri).await;
        tokio::fs::remove_file(path).await?;
    }
    Ok(())
}

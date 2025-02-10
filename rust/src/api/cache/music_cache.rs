use super::file_cache::{cache_file_from_content, cache_file_from_uri};
use crate::api::{
    types::playinfo::PlayInfo, utils::path_util::url_encode_special_chars, APP_RHYME_FOLDER,
    LYRIC_FOLDER, MUSIC_FOLDER, PLAYINFO_FOLDER,
};
use flutter_rust_bridge::frb;
use std::{path::PathBuf, str::FromStr};

// 构建音乐缓存文件名
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

// 构建歌词缓存文件路径
fn format_lrc_file_name(name: &str, artists: &str) -> String {
    url_encode_special_chars(&format!("{}_{}.lrc", name, artists))
}

fn format_lrc_file_path(
    document_folder: &str,
    custom_cache_root: &Option<String>,
    name: &str,
    artists: &str,
) -> Result<PathBuf, anyhow::Error> {
    Ok(match custom_cache_root {
        Some(custom_cache_root) => PathBuf::from_str(&custom_cache_root)?,
        None => PathBuf::from_str(document_folder)?,
    }
    .join(APP_RHYME_FOLDER)
    .join(LYRIC_FOLDER)
    .join(url_encode_special_chars(&format!(
        "{}_{}.lrc",
        name, artists
    ))))
}

fn format_music_play_info_file_name(name: &str, artists: &str) -> String {
    url_encode_special_chars(&format!("{}_{}.json", name, artists))
}

// 构建音乐缓存元数据文件路径
fn format_music_play_info_file_path(
    document_folder: &str,
    custom_cache_root: &Option<String>,
    name: &str,
    artists: &str,
) -> Result<PathBuf, anyhow::Error> {
    Ok(match custom_cache_root {
        Some(custom_cache_root) => PathBuf::from_str(&custom_cache_root)?,
        None => PathBuf::from_str(document_folder)?,
    }
    .join(APP_RHYME_FOLDER)
    .join(PLAYINFO_FOLDER)
    .join(url_encode_special_chars(&format!(
        "{}_{}.json",
        name, artists
    ))))
}

#[frb]
// 音乐是否存在缓存
// 根据音乐元数据文件是否存在判断
pub async fn has_cache_music(
    document_folder: &str,
    custom_cache_root: &Option<String>,
    name: String,
    artists: String,
) -> bool {
    format_music_play_info_file_path(document_folder, custom_cache_root, &name, &artists)
        .ok()
        .map(|path| path.exists())
        .unwrap_or(false)
}

// 获取缓存的音乐和歌词
#[frb]
pub async fn get_cache_music(
    document_folder: &str,
    custom_cache_root: &Option<String>,
    name: String,
    artists: String,
) -> (Option<PlayInfo>, Option<String>) {
    let mut playinfo =
        match format_music_play_info_file_path(document_folder, custom_cache_root, &name, &artists)
        {
            Ok(path) => {
                if path.exists() {
                    match tokio::fs::read_to_string(path).await {
                        Ok(content_str) => match serde_json::from_str::<PlayInfo>(&content_str) {
                            Ok(playinfo) => Some(playinfo),
                            Err(_) => None,
                        },
                        Err(_) => None,
                    }
                } else {
                    None
                }
            }
            Err(_) => None,
        };

    // 验证PlayInfo指向的音乐文件是否存在
    // 如果不存在可能是用户手动删除了音乐文件
    // 此时不返回PlayInfo
    // 但是歌词可能存在, 所以继续歌词逻辑
    if let Some(playinfo_) = &playinfo {
        let music_path = match PathBuf::from_str(&playinfo_.uri) {
            Ok(path) => path,
            Err(_) => return (None, None),
        };
        if !music_path.exists() {
            playinfo = None;
        }
    }

    let lyric = match format_lrc_file_path(document_folder, custom_cache_root, &name, &artists) {
        Ok(path) => {
            if path.exists() {
                match tokio::fs::read_to_string(path).await {
                    Ok(content_str) => Some(content_str),
                    Err(_) => None,
                }
            } else {
                None
            }
        }
        Err(_) => None,
    };

    (playinfo, lyric)
}

// 缓存音乐和歌词
// 音乐保存到 MUSIC_FOLDER
// 歌词保存到 LYRIC_FOLDER
// 元数据保存到 PLAYINFO_FOLDER
pub async fn cache_music(
    document_folder: &str,
    custom_cache_root: &Option<String>,
    name: String,
    artists: String,
    mut playinfo: PlayInfo,
    lyric: Option<String>,
) -> Result<(), anyhow::Error> {
    // 缓存音乐文件
    // 如果缓存失败, 直接返回错误
    let cached_music_path = cache_file_from_uri(
        document_folder,
        &playinfo.uri,
        MUSIC_FOLDER,
        &Some(format_music_file_name(&name, &artists, &playinfo)),
        custom_cache_root,
    )
    .await?;

    // 缓存 PlayInfo
    // 更新 playinfo.uri 为缓存后的路径, 并且保存json到 PLAYINFO_FOLDER
    playinfo.uri = cached_music_path;
    let playinfo_json = serde_json::to_string(&playinfo)?;
    cache_file_from_content(
        document_folder,
        playinfo_json,
        PLAYINFO_FOLDER,
        format_music_play_info_file_name(&name, &artists),
        custom_cache_root,
    )
    .await?;

    // 如果有歌词, 缓存歌词
    if let Some(lyric) = lyric {
        let lyric_filename = format_lrc_file_name(&name, &artists);
        cache_file_from_content(
            document_folder,
            lyric,
            LYRIC_FOLDER,
            lyric_filename,
            custom_cache_root,
        )
        .await?;
    }

    Ok(())
}

// 删除音乐缓存
// 需要删除音乐文件, 歌词文件, 元数据文件
pub async fn delete_music_cache(
    document_folder: &str,
    custom_cache_root: &Option<String>,
    name: &str,
    artists: &str,
) -> Result<(), anyhow::Error> {
    let playinfo_file_path =
        format_music_play_info_file_path(document_folder, custom_cache_root, name, artists)?;

    let playinfo = match tokio::fs::read_to_string(&playinfo_file_path).await {
        Ok(content_str) => match serde_json::from_str::<PlayInfo>(&content_str) {
            Ok(playinfo) => playinfo,
            Err(_) => return Ok(()),
        },
        Err(_) => return Ok(()),
    };
    let music_file_path = PathBuf::from_str(&playinfo.uri)?;

    if playinfo_file_path.exists() {
        tokio::fs::remove_file(playinfo_file_path).await?;
    }

    if music_file_path.exists() {
        tokio::fs::remove_file(music_file_path).await?;
    }

    let lyric_file_path = format_lrc_file_path(document_folder, custom_cache_root, name, artists)?;
    if lyric_file_path.exists() {
        tokio::fs::remove_file(lyric_file_path).await?;
    }

    Ok(())
}

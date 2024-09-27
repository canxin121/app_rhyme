use anyhow::Result;
use futures::StreamExt as _;
use music_api::CLIENT;
use std::hash::{DefaultHasher, Hash as _, Hasher as _};
use std::path::PathBuf;
use std::str::FromStr;
use tokio::io::AsyncWriteExt as _;

use crate::api::utils::path_util::url_encode_special_chars;
use crate::api::APP_RHYME_FOLDER;

use super::FILE_OP_SEMAPHORE;

// 生成哈希值作为文件名
#[flutter_rust_bridge::frb]
pub fn gen_hash(str_: &str) -> String {
    let mut hasher = DefaultHasher::new();
    str_.hash(&mut hasher);
    format!("{:x}", hasher.finish())
}

/// cache file
/// uri: file path or url
/// filename: file name, if None, use hash value
/// custom_cache_root: custom storage path, if None, use root path of the app
#[flutter_rust_bridge::frb]
pub async fn cache_file_from_uri(
    document_folder: &str,
    uri: &str,
    cache_folder: &str,
    filename: Option<String>,
    custom_cache_root: Option<String>,
) -> Result<String, anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;
    let filename = match filename {
        None => gen_hash(uri),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let cache_folder_path = match custom_cache_root {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_folder)?,
    }
    .join(APP_RHYME_FOLDER)
    .join(cache_folder);

    if !cache_folder_path.exists() {
        tokio::fs::create_dir_all(&cache_folder_path).await?;
    }

    let file_path = cache_folder_path.join(&filename);

    if uri.starts_with("http") {
        let response = CLIENT.get(uri).send().await?;
        let mut stream = response.bytes_stream();
        let mut file = tokio::fs::File::create(&file_path).await?;
        while let Some(chunk) = stream.next().await {
            let data = chunk?;
            file.write_all(&data).await?;
        }
    } else {
        tokio::fs::copy(uri, &file_path).await?;
    }

    Ok(file_path.to_string_lossy().to_string())
}

/// cache file from content
/// content: file content
/// filename: file name
/// custom_cache_root: custom storage path, if None, use root path of the app
pub async fn cache_file_from_content(
    document_folder: &str,
    content: String,
    cache_folder: &str,
    filename: String,
    custom_cache_root: Option<String>,
) -> Result<String, anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let cache_folder_path = match custom_cache_root {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_folder)?,
    }
    .join(APP_RHYME_FOLDER)
    .join(cache_folder);

    if !cache_folder_path.exists() {
        tokio::fs::create_dir_all(&cache_folder_path).await?;
    }

    let file_path = cache_folder_path.join(&filename);

    let mut file = tokio::fs::File::create(&file_path).await?;
    file.write_all(content.as_bytes()).await?;

    Ok(file_path.to_string_lossy().to_string())
}

// get cached file path from uri
// uri: file path or url
// root: root path of the app
// filename: file name, if None, use hash value
// custom_cache_root: custom storage path, if None, use root path of the app
#[flutter_rust_bridge::frb(sync)]
pub fn get_cache_file_from_uri(
    document_folder: &str,
    uri: &str,
    cache_folder: &str,
    filename: Option<String>,
    custom_cache_root: Option<String>,
) -> Option<String> {
    let filename = match filename {
        None => gen_hash(uri),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let file_path = match custom_cache_root {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_folder).ok()?,
    }
    .join(APP_RHYME_FOLDER)
    .join(cache_folder)
    .join(filename);

    if file_path.exists() {
        Some(file_path.to_string_lossy().into_owned())
    } else {
        None
    }
}

// delete cached file
// uri: file path or url
// filename: file name, if None, use hash value
// custom_cache_root: custom storage path, if None, use root path of the app
#[flutter_rust_bridge::frb]
pub async fn delete_cache_file_with_uri(
    document_folder: &str,
    uri: &str,
    cache_folder: &str,
    filename: Option<String>,
    custom_cache_root: Option<String>,
) -> Result<(), anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let filename = match filename {
        None => gen_hash(uri),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let file_path = match custom_cache_root {
        Some(export_root) => export_root.into(),
        None => PathBuf::from_str(document_folder)?,
    }
    .join(APP_RHYME_FOLDER)
    .join(cache_folder)
    .join(&filename);

    if file_path.exists() {
        tokio::fs::remove_file(&file_path).await?;
        Ok(())
    } else {
        Err(anyhow::Error::new(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            "File not found",
        )))
    }
}

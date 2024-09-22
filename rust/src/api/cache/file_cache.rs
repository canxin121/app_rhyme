use anyhow::Result;
use futures::StreamExt as _;
use music_api::CLIENT;
use std::hash::{DefaultHasher, Hash as _, Hasher as _};
use std::path::PathBuf;
use tokio::io::AsyncWriteExt;

use crate::api::utils::path_util::url_encode_special_chars;
use crate::api::ROOT_PATH;

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
/// custom_root: custom storage path, if None, use root path of the app
#[flutter_rust_bridge::frb]
pub async fn cache_file_from_uri(
    uri: &str,
    cache_folder: &str,
    filename: Option<String>,
    custom_root: Option<String>,
) -> Result<String, anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;
    let filename = match filename {
        None => gen_hash(uri),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let mut root_path = match custom_root {
        Some(export_root) => export_root.into(),
        None => ROOT_PATH.read().await.clone(),
    };

    root_path.push(cache_folder);

    if !root_path.exists() {
        tokio::fs::create_dir_all(&root_path).await?;
    }

    let filepath = root_path
        .join(&filename)
        .to_string_lossy()
        .to_string()
        .replace("\r", "");
    if uri.starts_with("http") {
        let response = CLIENT.get(uri).send().await?;
        let mut stream = response.bytes_stream();
        let mut file = tokio::fs::File::create(&filepath).await?;
        while let Some(chunk) = stream.next().await {
            let data = chunk?;
            file.write_all(&data).await?;
        }
    } else {
        tokio::fs::copy(uri, &filepath).await?;
    }

    Ok(filepath)
}

/// cache file from content
/// content: file content
/// filename: file name
/// custom_root: custom storage path, if None, use root path of the app
pub async fn cache_file_from_content(
    content: String,
    cache_folder: &str,
    filename: String,
    custom_root: Option<String>,
) -> Result<String, anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let mut root_path = match custom_root {
        Some(export_root) => export_root.into(),
        None => ROOT_PATH.read().await.clone(),
    };

    root_path.push(cache_folder);

    if !root_path.exists() {
        tokio::fs::create_dir_all(&root_path).await?;
    }

    let filepath = root_path
        .join(&filename)
        .to_string_lossy()
        .to_string()
        .replace("\r", "");

    let mut file = tokio::fs::File::create(&filepath).await?;
    file.write_all(content.as_bytes()).await?;

    Ok(filepath)
}

// get cached file path from uri
// uri: file path or url
// root: root path of the app
// filename: file name, if None, use hash value
// custom_root: custom storage path, if None, use root path of the app
#[flutter_rust_bridge::frb(sync)]
pub fn get_cache_file_from_uri(
    uri: &str,
    cache_folder: &str,
    filename: Option<String>,
    root: String,
    custom_root: Option<String>,
) -> Option<String> {
    let filename = match filename {
        None => gen_hash(uri),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let mut folder = PathBuf::from(custom_root.unwrap_or(root));
    folder.push(cache_folder);

    let filepath = folder.join(&filename);

    if filepath.exists() {
        Some(filepath.to_string_lossy().into_owned())
    } else {
        None
    }
}

// delete cached file
// uri: file path or url
// filename: file name, if None, use hash value
// custom_root: custom storage path, if None, use root path of the app
#[flutter_rust_bridge::frb]
pub async fn delete_cache_file_with_uri(
    uri: &str,
    cache_folder: &str,
    filename: Option<String>,
    custom_root: Option<String>,
) -> Result<(), anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let filename = match filename {
        None => gen_hash(uri),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let mut root_path = match custom_root {
        Some(export_root) => export_root.into(),
        None => ROOT_PATH.read().await.clone(),
    };

    root_path.push(cache_folder);

    let filepath = root_path.join(&filename);

    if filepath.exists() {
        tokio::fs::remove_file(&filepath).await?;
        Ok(())
    } else {
        Err(anyhow::Error::new(std::io::Error::new(
            std::io::ErrorKind::NotFound,
            "File not found",
        )))
    }
}

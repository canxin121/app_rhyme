use anyhow::Result;
use futures::StreamExt as _;
use lazy_static::lazy_static;
use music_api::util::CLIENT;
use std::hash::{DefaultHasher, Hash as _, Hasher as _};
use std::path::{Path, PathBuf};
use std::sync::Arc;
use std::thread::sleep;
use std::time::Duration;
use tokio::fs;
use tokio::io::AsyncWriteExt;
use tokio::sync::Semaphore;

use crate::api::utils::path_util::url_encode_special_chars;
use crate::api::{CONFIG, ROOT_PATH};

use super::FILE_OP_SEMAPHORE;

// 生成哈希值作为文件名
#[flutter_rust_bridge::frb]
pub fn gen_hash(str_: &str) -> String {
    let mut hasher = DefaultHasher::new();
    str_.hash(&mut hasher);
    format!("{:x}", hasher.finish())
}

#[flutter_rust_bridge::frb]
pub async fn cache_file(
    file: &str,
    cache_path: &str,
    filename: Option<String>,
    export_root: Option<String>,
) -> Result<String, anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;
    let filename = match filename {
        None => gen_hash(file),
        Some(filename) => url_encode_special_chars(&filename),
    };
    let mut root_path = match export_root {
        Some(export_root) => export_root.into(),
        None => ROOT_PATH.read().await.clone(),
    };

    root_path.push(cache_path);

    if !root_path.exists() {
        tokio::fs::create_dir_all(&root_path).await?;
    }

    let filepath = root_path
        .join(&filename)
        .to_string_lossy()
        .to_string()
        .replace("\r", "");

    if file.starts_with("http") {
        let response = CLIENT.get(file).send().await?;
        let mut stream = response.bytes_stream();
        let mut file = tokio::fs::File::create(&filepath).await?;
        while let Some(chunk) = stream.next().await {
            let data = chunk?;
            file.write_all(&data).await?;
        }
    } else {
        tokio::fs::copy(file, &filepath).await?;
    }

    Ok(filepath)
}

#[flutter_rust_bridge::frb(sync)]
pub fn use_cache_file(
    file: &str,
    cache_path: &str,
    filename: Option<String>,
    export_root: Option<String>,
) -> Option<String> {
    let filename = match filename {
        None => gen_hash(file),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let mut attempts = 0;
    let max_attempts = 5;
    let mut root_path = match export_root {
        Some(export_root) => {
            let mut root_path: PathBuf = export_root.into();
            root_path.push(cache_path);
            let filepath = root_path.join(&filename);

            if filepath.exists() {
                return Some(filepath.to_string_lossy().into_owned());
            } else {
                None
            }
        }
        None => {
            let mut root = None;

            while attempts < max_attempts {
                match ROOT_PATH.try_read() {
                    Ok(lock) => {
                        root = Some(lock.clone());
                        break;
                    }
                    Err(_) => {
                        attempts += 1;
                        sleep(Duration::from_millis(10)); // 等待 10 毫秒后重试
                    }
                }
            }

            let root = root;
            root
        }
    }?;

    root_path.push(cache_path);
    let filepath = root_path.join(&filename);

    if filepath.exists() {
        Some(filepath.to_string_lossy().into_owned())
    } else {
        None
    }
}

#[flutter_rust_bridge::frb]
pub async fn delete_cache_file(
    file: &str,
    cache_path: &str,
    filename: Option<String>,
    export_root: Option<String>,
) -> Result<(), anyhow::Error> {
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let filename = match filename {
        None => gen_hash(file),
        Some(filename) => url_encode_special_chars(&filename),
    };

    let mut root_path = match export_root {
        Some(export_root) => export_root.into(),
        None => ROOT_PATH.read().await.clone(),
    };

    root_path.push(cache_path);

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

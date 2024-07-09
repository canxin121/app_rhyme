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

use super::config::Config;
use super::ROOT_PATH;

lazy_static! {
    static ref FILE_OP_SEMAPHORE: Arc<Semaphore> = Arc::new(Semaphore::new(100));
}

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
        Some(filename) => filename.to_string(),
    };
    let mut root_path = match export_root {
        Some(export_root) => export_root.into(),
        None => ROOT_PATH.read().await.clone(),
    };

    root_path.push(cache_path);

    if !root_path.exists() {
        tokio::fs::create_dir_all(&root_path).await?;
    }

    let filepath = root_path.join(&filename);

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

    Ok(filepath.to_string_lossy().into_owned())
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
        Some(filename) => filename,
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
        Some(filename) => filename.to_string(),
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

#[flutter_rust_bridge::frb]
pub async fn rename(from: &str, to: &str) -> Result<(), anyhow::Error> {
    // from 和 to 都是绝对路径, 不需要拼接
    // 不需要使用 ROOT_PATH
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let from_path = PathBuf::from(from);
    let to_path = PathBuf::from(to);
    tokio::fs::rename(from_path, to_path).await?;
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn copy_file(from: &str, to: &str) -> Result<(), anyhow::Error> {
    let from_path = Path::new(from);
    let to_path = Path::new(to);

    // 如果目标文件存在, 则删除
    if to_path.exists() {
        fs::remove_file(to_path).await?;
    }

    // 如果目标目录不存在, 则创建
    if let Some(parent) = to_path.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent).await?;
        }
    }

    fs::copy(from_path, to_path).await?;
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn copy_directory(src: &str, dst: &str) -> Result<(), anyhow::Error> {
    let src_path = Path::new(src);
    let dst_path = Path::new(dst);

    if !dst_path.exists() {
        fs::create_dir_all(dst_path).await?;
    }

    // 如果源目录不存在, 则直接返回, 不需要拷贝
    if !src_path.exists() {
        return Ok(());
    }

    let mut entries = fs::read_dir(src_path).await?;
    while let Some(entry) = entries.next_entry().await? {
        let entry_path = entry.path();
        if entry_path.is_file() {
            let file_name = entry.file_name();
            let dst_file_path = dst_path.join(file_name);
            copy_file(
                entry_path.to_str().unwrap(),
                dst_file_path.to_str().unwrap(),
            )
            .await?;
        }
    }

    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn remove_dir(dir: &str) -> Result<(), anyhow::Error> {
    // file 是绝对路径, 不需要拼接
    // 不需要使用 ROOT_PATH
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let dir_path = PathBuf::from(dir);
    if dir_path.exists() {
        tokio::fs::remove_dir_all(dir_path).await?;
    }
    Ok(())
}

#[flutter_rust_bridge::frb]
pub async fn remove_file(file: &str) -> Result<(), anyhow::Error> {
    // file 是绝对路径, 不需要拼接
    // 不需要使用 ROOT_PATH
    let _ = FILE_OP_SEMAPHORE.acquire().await?;

    let file_path = PathBuf::from(file);
    if file_path.exists() {
        tokio::fs::remove_file(file_path).await?;
    }
    Ok(())
}

pub(crate) async fn del_old_data() -> Result<(), anyhow::Error> {
    let config = Config::load().await?;
    let root_path = match config.last_export_cache_root {
        Some(export_root) => export_root,
        None => {
            let root_path = ROOT_PATH.read().await.clone();
            root_path.to_str().unwrap().to_string()
        }
    };
    let root = Path::new(&root_path).to_owned();
    let mut pic_path = root.clone();
    pic_path.push("Pic");
    let mut music_path = root.clone();
    music_path.push("Music");
    let mut db_path = root.clone();
    db_path.push("MusicData.db");
    if pic_path.exists() {
        remove_dir(pic_path.to_str().ok_or(anyhow::anyhow!("pic_path error"))?).await?;
    }
    if music_path.exists() {
        remove_dir(
            music_path
                .to_str()
                .ok_or(anyhow::anyhow!("music_path error"))?,
        )
        .await?;
    }
    if db_path.exists() {
        remove_file(db_path.to_str().ok_or(anyhow::anyhow!("db_path error"))?).await?;
    }
    Ok(())
}

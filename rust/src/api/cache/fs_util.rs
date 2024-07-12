use std::path::{Path, PathBuf};

use tokio::fs;

use crate::api::{CONFIG, ROOT_PATH};

use super::FILE_OP_SEMAPHORE;

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
    let config = CONFIG
        .read()
        .await
        .clone()
        .ok_or(anyhow::anyhow!("global config is None"))?;
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

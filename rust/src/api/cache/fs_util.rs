use flutter_rust_bridge::frb;
use std::path::PathBuf;
use tokio::fs;

#[frb(ignore)]
pub async fn copy_file(from: &PathBuf, to: &PathBuf) -> Result<(), anyhow::Error> {
    if to.exists() {
        fs::remove_file(to).await?;
    }

    if let Some(parent) = to.parent() {
        if !parent.exists() {
            fs::create_dir_all(parent).await?;
        }
    }

    fs::copy(from, to).await?;
    Ok(())
}

#[frb(ignore)]
pub async fn copy_directory(from: &PathBuf, to: &PathBuf) -> Result<(), anyhow::Error> {
    if !to.exists() {
        fs::create_dir_all(to).await?;
    }

    if !from.exists() {
        return Ok(());
    }

    let mut entries = fs::read_dir(from).await?;
    while let Some(entry) = entries.next_entry().await? {
        let entry_path = entry.path();
        if entry_path.is_file() {
            let file_name = entry.file_name();
            let dst_file_path = to.join(file_name);
            copy_file(&entry_path, &dst_file_path).await?;
        }
    }

    Ok(())
}

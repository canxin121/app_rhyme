use tokio::fs::create_dir_all;

use crate::api::{APP_RHYME_FOLDER, LYRIC_FOLDER, MUSIC_FOLDER, PIC_FOLDER, PLAYINFO_FOLDER};
use std::{path::PathBuf, str::FromStr as _};

use super::fs_util::move_directory;

// 需要一种移动缓存数据的方法
// 只需要移动 PIC_FOLDER、MUSIC_FOLDER、PLAYINFO_FOLDER、LYRIC_FOLDER 四个文件夹就可以
// 移动之后直接关闭整个应用
pub async fn move_cache_data(
    document_path: &str,
    old_custom_cache_root: Option<String>,
    new_custom_cache_root: String,
) -> Result<(), anyhow::Error> {
    let old_cache_root = old_custom_cache_root.unwrap_or_else(|| document_path.to_string());

    let old_cache_root = PathBuf::from_str(&old_cache_root)?;
    let new_cache_root = PathBuf::from_str(&new_custom_cache_root)?;

    let old_base_folder = old_cache_root.join(APP_RHYME_FOLDER);
    let new_base_folder = new_cache_root.join(APP_RHYME_FOLDER);

    // 确保new_base_folder存在
    create_dir_all(&new_base_folder).await?;

    let old_pic_folder = old_base_folder.join(PIC_FOLDER);
    let new_pic_folder = new_base_folder.join(PIC_FOLDER);

    let old_music_folder = old_base_folder.join(MUSIC_FOLDER);
    let new_music_folder = new_base_folder.join(MUSIC_FOLDER);

    let old_playinfo_folder = old_base_folder.join(PLAYINFO_FOLDER);
    let new_playinfo_folder = new_base_folder.join(PLAYINFO_FOLDER);

    let old_lyric_folder = old_base_folder.join(LYRIC_FOLDER);
    let new_lyric_folder = new_base_folder.join(LYRIC_FOLDER);

    move_directory(&old_pic_folder, &new_pic_folder).await?;
    move_directory(&old_music_folder, &new_music_folder).await?;
    move_directory(&old_playinfo_folder, &new_playinfo_folder).await?;
    move_directory(&old_lyric_folder, &new_lyric_folder).await?;

    Ok(())
}

// 删除缓存数据
// 只需要删除 PIC_FOLDER、MUSIC_FOLDER、PLAYINFO_FOLDER、LYRIC_FOLDER 四个文件夹就可以
pub async fn delete_cache_data(
    document_path: &str,
    custom_cache_root: Option<String>,
) -> Result<(), anyhow::Error> {
    let cache_root = custom_cache_root.unwrap_or_else(|| document_path.to_string());
    let cache_root = PathBuf::from_str(&cache_root)?;

    let base_folder = cache_root.join(APP_RHYME_FOLDER);

    let pic_folder = base_folder.join(PIC_FOLDER);
    let music_folder = base_folder.join(MUSIC_FOLDER);
    let playinfo_folder = base_folder.join(PLAYINFO_FOLDER);
    let lyric_folder = base_folder.join(LYRIC_FOLDER);

    if pic_folder.exists() {
        tokio::fs::remove_dir_all(&pic_folder).await?;
    }
    if music_folder.exists() {
        tokio::fs::remove_dir_all(&music_folder).await?;
    }
    if playinfo_folder.exists() {
        tokio::fs::remove_dir_all(&playinfo_folder).await?;
    }
    if lyric_folder.exists() {
        tokio::fs::remove_dir_all(&lyric_folder).await?;
    }

    Ok(())
}

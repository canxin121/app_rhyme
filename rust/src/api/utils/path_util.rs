use std::path::PathBuf;

use flutter_rust_bridge::frb;

use crate::api::{CONFIG, ROOT_PATH};

#[frb(ignore)]
pub(crate) async fn get_root_path() -> Result<PathBuf, anyhow::Error> {
    let global_config = CONFIG.read().await;
    let mut result = None;
    if let Some(config) = global_config.as_ref() {
        if let Some(export_cache_root) = config.export_cache_root.as_ref() {
            result = Some(PathBuf::from(export_cache_root));
        }
    }
    if result.is_none() {
        let root_path = ROOT_PATH.read().await;
        result = Some(root_path.clone());
    }
    result.ok_or(anyhow::anyhow!("Failed to get root path"))
}

pub fn url_encode_special_chars(input: &str) -> String {
    // 创建一个映射，将特殊字符映射到它们的URL编码
    let special_chars = [
        ('\\', "%5C"),
        ('/', "%2F"),
        (':', "%3A"),
        ('*', "%2A"),
        ('?', "%3F"),
        ('"', "%22"),
        ('<', "%3C"),
        ('>', "%3E"),
        ('|', "%7C"),
    ];

    // 创建一个新的String以存储结果
    let mut encoded = String::new();

    // 逐字符遍历输入字符串
    for c in input.chars() {
        // 如果字符在映射中，则替换为URL编码，否则保留原字符
        match special_chars.iter().find(|&&(sc, _)| sc == c) {
            Some(&(_, code)) => encoded.push_str(code),
            None => encoded.push(c),
        }
    }

    encoded
}

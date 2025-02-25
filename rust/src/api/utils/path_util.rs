use std::{path::PathBuf, str::FromStr};

use crate::api::{APP_RHYME_FOLDER, LOGS_FOLDER};

pub fn url_encode_special_chars(input: &str) -> String {
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
        (' ', "%20"),
    ];

    let mut encoded = String::new();

    for c in input.chars() {
        match special_chars.iter().find(|&&(sc, _)| sc == c) {
            Some(&(_, code)) => encoded.push_str(code),
            None => encoded.push(c),
        }
    }

    encoded
}

pub fn get_log_dir(document_dir: String) -> anyhow::Result<String> {
    Ok(PathBuf::from_str(&document_dir)?
        .join(APP_RHYME_FOLDER)
        .join(LOGS_FOLDER)
        .to_string_lossy()
        .to_string())
}

pub fn get_apprhyme_dir(document_dir: String) -> anyhow::Result<String> {
    Ok(PathBuf::from_str(&document_dir)?
        .join(APP_RHYME_FOLDER)
        .to_string_lossy()
        .to_string())
}

pub mod cache;
pub mod init;
pub mod music_api;
pub mod types;
pub mod utils;
pub mod log;

// 根目录
static APP_RHYME_FOLDER: &str = "app_rhyme";
// 根目录下的子目录
static PIC_FOLDER: &str = "pic";
static MUSIC_FOLDER: &str = "music";
static PLAYINFO_FOLDER: &str = "playinfo";
static LYRIC_FOLDER: &str = "lyric";
static LOGS_FOLDER: &str = "logs";
// 一些文件名
static DB_FILE: &str = "music_data.db";
static CONFIG_FILE: &str = "config.json";
static EXTERNAL_API_FILE: &str = "plugin.evc";
static EXTERNAL_API_FOLDER: &str = "plugin";

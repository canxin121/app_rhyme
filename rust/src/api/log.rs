use std::{
    io::{Read, Write},
    path,
    sync::LazyLock,
};

use flexi_logger::{
    style, Cleanup, Criterion, DeferredNow, Logger as FlexiLogger, LoggerHandle, Naming,
    TS_DASHES_BLANK_COLONS_DOT_BLANK,
};
use log::Record;
use tokio::sync::Mutex;

use super::utils::path_util::get_log_dir;

#[flutter_rust_bridge::frb(init)]
pub async fn init() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub enum LogLevel {
    Debug,
    Info,
    Warn,
    Error,
}

impl LogLevel {
    fn to_str(&self) -> &str {
        match self {
            LogLevel::Debug => "debug",
            LogLevel::Info => "info",
            LogLevel::Warn => "warn",
            LogLevel::Error => "error",
        }
    }
}

pub struct Logger{}

fn format_log(
    w: &mut dyn std::io::Write,
    now: &mut DeferredNow,
    record: &Record,
) -> Result<(), std::io::Error> {
    let level = record.level();
    write!(
        w,
        "[{}] {} [{}:{}] {}",
        style(level).paint(now.format(TS_DASHES_BLANK_COLONS_DOT_BLANK).to_string()),
        style(level).paint(level.to_string()),
        record.file().unwrap_or("<unnamed>"),
        record.line().unwrap_or(0),
        style(level).paint(record.args().to_string())
    )
}

static LOGGER_HANDLE: LazyLock<Mutex<Option<LoggerHandle>>> = LazyLock::new(|| Mutex::new(None));

impl Logger {
    pub async fn new(
        log_dir: String,
        max_level: LogLevel,
        max_log_size: u64,
        max_log_files: usize,
    ) -> anyhow::Result<Self> {
        let mut logger_handle = LOGGER_HANDLE.lock().await;
        if logger_handle.is_some() {
            return Ok(Logger {});
        }
        // 使用 flexi_logger 配置日志输出
        let file_appender = flexi_logger::FileSpec::default()
            .directory(log_dir) // 日志文件存放目录
            .basename("log");

        let flexi_logger = FlexiLogger::try_with_str(max_level.to_str())?
            .log_to_file(file_appender)
            .rotate(
                Criterion::Size(max_log_size),        // 文件大小超过指定值时轮换
                Naming::Timestamps,                   // 使用时间戳命名日志文件
                Cleanup::KeepLogFiles(max_log_files), // 保留最多`max_log_files`个日志文件
            )
            .format(format_log)
            .write_mode(flexi_logger::WriteMode::Async)
            .start()?;

        logger_handle.replace(flexi_logger);

        Ok(Logger {})
    }

    pub fn debug(&self, message: &str) {
        log::debug!("{}", message);
    }

    pub fn info(&self, message: &str) {
        log::info!("{}", message);
    }

    pub fn warn(&self, message: &str) {
        log::warn!("{}", message);
    }

    pub fn error(&self, message: &str) {
        log::error!("{}", message);
    }
}

pub async fn save_log(document_dir: String, output_dir: String) -> anyhow::Result<()> {
    let log_dir = get_log_dir(document_dir)?;
    let zip_file = path::Path::new(&output_dir)
        .join("app_rhyme_log_compressed")
        .with_extension("zip");
    let mut zip = zip::ZipWriter::new(std::fs::File::create(&zip_file)?);
    let options: zip::write::FileOptions<'_, ()> =
        zip::write::FileOptions::default().compression_method(zip::CompressionMethod::Stored);
    let mut buffer = Vec::new();
    for entry in std::fs::read_dir(log_dir)? {
        let entry = entry?;
        let path = entry.path();
        let name = path.file_name().unwrap().to_str().unwrap();
        zip.start_file(name, options)?;
        std::fs::File::open(path)?.read_to_end(&mut buffer)?;
        zip.write_all(&buffer)?;
        buffer.clear();
    }

    zip.finish()?;

    Ok(())
}

use std::sync::{Arc, LazyLock};

use tokio::sync::Semaphore;

pub mod cache_util;
pub mod file_cache;
pub mod fs_util;
pub mod music_cache;

static FILE_OP_SEMAPHORE: LazyLock<Arc<Semaphore>> = LazyLock::new(|| Arc::new(Semaphore::new(30)));

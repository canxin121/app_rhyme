pub mod file_cache;
pub mod fs_util;
pub mod music_cache;
use lazy_static::lazy_static;
use std::sync::Arc;
use tokio::sync::Semaphore;

lazy_static! {
    static ref FILE_OP_SEMAPHORE: Arc<Semaphore> = Arc::new(Semaphore::new(30));
}

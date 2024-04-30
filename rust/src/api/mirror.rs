#[allow(unused)]
use music_api::{MusicInfo, MusicList, Quality};

#[flutter_rust_bridge::frb(mirror(Quality))]
pub struct Quality_ {
    pub short: String,
    pub level: Option<String>,
    pub bitrate: Option<u32>,
    pub format: Option<String>,
    pub size: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(MusicInfo))]
pub struct MusicInfo_ {
    pub id: i64,
    pub source: String,
    pub name: String,
    pub artist: Vec<String>,
    pub duration: Option<u32>,
    pub album: Option<String>,
    pub qualities: Vec<Quality>,
    pub default_quality: Option<Quality>,
    pub art_pic: Option<String>,
    pub lyric: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(MusicList))]
pub struct MusicList_ {
    pub name: String,
    pub art_pic: String,
    pub desc: String,
}

#![allow(unused_imports)]
#![allow(unused_variables)]
use flutter_rust_bridge::frb;

#[frb(mirror(MusicFuzzFilter))]
pub struct MusicFuzzFilter_ {
    pub name: Option<String>,
    pub artist: Vec<String>,
    pub album: Option<String>,
}

#[frb(mirror(MusicInfo))]
#[frb(non_opaque)]
pub struct MusicInfo_ {
    // 与歌曲/平台本身无关的id，代表的仅仅是其在当前 自定义歌单 中的id
    pub id: i64,
    // 歌曲的来源平台
    pub source: String,
    // 歌曲的名字
    pub name: String,
    // 歌曲的演唱者的集合
    pub artist: Vec<String>,
    // 歌曲的时长(s)
    pub duration: Option<u32>,
    // 歌曲的专辑的名称
    pub album: Option<String>,
    // 歌曲的可选音质
    pub qualities: Vec<music_api::Quality>,
    // 歌曲默认选取的音质，可以作为本地持久储存，来为实现每首歌的默认音质均可自定义的功能
    pub default_quality: Option<music_api::Quality>,
    // 歌曲的艺术照
    pub art_pic: Option<String>,
    // 歌曲的歌词
    #[frb(non_final)]
    pub lyric: Option<String>,
}

#[frb(mirror(MusicListInfo))]
pub struct MusicListInfo_ {
    pub id: i64,
    pub name: String,
    pub art_pic: String,
    pub desc: String,
    pub extra: Option<music_api::music_list::ExtraInfo>,
}

#[frb(mirror(Quality))]
pub struct Quality_ {
    pub short: String,
    pub level: Option<String>,
    pub bitrate: Option<u32>,
    pub format: Option<String>,
    pub size: Option<String>,
}

#[frb(mirror(ExtraInfo))]
pub struct ExtraInfo_ {
    pub play_count: Option<u32>,
    pub music_count: Option<u32>,
}

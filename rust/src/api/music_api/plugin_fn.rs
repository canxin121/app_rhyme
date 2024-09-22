use flutter_rust_bridge::frb;
use music_api::data::interface::{music_aggregator::Music, quality::Quality, server::MusicServer};
use serde::Serialize;

#[frb]
#[derive(Debug, Serialize)]
pub struct ExternMusicInfo {
    pub name: String,
    pub artists: Vec<String>,
    pub server: String,
    pub identity: String,
    pub quality: Quality,
}

#[frb]
pub fn music_to_json(music: Music, quality: Quality) -> anyhow::Result<String> {
    let extern_music_info: ExternMusicInfo = ExternMusicInfo {
        name: music.name,
        artists: music.artists.into_iter().map(|a| a.name).collect(),
        server: match music.server {
            MusicServer::Kuwo => "kuwo".to_string(),
            MusicServer::Netease => "netease".to_string(),
        },
        identity: music.identity,
        quality,
    };
    Ok(serde_json::to_string(&extern_music_info)?)
}

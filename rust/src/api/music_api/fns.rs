#![allow(unused, non_camel_case_types)]
use anyhow::Result;
use flutter_rust_bridge::frb;
use music_api::{
    data::interface::{
        json::{MusicAggregatorJsonVec, PlaylistJsonVec},
        music_aggregator::{Music, MusicAggregator},
        playlist::Playlist,
        playlist_subscription::PlayListSubscription,
        results::PlaylistUpdateSubscriptionResult,
        server::MusicServer,
    },
    server::kuwo::web_api::music,
};

#[frb(external)]
impl Music {
    /// get music cover of specific size
    #[frb(sync)]
    pub fn get_cover(&self, size: u16) -> Option<String> {}

    /// Search music online
    pub async fn search_online(
        servers: Vec<MusicServer>,
        content: String,
        page: i64,
        size: i64,
    ) -> Result<Vec<Music>> {
    }

    /// return the album playlist on first page, and musics on each page
    /// on some music server, the page and limit has no effect, they just return the all musics.
    pub async fn get_album(
        &self,
        page: u16,
        limit: u16,
    ) -> Result<(Option<Playlist>, Vec<MusicAggregator>)> {
    }

    pub async fn get_lyric(&self) -> Result<String> {}
    /// 允许外部调用更新音乐的功能
    pub async fn update_to_db(&self) -> anyhow::Result<Self> {}

    pub async fn insert_to_db(&self) -> anyhow::Result<()> {}
}

#[frb(external)]
impl MusicAggregator {
    #[frb(sync)]
    pub fn identity(&self) -> String {}

    pub fn from_music(music: Music) -> Self {}

    pub async fn save_to_db(&self) -> Result<(), anyhow::Error> {}

    pub async fn del_from_db(&self) -> Result<(), anyhow::Error> {}

    pub async fn search_online(
        aggs: Vec<MusicAggregator>,
        servers: Vec<MusicServer>,
        content: String,
        page: i64,
        size: i64,
    ) -> anyhow::Result<Vec<Self>> {
    }

    pub async fn fetch_server_online(self, servers: Vec<MusicServer>) -> anyhow::Result<Self> {}

    pub async fn change_default_server_in_db(
        &self,
        server: MusicServer,
    ) -> Result<(), anyhow::Error> {
    }

    pub async fn update_order_to_db(&self, playlist_id: i64) -> Result<(), anyhow::Error> {}
}

#[frb(external)]
impl Playlist {
    /// get playlist cover of specific size
    #[frb(sync)]
    pub fn get_cover(&self, size: u16) -> Option<String> {}

    /// Search playlist online
    pub async fn search_online(
        servers: Vec<MusicServer>,
        content: String,
        page: i64,
        size: i64,
    ) -> Result<Vec<Playlist>> {
    }

    /// get a playlist from share link
    pub async fn get_from_share(share: &str) -> Result<Self> {}

    /// Fetch musics from playlist
    pub async fn fetch_musics_online(&self, page: u16, limit: u16) -> Result<Vec<MusicAggregator>> {
    }
    pub fn new(
        name: String,
        summary: Option<String>,
        cover: Option<String>,
        subscriptions: Vec<PlayListSubscription>,
    ) -> Self {
    }

    /// find db playlist by primary key `id`
    pub async fn find_in_db(id: i64) -> Option<Self> {}

    /// update db playlist info
    pub async fn update_to_db(&self) -> Result<Self> {}

    // insert a playlist to db
    pub async fn insert_to_db(&self) -> Result<i64> {}

    /// delete a playlist from db
    /// this will also delete all junctions between the playlist and music
    pub async fn del_from_db(self) -> Result<()> {}

    /// get playlists from db
    pub async fn get_from_db() -> Result<Vec<Self>> {}

    /// add playlist music aggregator junction to db
    /// this will also add the music and music aggregators to the db
    pub async fn add_aggs_to_db(&self, music_aggs: &Vec<MusicAggregator>) -> Result<()> {}

    /// get all music aggregators from db
    pub async fn get_musics_from_db(&self) -> Result<Vec<MusicAggregator>> {}

    /// update playlist music aggregator of subscribed playlist into db playlist
    pub async fn update_subscription(&self) -> Result<PlaylistUpdateSubscriptionResult> {}

    pub async fn del_music_agg(&self, music_agg_identity: String) -> anyhow::Result<()> {}
}

#[frb(external)]
impl MusicServer {
    #[frb(sync)]
    pub fn all() -> Vec<MusicServer> {}
    #[frb(sync)]
    pub fn length() -> usize {}
    #[frb(sync)]
    pub fn to_string(&self) -> String {}
}

#[frb]
pub async fn set_db(database_url: &str) -> Result<(), anyhow::Error> {
    music_api::data::interface::database::set_db(database_url).await
}

#[frb]
pub async fn close_db() -> Result<(), anyhow::Error> {
    music_api::data::interface::database::close_db().await
}

#[frb]
pub async fn clear_db() -> Result<(), anyhow::Error> {
    music_api::data::interface::database::clear_db().await
}

#[frb]
pub async fn reinit_db() -> Result<(), anyhow::Error> {
    music_api::data::interface::database::reinit_db().await
}

use flutter_rust_bridge::frb;
pub use music_api::interface::{
    artist::{Artist, ArtistVec},
    json::{DatabaseJson, MusicAggregatorJsonVec, MusicDataType, PlaylistJson, PlaylistJsonVec},
    music_aggregator::{Music, MusicAggregator},
    music_chart::{MusicChart, MusicChartCollection, ServerMusicChartCollection},
    playlist::{Playlist, PlaylistType},
    playlist_collection::PlaylistCollection,
    playlist_subscription::PlayListSubscription,
    playlist_tag::{
        PlaylistTag, PlaylistTagCollection, ServerPlaylistTagCollection, TagPlaylistOrder,
    },
    quality::{Quality, QualityVec},
    results::PlaylistUpdateSubscriptionResult,
    server::MusicServer,
};

#[frb(mirror(Music))]
pub struct _Music {
    pub from_db: bool,
    pub server: MusicServer,
    pub identity: String,
    #[frb(non_final)]
    pub name: String,
    #[frb(non_final)]
    pub duration: Option<i64>,
    #[frb(non_final)]
    pub artists: Vec<Artist>,
    #[frb(non_final)]
    pub album: Option<String>,
    #[frb(non_final)]
    pub album_id: Option<String>,
    #[frb(non_final)]
    pub qualities: Vec<Quality>,
    #[frb(non_final)]
    pub cover: Option<String>,
}

#[frb(mirror(MusicServer))]
pub enum _MusicServer {
    Kuwo,
    Netease,
}

#[frb(mirror(Artist))]
pub struct _Artist {
    #[frb(non_final)]
    pub name: String,
    #[frb(non_final)]
    pub id: Option<String>,
}

#[frb(mirror(ArtistVec))]
pub struct _ArtistVec(pub Vec<Artist>);

#[frb(mirror(Quality))]
pub struct _Quality {
    pub summary: String,
    pub bitrate: Option<String>,
    pub format: Option<String>,
    pub size: Option<String>,
}

#[frb(mirror(QualityVec))]
pub struct _QualityVec(pub Vec<Quality>);

#[frb(mirror(MusicAggregator))]
pub struct _MusicAggregator {
    pub name: String,
    pub artist: String,
    pub from_db: bool,
    #[frb(non_final)]
    pub order: Option<i64>,
    #[frb(non_final)]
    pub musics: Vec<Music>,
    #[frb(non_final)]
    pub default_server: MusicServer,
}

#[frb(mirror(PlaylistType))]
pub enum _PlaylistType {
    UserPlaylist,
    Album,
}

#[frb(mirror(Playlist))]
pub struct _Playlist {
    pub from_db: bool,
    pub server: Option<MusicServer>,
    pub type_field: PlaylistType,
    pub identity: String,
    pub collection_id: Option<i64>,
    #[frb(non_final)]
    pub name: String,
    #[frb(non_final)]
    pub order: Option<i64>,
    #[frb(non_final)]
    pub summary: Option<String>,
    #[frb(non_final)]
    pub cover: Option<String>,
    pub creator: Option<String>,
    pub creator_id: Option<String>,
    pub play_time: Option<i64>,
    pub music_num: Option<i64>,
    #[frb(non_final)]
    pub subscription: Option<Vec<PlayListSubscription>>,
}

#[frb(mirror(PlayListSubscriptionVec))]
pub struct _PlayListSubscriptionVec(pub Vec<PlayListSubscription>);

#[frb(mirror(PlayListSubscription))]
pub struct _PlayListSubscription {
    #[frb(non_final)]
    pub name: String,
    #[frb(non_final)]
    pub share: String,
}

#[frb(mirror(PlaylistUpdateSubscriptionResult))]
pub struct _PlaylistUpdateSubscriptionResult {
    pub errors: Vec<(String, String)>,
}

#[frb(mirror(PlaylistJson))]
pub struct _PlaylistJson {
    pub playlist: Playlist,
    pub music_aggregators: Vec<MusicAggregator>,
}

#[frb(mirror(PlaylistJsonVec))]
pub struct _PlaylistJsonVec(pub Vec<PlaylistJson>);

#[frb(mirror(MusicAggregatorJsonVec))]
pub struct _MusicAggregatorJsonVec(pub Vec<MusicAggregator>);

#[frb(mirror(MusicDataType))]
pub enum _MusicDataType {
    Database,
    Playlists,
    MusicAggregators,
}

#[frb(mirror(PlaylistTag))]
pub struct _PlaylistTag {
    pub name: String,
    pub id: String,
}

#[frb(mirror(PlaylistTagCollection))]
pub struct _PlaylistTagCollection {
    pub name: String,
    pub tags: Vec<PlaylistTag>,
}

#[frb(mirror(ServerPlaylistTagCollection))]
pub struct _ServerPlaylistTagCollection {
    pub server: MusicServer,
    pub collections: Vec<PlaylistTagCollection>,
}

#[frb(mirror(TagPlaylistOrder))]
pub enum _TagPlaylistOrder {
    Hot,
    New,
}

#[frb(mirror(MusicChart))]
pub struct _MusicChart {
    pub name: String,
    pub summary: Option<String>,
    pub cover: Option<String>,
    pub id: String,
}

#[frb(mirror(MusicChartCollection))]
pub struct _MusicChartCollection {
    pub name: String,
    pub summary: Option<String>,
    pub charts: Vec<MusicChart>,
}

#[frb(mirror(ServerMusicChartCollection))]
pub struct _ServerMusicChartCollection {
    pub server: MusicServer,
    pub collections: Vec<MusicChartCollection>,
}

#[frb(mirror(PlaylistCollection))]
pub struct _PlaylistCollection {
    pub id: i64,
    #[frb(non_final)]
    pub order: i64,
    #[frb(non_final)]
    pub name: String,
}

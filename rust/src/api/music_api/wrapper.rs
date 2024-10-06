use music_api::interface::{
    json::{MusicDataJson, MusicDataType},
    music_aggregator::MusicAggregator,
    playlist::Playlist,
};

pub struct MusicDataJsonWrapper(MusicDataJson);

impl MusicDataJsonWrapper {
    pub fn get_type(&self) -> MusicDataType {
        self.0.get_type()
    }

    pub fn to_json(&self) -> anyhow::Result<String> {
        self.0.to_json()
    }

    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        Ok(MusicDataJsonWrapper(MusicDataJson::from_json(json)?))
    }

    pub async fn save_to(&self, path: &str) -> anyhow::Result<()> {
        self.0.save_to(path).await
    }

    pub async fn load_from(path: &str) -> anyhow::Result<Self> {
        Ok(MusicDataJsonWrapper(MusicDataJson::load_from(path).await?))
    }

    /// takes ownership
    pub async fn apply_to_db(self, playlist_id: Option<i64>) -> anyhow::Result<()> {
        self.0.apply_to_db(playlist_id).await
    }

    pub async fn from_database() -> anyhow::Result<Self> {
        Ok(MusicDataJsonWrapper(MusicDataJson::from_database().await?))
    }

    pub async fn from_playlists(playlists: Vec<Playlist>) -> anyhow::Result<Self> {
        Ok(MusicDataJsonWrapper(
            MusicDataJson::from_playlists(playlists).await?,
        ))
    }

    pub async fn from_music_aggregators(
        music_aggregators: Vec<MusicAggregator>,
    ) -> anyhow::Result<Self> {
        Ok(MusicDataJsonWrapper(
            MusicDataJson::from_music_aggregators(music_aggregators).await?,
        ))
    }
}

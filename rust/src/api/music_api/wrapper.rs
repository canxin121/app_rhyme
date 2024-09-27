use flutter_rust_bridge::frb;
use music_api::data::interface::json::DatabaseJson;

#[frb]
pub struct DatabaseJsonWrapper(DatabaseJson);

impl DatabaseJsonWrapper {
    pub fn from_json(json: &str) -> anyhow::Result<Self> {
        DatabaseJson::from_json(json).map(|db| Self(db))
    }

    pub fn to_json(&self) -> anyhow::Result<String> {
        self.0.to_json()
    }

    pub async fn save_to(&self, path: &str) -> anyhow::Result<()> {
        self.0.save_to(path).await
    }

    pub async fn load_from(path: &str) -> anyhow::Result<Self> {
        DatabaseJson::load_from(path).await.map(|db| Self(db))
    }

    pub async fn get_from_db() -> anyhow::Result<Self> {
        DatabaseJson::get_from_db().await.map(|db| Self(db))
    }

    /// takes ownership
    pub async fn apply_to_db(self) -> anyhow::Result<()> {
        self.0.apply_to_db().await
    }
}

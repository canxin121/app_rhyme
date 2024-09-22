use flutter_rust_bridge::frb;
use music_api::data::interface::quality::Quality;
use serde::{Deserialize, Serialize};

#[frb]
#[derive(Serialize, Deserialize, Clone)]
pub struct PlayInfo {
    pub uri: String,
    pub quality: Quality,
}

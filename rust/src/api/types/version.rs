use std::cmp::Ordering;

use flutter_rust_bridge::frb;
use music_api::CLIENT;
use reqwest::header::{HeaderValue, USER_AGENT};
use serde::{Deserialize, Serialize};

#[frb]
#[derive(Debug, Serialize, Deserialize)]
pub struct Release {
    pub url: String,
    pub assets_url: String,
    pub upload_url: String,
    pub html_url: String,
    pub id: u64,
    pub author: Author,
    pub node_id: String,
    pub tag_name: String,
    pub target_commitish: String,
    pub name: String,
    pub draft: bool,
    pub prerelease: bool,
    pub created_at: String,
    pub published_at: String,
    pub assets: Vec<Asset>,
    pub tarball_url: String,
    pub zipball_url: String,
    pub body: String,
}

#[frb]
#[derive(Debug, Serialize, Deserialize)]
pub struct Author {
    pub login: String,
    pub id: u64,
    pub node_id: String,
    pub avatar_url: String,
    pub gravatar_id: String,
    pub url: String,
    pub html_url: String,
    pub followers_url: String,
    pub following_url: String,
    pub gists_url: String,
    pub starred_url: String,
    pub subscriptions_url: String,
    pub organizations_url: String,
    pub repos_url: String,
    pub events_url: String,
    pub received_events_url: String,
    pub r#type: String,
    pub site_admin: bool,
}

#[frb]
#[derive(Debug, Serialize, Deserialize)]
pub struct Asset {
    pub url: String,
    pub id: u64,
    pub node_id: String,
    pub name: String,
    pub label: Option<String>,
    pub uploader: Author,
    pub content_type: String,
    pub state: String,
    pub size: u64,
    pub download_count: u64,
    pub created_at: String,
    pub updated_at: String,
    pub browser_download_url: String,
}

pub async fn get_release() -> Result<Release, anyhow::Error> {
    let back_url = "https://raw.githubusercontent.com/canxin121/app_rhyme/main/Release_latest.json";
    let url = "https://cdn.jsdelivr.net/gh/canxin121/app_rhyme@main/Release_latest.json";

    let resp = CLIENT
        .get(url)
        .header(USER_AGENT, HeaderValue::from_static("AppRhyme"))
        .send()
        .await;

    let release = match resp {
        Ok(resp) => resp.json::<Release>().await?,
        Err(_) => {
            let back_resp = CLIENT
                .get(back_url)
                .header(USER_AGENT, HeaderValue::from_static("AppRhyme"))
                .send()
                .await?;
            back_resp.json::<Release>().await?
        }
    };

    Ok(release)
}

#[frb(ignore)]
#[derive(Debug, PartialEq, Eq)]
struct Version {
    major: u32,
    minor: u32,
    patch: u32,
}

impl Version {
    fn parse(version: &str) -> Result<Self, anyhow::Error> {
        let parts: Vec<&str> = version.trim_start_matches('v').split('.').collect();
        if parts.len() != 3 {
            return Err(anyhow::anyhow!("Invalid version"));
        }

        let major = parts[0]
            .parse()
            .map_err(|_| anyhow::anyhow!("Invalid major version"))?;
        let minor = parts[1]
            .parse()
            .map_err(|_| anyhow::anyhow!("Invalid minor version"))?;
        let patch = parts[2]
            .parse()
            .map_err(|_| anyhow::anyhow!("Invalid patch version"))?;

        Ok(Version {
            major,
            minor,
            patch,
        })
    }
}

impl Ord for Version {
    fn cmp(&self, other: &Self) -> Ordering {
        self.major
            .cmp(&other.major)
            .then_with(|| self.minor.cmp(&other.minor))
            .then_with(|| self.patch.cmp(&other.patch))
    }
}

impl PartialOrd for Version {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[frb(ignore)]
fn needs_update(current_version: &str, latest_version: &str) -> Result<bool, anyhow::Error> {
    let current = Version::parse(current_version)?;
    let latest = Version::parse(latest_version)?;

    Ok(current < latest)
}

#[frb]
pub async fn check_update(current_version: &str) -> Result<Option<Release>, anyhow::Error> {
    let release = get_release().await?;
    if needs_update(current_version, &release.tag_name)? {
        Ok(Some(release))
    } else {
        Ok(None)
    }
}

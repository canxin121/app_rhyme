use music_api::{
    search_factory::SearchFactory, sql_store_actory::SqlMusicFactory, Music, MusicInfo, MusicList,
    Quality,
};
use sqlx::{Any, Pool};
use tokio::sync::RwLock;

lazy_static::lazy_static! {
    static ref POOL:RwLock<Option<Pool<Any>>> = RwLock::new(None);
}

#[flutter_rust_bridge::frb]
pub struct MusicW {
    pub inner: Music,
}

unsafe impl Send for MusicW {}
unsafe impl Sync for MusicW {}

impl MusicW {
    #[flutter_rust_bridge::frb(sync)]
    pub fn get_music_id(&self) -> i64 {
        self.inner.get_music_id()
    }
    #[flutter_rust_bridge::frb(sync)]
    pub fn get_music_info(&self) -> MusicInfo {
        self.inner.get_music_info()
    }
    #[flutter_rust_bridge::frb(sync)]
    pub fn get_extra_into(&self, quality: &Quality) -> String {
        self.inner.get_extra_into(quality)
    }
}

impl From<Music> for MusicW {
    fn from(value: Music) -> Self {
        MusicW { inner: value }
    }
}

#[flutter_rust_bridge::frb]
pub async fn search_music_list(
    content: &str,
    page: u32,
    source: &str,
) -> Result<Vec<(String, MusicList)>, anyhow::Error> {
    Ok(SearchFactory::search_music_list(source, content, page).await?)
}

#[flutter_rust_bridge::frb]
pub async fn get_musics_from_music_list(
    payload: &str,
    page: u32,
    source: &str,
) -> Result<Vec<MusicW>, anyhow::Error> {
    Ok(
        SearchFactory::get_musics_from_music_list(source, payload, page)
            .await?
            .into_iter()
            .map(|m| MusicW::from(m))
            .collect(),
    )
}

#[flutter_rust_bridge::frb]
pub async fn search_album(
    music: &MusicW,
    page: u32,
) -> Result<(MusicList, Vec<MusicW>), anyhow::Error> {
    let (music_list, musics) = SearchFactory::search_album(&music.inner, page).await?;
    let musics = musics.into_iter().map(|m| MusicW::from(m)).collect();
    Ok((music_list, musics))
}

#[flutter_rust_bridge::frb]
pub async fn search_music(
    content: &str,
    page: u32,
    source: &str,
) -> Result<Vec<MusicW>, anyhow::Error> {
    Ok(SearchFactory::search(source, content, page)
        .await?
        .into_iter()
        .map(|m| MusicW::from(m))
        .collect())
}

#[flutter_rust_bridge::frb]
pub struct SqlMusicFactoryW {
    inner: SqlMusicFactory,
}

impl SqlMusicFactoryW {
    pub fn build(pool: Pool<Any>) -> Self {
        SqlMusicFactoryW {
            inner: SqlMusicFactory::new(pool),
        }
    }

    pub async fn init_create_table(&self) -> Result<(), anyhow::Error> {
        self.inner.init_create_table().await
    }

    pub async fn create_music_list_table(
        &self,
        music_lists: &Vec<MusicList>,
    ) -> Result<(), anyhow::Error> {
        self.inner.create_music_list_table(music_lists).await
    }

    pub async fn change_music_list_metadata(
        &self,
        old_list: &Vec<MusicList>,
        new_list: &Vec<MusicList>,
    ) -> Result<(), anyhow::Error> {
        self.inner
            .change_music_list_metadata(old_list, new_list)
            .await
    }

    pub async fn read_music_lists(&self) -> Result<Vec<MusicList>, anyhow::Error> {
        self.inner.read_music_lists().await
    }

    pub async fn del_music_list_table(
        &self,
        music_lists: &Vec<MusicList>,
    ) -> Result<(), anyhow::Error> {
        self.inner.del_music_list_table(music_lists).await
    }

    pub async fn insert_music(
        &self,
        music_list: &MusicList,
        musics: &Vec<MusicW>,
    ) -> Result<(), anyhow::Error> {
        self.inner
            .insert_music(music_list, &musics.iter().map(|m| &m.inner).collect())
            .await
    }

    pub async fn del_music(
        &self,
        music_list: &MusicList,
        ids: Vec<i64>,
    ) -> Result<(), anyhow::Error> {
        self.inner.del_music(music_list, ids).await
    }

    pub async fn reorder_music(
        &self,
        music_list: &MusicList,
        new_index: Vec<i64>,
        old_musics_in_order: &Vec<MusicW>,
    ) -> Result<(), anyhow::Error> {
        self.inner
            .reorder_music(
                music_list,
                new_index,
                &old_musics_in_order.iter().map(|m| &m.inner).collect(),
            )
            .await
    }

    pub async fn read_music(&self, music_list: &MusicList) -> Result<Vec<MusicW>, anyhow::Error> {
        Ok(self
            .inner
            .read_music(music_list)
            .await?
            .into_iter()
            .map(|m| m.into())
            .collect())
    }

    pub async fn change_music_default_source(
        &self,
        music_list: &MusicList,
        ids: Vec<i64>,
        default_sources: Vec<String>,
    ) -> Result<(), anyhow::Error> {
        self.inner
            .change_music_default_source(music_list, ids, default_sources)
            .await
    }

    pub async fn read_music_data(&self, source: &str) -> Result<Vec<MusicW>, anyhow::Error> {
        Ok(self
            .inner
            .read_music_data(source)
            .await?
            .into_iter()
            .map(|m| m.into())
            .collect())
    }

    pub async fn change_music_data(
        &self,
        musics: Vec<MusicW>,
        infos: Vec<MusicInfo>,
    ) -> Result<(), anyhow::Error> {
        self.inner
            .change_music_data(&musics.iter().map(|m| &m.inner).collect(), infos)
            .await
    }

    pub async fn clean_unused_music_data(&self) -> Result<(), anyhow::Error> {
        self.inner.clean_unused_music_data().await
    }
}

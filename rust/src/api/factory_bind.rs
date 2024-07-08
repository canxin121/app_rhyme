use flutter_rust_bridge::frb;
use music_api::{
    filter::{MusicFilter, MusicFuzzFilter},
    AggregatorOnlineFactory, Music, MusicAggregator, MusicInfo, MusicListInfo, OnlineFactory,
    SqlFactory,
};
use rayon::iter::{IntoParallelIterator, IntoParallelRefIterator, ParallelIterator as _};

use super::type_bind::{MusicAggregatorW, MusicListW, MusicW};

#[frb]
pub struct AggregatorOnlineFactoryW();

impl AggregatorOnlineFactoryW {
    pub async fn search_music_aggregator(
        aggregators: Vec<MusicAggregatorW>,
        sources: &[String],
        content: &str,
        page: u32,
        limit: u32,
        filter: Option<MusicFuzzFilter>,
    ) -> Result<Vec<MusicAggregatorW>, anyhow::Error> {
        let aggregators = aggregators
            .into_par_iter()
            .map(|a| a.get_inner())
            .collect::<Vec<MusicAggregator>>();
        let mut factory = AggregatorOnlineFactory { aggregators };
        factory
            .search_music_aggregator(
                sources,
                content,
                page,
                limit,
                filter
                    .as_ref()
                    .map(|f| f as &(dyn MusicFilter + Send + Sync)),
            )
            .await?;

        let aggregators: Vec<MusicAggregatorW> = factory
            .aggregators
            .into_par_iter()
            .map(|a| MusicAggregatorW::new(a))
            .collect();

        Ok(aggregators)
    }
}

#[frb]
pub struct OnlineFactoryW();

impl OnlineFactoryW {
    pub async fn search_musiclist(
        sources: Vec<String>,
        content: &str,
        page: u32,
        limit: u32,
    ) -> Result<Vec<MusicListW>, anyhow::Error> {
        Ok(
            OnlineFactory::search_musiclist(sources, content, page, limit)
                .await?
                .into_par_iter()
                .map(|m| MusicListW::new(m))
                .collect(),
        )
    }
    pub async fn get_musiclist_from_share(
        share_url: &str,
    ) -> Result<(MusicListW, Vec<MusicAggregatorW>), anyhow::Error> {
        let (ml, mas) = OnlineFactory::get_musiclist_from_share(share_url).await?;
        Ok((
            MusicListW::new(ml),
            mas.into_par_iter()
                .map(|m| MusicAggregatorW::new(m))
                .collect(),
        ))
    }
}

#[frb]
pub struct SqlFactoryW();
impl SqlFactoryW {
    pub async fn init_from_path(filepath: &str) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::init_from_path(filepath).await?)
    }
    pub async fn shutdown() -> Result<(), anyhow::Error> {
        Ok(SqlFactory::shutdown().await?)
    }
    pub async fn clean_unused_music_data() -> Result<(), anyhow::Error> {
        Ok(SqlFactory::clean_unused_music_data().await?)
    }
    pub async fn read_music_data(source: &str) -> Result<Vec<MusicW>, anyhow::Error> {
        Ok(SqlFactory::read_music_data(source)
            .await?
            .into_par_iter()
            .map(|m| MusicW::new(m))
            .collect())
    }
    pub async fn create_musiclist(
        music_list_infos: &Vec<MusicListInfo>,
    ) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::create_musiclist(music_list_infos).await?)
    }

    pub async fn change_musiclist_info(
        old: &Vec<MusicListInfo>,
        new: &Vec<MusicListInfo>,
    ) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::change_musiclist_info(old, new).await?)
    }

    pub async fn get_all_musiclists() -> Result<Vec<MusicListW>, anyhow::Error> {
        Ok(SqlFactory::get_all_musiclists()
            .await?
            .into_par_iter()
            .map(|m| MusicListW::new(m))
            .collect())
    }

    pub async fn del_musiclist(musiclist_names: &[String]) -> Result<(), anyhow::Error> {
        let musiclist_names_refs: Vec<&str> =
            musiclist_names.par_iter().map(|s| s.as_str()).collect();
        Ok(SqlFactory::del_musiclist(&musiclist_names_refs).await?)
    }

    pub async fn add_musics(
        musics_list_name: &str,
        musics: &Vec<MusicAggregatorW>,
    ) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::add_musics(
            musics_list_name,
            &musics.par_iter().map(|m| m.get_ref()).collect(),
        )
        .await?)
    }

    pub async fn del_musics(music_list_name: &str, ids: Vec<i64>) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::del_musics(music_list_name, ids).await?)
    }

    pub async fn replace_musics(
        music_list_name: &str,
        ids: Vec<i64>,
        musics: Vec<MusicAggregatorW>,
    ) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::replace_musics(
            music_list_name,
            ids,
            musics.into_par_iter().map(|m| m.get_inner()).collect(),
        )
        .await?)
    }

    pub async fn reorder_musics(
        music_list_name: &str,
        new_full_index: &[i64],
        full_ids_in_order: &[i64],
    ) -> Result<(), anyhow::Error> {
        Ok(SqlFactory::reorder_musics(music_list_name, new_full_index, full_ids_in_order).await?)
    }

    pub async fn get_all_musics(
        musiclist_info: &MusicListInfo,
    ) -> Result<Vec<MusicAggregatorW>, anyhow::Error> {
        Ok(SqlFactory::get_all_musics(musiclist_info)
            .await?
            .into_par_iter()
            .map(|m| MusicAggregatorW::new(m))
            .collect())
    }

    pub async fn get_music_by_id(
        music_list_info: &MusicListInfo,
        id: i64,
        sources: &[String],
    ) -> Result<MusicAggregatorW, anyhow::Error> {
        let sources_refs: Vec<&str> = sources.par_iter().map(|s| s.as_str()).collect();
        Ok(MusicAggregatorW::new(
            SqlFactory::get_music_by_id(music_list_info, id, &sources_refs).await?,
        ))
    }

    pub async fn change_music_default_source(
        music_list_name: &str,
        ids: Vec<i64>,
        new_default_sources: Vec<String>,
    ) -> Result<(), anyhow::Error> {
        Ok(
            SqlFactory::change_music_default_source(music_list_name, ids, new_default_sources)
                .await?,
        )
    }

    pub async fn change_music_info(
        musics: Vec<MusicW>,
        new_infos: Vec<MusicInfo>,
    ) -> Result<(), anyhow::Error> {
        let musics_refs: Vec<Music> = musics.into_par_iter().map(|m| m.get_inner()).collect();
        Ok(SqlFactory::change_music_info(&musics_refs, new_infos).await?)
    }
}

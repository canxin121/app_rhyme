#![allow(unused_variables)]

use std::fmt::Display;

use flutter_rust_bridge::frb;
use futures::future::join_all;
use music_api::Quality;
use rayon::iter::{IntoParallelIterator, ParallelIterator as _};
use serde::{Deserialize, Serialize};

#[frb]
pub struct MusicAggregatorW(music_api::MusicAggregator);
impl Display for MusicAggregatorW {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

#[frb]
impl Clone for MusicAggregatorW {
    #[frb(sync)]
    fn clone(&self) -> Self {
        Self(self.0.clone_())
    }
}

impl MusicAggregatorW {
    #[frb(ignore)]
    pub(crate) fn new(music_aggregator: music_api::MusicAggregator) -> Self {
        MusicAggregatorW(music_aggregator)
    }
    // 获取MusicAggregator的引用
    #[frb(ignore)]
    pub(crate) fn get_ref(&self) -> &music_api::MusicAggregator {
        &self.0
    }
    // 获取MusicAggregator的可变引用
    #[frb(ignore)]
    pub(crate) fn get_mut_ref(&mut self) -> &mut music_api::MusicAggregator {
        &mut self.0
    }
    #[frb(ignore)]
    pub(crate) fn get_inner(self) -> music_api::MusicAggregator {
        self.0
    }
    #[frb(sync)]
    pub fn to_string(&self) -> String {
        self.0.to_string()
    }
    // 此处的id为自定义歌单中的id，是借由sql构造时传入的，与音乐平台无关的值
    #[frb(sync)]
    pub fn get_music_id(&self) -> i64 {
        self.0.get_music_id()
    }

    // 插入一个新的源的Music
    pub async fn add_music(&mut self, music: MusicW) -> Result<(), anyhow::Error> {
        self.0.add_music(music.0).await
    }

    // 判断一个Music是否属于此MusicAggregator
    #[frb(sync)]
    pub fn belong_to(&self, music: &MusicW) -> bool {
        self.0.belong_to(&music.0)
    }

    // 判断一个Music是否符合过滤器
    #[frb(sync)]
    pub fn match_filter(&self, filter: &music_api::filter::MusicFuzzFilter) -> bool {
        self.0.match_filter(filter)
    }

    // 设置默认来源
    pub async fn set_default_source(&mut self, source: &str) -> Result<(), anyhow::Error> {
        self.0.set_default_source(source).await
    }
    // 获取所有可用的源
    #[frb(sync)]
    pub fn get_available_sources(&self) -> Vec<String> {
        self.0.get_available_sources()
    }

    // 获取默认使用的源
    #[frb(sync)]
    pub fn get_default_source(&self) -> String {
        self.0.get_default_source()
    }

    // 获取默认源的Music
    #[frb(sync)]
    pub fn get_default_music(&self) -> MusicW {
        MusicW(self.0.get_default_music().clone())
    }

    // 获取对应源的Music
    // 为了便于不同场景下的储存，我们认为get_music是可以改变自身
    pub async fn get_music(&mut self, source: &str) -> Option<MusicW> {
        let music = self.0.get_music(&source).await?;
        return Some(MusicW(music.clone()));
    }

    // 获取所有可用的Music
    #[frb(sync)]
    pub fn get_all_musics(&self) -> Vec<MusicW> {
        self.0
            .get_all_musics()
            .into_par_iter()
            .map(|x| MusicW(x.clone()))
            .collect()
    }

    // 获取所有拥有的Music的实例，而非引用
    #[frb(sync)]
    pub fn get_all_musics_owned(&self) -> Vec<MusicW> {
        self.0
            .get_all_musics_owned()
            .into_par_iter()
            .map(|x| MusicW(x))
            .collect()
    }

    // 获取指定的Music
    pub async fn fetch_musics(
        &mut self,
        sources: Vec<String>,
    ) -> Result<Vec<MusicW>, anyhow::Error> {
        let musics = self.0.fetch_musics(sources).await?;
        return Ok(musics.into_par_iter().map(|x| MusicW(x.clone())).collect());
    }

    // 获取歌曲的歌词
    pub async fn fetch_lyric(&self) -> Result<String, anyhow::Error> {
        let lyric = self.0.fetch_lyric().await?;
        return Ok(lyric);
    }

    // 获取歌曲的专辑及其中的歌曲
    // 目前支持的平台均是一次性获取到所有歌曲，不必返回MusicList Trait Object
    // 这里的page，limit并不能完全保证所有平台都遵循，可能直接返回全部
    pub async fn fetch_album(
        &self,
        page: u32,
        limit: u32,
    ) -> Result<(MusicListW, Vec<MusicAggregatorW>), anyhow::Error> {
        let (list, aggs) = self.0.fetch_album(page, limit).await?;
        return Ok((
            MusicListW(list),
            aggs.into_par_iter().map(|x| MusicAggregatorW(x)).collect(),
        ));
    }
}

#[frb]
pub struct MusicW(music_api::Music);
impl Display for MusicW {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}
impl MusicW {
    #[frb(ignore)]
    pub(crate) fn new(music: music_api::Music) -> Self {
        MusicW(music)
    }
    #[frb(ignore)]
    // 获取Music的实例
    pub(crate) fn get_inner(self) -> music_api::Music {
        self.0
    }

    #[frb(sync)]
    pub fn to_string(&self) -> String {
        self.0.to_string()
    }

    // 常量用于区分音乐源
    #[frb(sync)]
    pub fn source(&self) -> String {
        self.0.source().to_string()
    }
    // 获取音乐的信息
    #[frb(sync)]
    pub fn get_music_info(&self) -> music_api::MusicInfo {
        self.0.get_music_info()
    }
    // 获取额外的信息
    #[frb(sync)]
    pub fn get_extra_info(&self, quality: &music_api::Quality) -> String {
        self.0.get_extra_info(quality)
    }
    // 用于sql储存唯一索引键值，k指储存的列名，v指本歌曲对应列的值
    #[frb(sync)]
    pub fn get_primary_kv(&self) -> (String, String) {
        self.0.get_primary_kv()
    }
    // 获取歌词
    pub async fn fetch_lyric(&self) -> Result<String, anyhow::Error> {
        self.0.fetch_lyric().await
    }
    // 获取album和其中的所有歌曲
    pub async fn fetch_album(
        &self,
        page: u32,
        limit: u32,
    ) -> Result<(MusicListW, Vec<MusicAggregatorW>), anyhow::Error> {
        let (list, aggs) = self.0.fetch_album(page, limit).await?;
        return Ok((
            MusicListW(list),
            aggs.into_par_iter().map(|x| MusicAggregatorW(x)).collect(),
        ));
    }
}

#[frb]
pub struct MusicListW(music_api::MusicList);

impl Display for MusicListW {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}
impl MusicListW {
    #[frb(ignore)]
    pub(crate) fn new(music_list: music_api::MusicList) -> Self {
        MusicListW(music_list)
    }

    #[frb(ignore)]
    pub(crate) fn get_ref(&self) -> &music_api::MusicList {
        &self.0
    }

    #[frb(ignore)]
    pub(crate) fn get_mut_ref(&mut self) -> &mut music_api::MusicList {
        &mut self.0
    }

    #[frb(sync)]
    pub fn to_string(&self) -> String {
        self.0.to_string()
    }

    #[frb(sync)]
    pub fn source(&self) -> String {
        self.0.source()
    }
    #[frb(sync)]
    pub fn get_musiclist_info(&self) -> music_api::MusicListInfo {
        self.0.get_musiclist_info()
    }

    pub async fn get_music_aggregators(
        &self,
        page: u32,
        limit: u32,
    ) -> Result<Vec<MusicAggregatorW>, anyhow::Error> {
        let aggs = self.0.get_music_aggregators(page, limit).await?;
        return Ok(aggs.into_par_iter().map(|x| MusicAggregatorW(x)).collect());
    }

    pub async fn fetch_all_music_aggregators(
        &self,
        pages_per_batch: u32,
        limit: u32,
        with_lyric: bool,
    ) -> Result<Vec<MusicAggregatorW>, anyhow::Error> {
        let mut all_aggregators = Vec::new();
        let mut page = 1;
        if self.source() == "Local" {
            all_aggregators.append(&mut self.get_music_aggregators(page, limit).await?);
        } else {
            loop {
                let mut fetch_futures = Vec::new();
                for _ in 0..pages_per_batch {
                    fetch_futures.push(self.get_music_aggregators(page, limit));
                    page += 1;
                }

                let results: Vec<Result<Vec<MusicAggregatorW>, anyhow::Error>> =
                    join_all(fetch_futures).await;

                let mut all_empty = true;
                for result in results {
                    match result {
                        Ok(aggs) => {
                            if !aggs.is_empty() {
                                all_empty = false;
                                all_aggregators.extend(aggs);
                            }
                        }
                        Err(err) => return Err(err),
                    }
                }

                if all_empty {
                    break;
                }
            }
        }
        if with_lyric {
            let futures = all_aggregators.iter_mut().map(|agg| async {
                let _ = agg.fetch_lyric();
            });
            futures::future::join_all(futures).await;
        }
        Ok(all_aggregators)
    }
}

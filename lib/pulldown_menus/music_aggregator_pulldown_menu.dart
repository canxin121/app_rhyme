import 'package:app_rhyme/pulldown_menus/items/music_aggregator.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

Future<void> showMusicAggregatorMenu(
  BuildContext context,
  MusicAggregator musicAgg,
  bool isDesktop,
  Rect position, {
  Playlist? playlist,
  int index = -1,
}) async {
  var defaultMusic = getMusicAggregatorDefaultMusic(musicAgg);
  if (defaultMusic == null) {
    LogToast.error("显示菜单", "显示菜单失败: 无默认音乐",
        "[showMusicAggregatorMenu] failed to show, no default music.");
    return;
  }
  List<dynamic> menuItems;

  if (index == -1) {
    bool hasCache = false;
    hasCache = await hasCacheMusic(
        name: musicAgg.name,
        artists: musicAgg.artist,
        customCacheRoot: globalConfig.storageConfig.customCacheRoot,
        documentFolder: globalDocumentPath);
    if (!context.mounted) return;
    menuItems = _musicAggregetorPullDownItems(
        context, playlist, musicAgg, defaultMusic, hasCache, isDesktop);
  } else {
    menuItems =
        _playinglistItems(context, index, musicAgg, defaultMusic, isDesktop);
  }

  List<PullDownMenuEntry> items = [
    PullDownMenuHeader(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      leading: imageWithCache(defaultMusic.getCover(size: 250),
          height: 50, width: 50),
      title: defaultMusic.name,
      subtitle: defaultMusic.artists.map((e) => e.name).join(", "),
    ),
    const PullDownMenuDivider.large(),
    ...menuItems,
  ];
  showPullDownMenu(context: context, items: items, position: position);
}

List<dynamic> _playinglistItems(BuildContext context, int index,
    MusicAggregator musicAgg, Music defaultMusic, bool isDesktop) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        removeMusicAggFromPlaylistPullDownItem(index),
        addMusicToPlaylistPullDownItem(context, musicAgg),
        createNewPlaylistFromMusicAggPullDownItem(context, musicAgg),
      ],
    ),
    // 查看专辑
    viewMusicAlbumPullDownItem(context, defaultMusic, isDesktop),
    // 查看歌手专辑
    viewArtistAlbumPullDownItem(context, defaultMusic, isDesktop),
    // 查看歌手单曲
    viewArtistMusicAggregatorsPullDownItem(context, defaultMusic, isDesktop),
    // 导出歌曲Json
    exportMusicAggregatorsJsonPullDownItem(context, musicAgg),
  ];
}

List<dynamic> _musicAggregetorPullDownItems(
    BuildContext context,
    Playlist? playlist,
    MusicAggregator musicAgg,
    Music defaultMusic,
    bool hasCache,
    bool isDesktop) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        // 保存到歌单
        addMusicToPlaylistPullDownItem(context, musicAgg),
        // 创建新歌单
        createNewPlaylistFromMusicAggPullDownItem(context, musicAgg),
        // 查看详情 or 编辑信息
        showOrEditMusicAggPullDownItem(context, defaultMusic)
      ],
    ),
    // 缓存歌曲 or 删除缓存
    musicCachePullDownItem(musicAgg, hasCache),
    if (playlist != null && playlist.fromDb)
      // 从歌单删除
      deleteMusicAggFromDbPlaylistPullDownItem(context, musicAgg, playlist),
    if (playlist != null && playlist.fromDb)
      // 设为歌单封面
      setMusicCoverAsPlaylistCoverPullDownItem(playlist, defaultMusic),
    // 查看专辑
    viewMusicAlbumPullDownItem(context, defaultMusic, isDesktop),
    // 查看歌手专辑
    viewArtistAlbumPullDownItem(context, defaultMusic, isDesktop),
    // 查看歌手单曲
    viewArtistMusicAggregatorsPullDownItem(context, defaultMusic, isDesktop),
    // 导出歌曲Json
    exportMusicAggregatorsJsonPullDownItem(context, musicAgg),
  ];
}

import 'package:app_rhyme/pulldown_menus/items/music_aggregators.dart';
import 'package:app_rhyme/pulldown_menus/items/playlist.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

void showMusicPlaylistSmartMenu(BuildContext context, Playlist playlist,
    Rect position, bool isDesktop, bool inPlaylist,
    {List<MusicAggregator>? musicAggs,
    PagingController<int, MusicAggregator>? musicAggPageController}) {
  showPullDownMenu(
    position: position,
    context: context,
    items: [
      PullDownMenuHeader(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        leading: imageWithCache(
          playlist.getCover(size: 250),
          width: 100,
          height: 100,
        ),
        title: playlist.name,
        subtitle: playlist.summary,
      ),
      const PullDownMenuDivider.large(),
      ...musicPlaylistMenuSmartItems(context, playlist, isDesktop, inPlaylist,
          musicAggs: musicAggs, musicAggPageController: musicAggPageController),
    ],
  );
}

List<PullDownMenuEntry> musicPlaylistMenuSmartItems(
    BuildContext context, Playlist? playlist, bool isDesktop, bool inPlaylist,
    {List<MusicAggregator>? musicAggs,
    PagingController<int, MusicAggregator>? musicAggPageController,
    Future<void> Function()? fetchAllMusicAggregators}) {
  return [
    if (playlist != null)
      PullDownMenuActionsRow.medium(
        items: [
          // 编辑信息 or 查看详情
          viewDetailsorEditPlaylistMenuItem(context, playlist),
          // 保存歌单
          if (!playlist.fromDb) savePlaylistMenuItem(context, playlist),
          // 删除歌单
          if (playlist.fromDb)
            deletePlaylistMenuItem(context, playlist, inPlaylist),
          // 保存歌曲
          saveMuiscAggregatorsOfPlaylistMenuItem(context, playlist),
        ],
      ),
    if (fetchAllMusicAggregators != null)
      // 加载所有音乐
      fetchAllMusicAggregatorsPullDownMenuItem(fetchAllMusicAggregators),
    // 编辑订阅
    if (playlist != null && playlist.fromDb)
      editSubscriptionsMenuItem(context, playlist),
    // 更新订阅
    if (playlist != null && playlist.fromDb)
      updateSubscriptionsMenuItem(context, playlist),
    // 导入歌曲Json
    if (playlist != null && playlist.fromDb)
      importMusicAggregatorJsonMenuItem(context, playlist),
    if (playlist != null)
      // 导出歌单Json
      exportPlaylistsJsonMenuItem(context, playlist),
    // 删除所有音乐缓存
    if (musicAggs != null || musicAggPageController != null)
      cacheAllMusicMenuItem(context, musicAggs, musicAggPageController),
    // 删除所有音乐缓存
    if (musicAggs != null || musicAggPageController != null)
      deleteAllMusicCacheMenuItem(context, musicAggs, musicAggPageController),
    // 歌曲排序
    if ((musicAggs != null || musicAggPageController != null) &&
        playlist != null &&
        playlist.fromDb)
      musicAggregatorReorderMenuItem(
          context, playlist, musicAggs, musicAggPageController, isDesktop),
    // 歌曲多选
    if (musicAggs != null || musicAggPageController != null)
      musicAggregatorMultiSelectMenuItem(
          context, playlist, musicAggs, musicAggPageController, isDesktop),
  ];
}

@immutable
class MusicPlaylistSmartPullDownMenu extends StatelessWidget {
  const MusicPlaylistSmartPullDownMenu({
    super.key,
    required this.builder,
    required this.isDesktop,
    this.musicAggs,
    this.playlist,
    this.inPlaylist = false,
    this.fetchAllMusicAggregators,
    this.musicAggPageController,
  });

  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;
  final List<MusicAggregator>? musicAggs;
  final PagingController<int, MusicAggregator>? musicAggPageController;
  final Future<void> Function()? fetchAllMusicAggregators;
  final Playlist? playlist;
  final bool inPlaylist;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        ...musicPlaylistMenuSmartItems(context, playlist, isDesktop, inPlaylist,
            musicAggs: musicAggs,
            fetchAllMusicAggregators: fetchAllMusicAggregators,
            musicAggPageController: musicAggPageController),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

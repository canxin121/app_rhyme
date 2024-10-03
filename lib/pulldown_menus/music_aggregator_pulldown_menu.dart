import 'package:app_rhyme/dialogs/music_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
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
        music: defaultMusic, documentFolder: globalDocumentPath);
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
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            globalAudioHandler.removeAt(index);
          },
          title: '移除',
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => addMusicsToPlayList(context, [musicAgg]),
          title: '添加到歌单',
          icon: CupertinoIcons.add,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => createNewMusicListFromMusics(context, [musicAgg]),
          title: '创建新歌单',
          icon: CupertinoIcons.add_circled,
        ),
      ],
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () {
        var defaultMusic = getMusicAggregatorDefaultMusic(musicAgg);
        if (defaultMusic == null) {
          LogToast.error("查看详情失败", "无法查看详情: 未找到音乐信息",
              "[MusicContainer] Failed to view music info: Cannot find music info");
          return;
        }
        showMusicInfoDialog(context, defaultMusicInfo: defaultMusic);
      },
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => viewMusicAlbum(context, defaultMusic, isDesktop),
      title: '查看专辑',
      icon: CupertinoIcons.music_albums,
    ),
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
        /// 在线歌曲
        if (!musicAgg.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () => createNewMusicListFromMusics(context, [musicAgg]),
            title: '创建新歌单',
            icon: CupertinoIcons.add_circled,
          ),

        /// 在线歌曲
        if (!musicAgg.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () => addMusicsToPlayList(context, [musicAgg]),
            title: '添加到歌单',
            icon: CupertinoIcons.add,
          ),

        /// 数据库内歌曲
        if (musicAgg.fromDb && playlist != null)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () => deleteMusicAggsFromDbPlaylist(
              [musicAgg],
              playlist,
            ),
            title: '从歌单删除',
            icon: CupertinoIcons.delete,
          ),

        /// 通用
        if (hasCache)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () => delMusicAggregatorCache(musicAgg,
                showToastWhenNoMsuicCache: true),
            title: '删除缓存',
            icon: CupertinoIcons.delete_solid,
          )
        else
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () => cacheMusicContainer(MusicContainer(musicAgg)),
            title: '缓存音乐',
            icon: CupertinoIcons.cloud_download,
          ),

        /// 数据库内歌曲
        if (musicAgg.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () async {
              var music = getMusicAggregatorDefaultMusic(musicAgg);
              if (music == null) {
                LogToast.error("编辑信息失败", "无法编辑信息: 未找到音乐信息",
                    "[MusicContainer] Failed to edit music info: Cannot find music info");
                return;
              }
              music = await editMusicInfoToDb(context, music);
            },
            title: '编辑信息',
            icon: CupertinoIcons.pencil,
          ),
      ],
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => showMusicInfoDialog(context, defaultMusicInfo: defaultMusic),
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => viewMusicAlbum(context, defaultMusic, isDesktop),
      title: '查看专辑',
      icon: CupertinoIcons.music_albums,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => addMusicsToPlayList(context, [musicAgg]),
      title: '添加到歌单',
      icon: CupertinoIcons.add,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => createNewMusicListFromMusics(context, [musicAgg]),
      title: '创建新歌单',
      icon: CupertinoIcons.add_circled,
    ),
    if (playlist != null && playlist.fromDb)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () => setMusicCoverAsPlaylistCover(defaultMusic, playlist),
        title: '用作歌单的封面',
        icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      ),
  ];
}

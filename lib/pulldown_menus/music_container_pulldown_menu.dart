import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 有三种使用场景: 1. 本地歌单的歌曲 2. 在线的歌曲 3. 播放列表
// 区分:
// 1. 本地歌单的歌曲: musicListW != null && index == -1
// 2. 在线的歌曲: musicListW == null && index == -1
// 3. 播放列表的歌曲: musicListW == null && index != -1

// 可执行的操作:
// 1. 本地歌单的歌曲:查看详情, 缓存 or 取消缓存, 从歌单删除, 编辑信息, 搜索匹配信息,
// 查看专辑, 添加到歌单, 创建新歌单, 用作歌单的封面
// 2. 在线的歌曲:查看详情, 添加到歌单, 创建新歌单,  查看专辑
// 3. 播放列表的歌曲:查看详情, 从播放列表删除, , 查看专辑,添加到歌单, 创建新歌单

Future<void> showMusicContainerMenu(
  BuildContext context,
  MusicContainer musicContainer,
  bool isDesktop,
  Rect position, {
  MusicListW? musicList,
  int index = -1,
}) async {
  List<dynamic> menuItems;

  if (musicList == null && index == -1) {
    // 在线的歌曲
    menuItems = onlineMusicContainerItems(context, musicContainer, isDesktop);
  } else if (musicList == null && index != -1) {
    // 播放列表的歌曲
    menuItems = _playlistItems(context, index, musicContainer, isDesktop);
  } else {
    // 本地歌单的音乐
    bool hasCache = await musicContainer.hasCache();
    if (!context.mounted) return;
    menuItems = localMusicContainerItems(
        context, musicList!, musicContainer, hasCache, isDesktop);
  }

  List<PullDownMenuEntry> items = [
    PullDownMenuHeader(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      leading: imageCacheHelper(musicContainer.info.artPic),
      title: musicContainer.info.name,
      subtitle: musicContainer.info.artist.join(", "),
    ),
    const PullDownMenuDivider.large(),
    ...menuItems,
  ];
  showPullDownMenu(context: context, items: items, position: position);
}

List<dynamic> _playlistItems(BuildContext context, int index,
    MusicContainer musicContainer, bool isDesktop) {
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
          onTap: () => addMusicsToMusicList(context, [musicContainer]),
          title: '添加到歌单',
          icon: CupertinoIcons.add,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => createNewMusicListFromMusics(context, [musicContainer]),
          title: '创建新歌单',
          icon: CupertinoIcons.add_circled,
        ),
      ],
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => showDetailsDialog(context, musicContainer),
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => viewMusicAlbum(context, musicContainer, isDesktop),
      title: '查看专辑',
      icon: CupertinoIcons.music_albums,
    ),
  ];
}

List<dynamic> onlineMusicContainerItems(
    BuildContext context, MusicContainer musicContainer, bool isDesktop) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => createNewMusicListFromMusics(context, [musicContainer]),
          title: '创建新歌单',
          icon: CupertinoIcons.add_circled,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => addMusicsToMusicList(context, [musicContainer]),
          title: '添加到歌单',
          icon: CupertinoIcons.add,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => viewMusicAlbum(context, musicContainer, isDesktop),
          title: '查看专辑',
          icon: CupertinoIcons.music_albums,
        ),
      ],
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => showDetailsDialog(context, musicContainer),
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
  ];
}

List<dynamic> localMusicContainerItems(
    BuildContext context,
    MusicListW musicList,
    MusicContainer musicContainer,
    bool hasCache,
    bool isDesktop) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => deleteMusicsFromLocalMusicList(
              context, [musicContainer], musicList),
          title: '从歌单删除',
          icon: CupertinoIcons.delete,
        ),
        if (hasCache)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () =>
                delMusicCache(musicContainer, showToastWhenNoMsuicCache: true),
            title: '删除缓存',
            icon: CupertinoIcons.delete_solid,
          )
        else
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () => cacheMusic(musicContainer),
            title: '缓存音乐',
            icon: CupertinoIcons.cloud_download,
          ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () => editMusicInfo(context, musicContainer),
          title: '编辑信息',
          icon: CupertinoIcons.pencil,
        ),
      ],
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => showDetailsDialog(context, musicContainer),
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => viewMusicAlbum(context, musicContainer, isDesktop),
      title: '查看专辑',
      icon: CupertinoIcons.music_albums,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => addMusicsToMusicList(context, [musicContainer]),
      title: '添加到歌单',
      icon: CupertinoIcons.add,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => createNewMusicListFromMusics(context, [musicContainer]),
      title: '创建新歌单',
      icon: CupertinoIcons.add_circled,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => setMusicPicAsMusicListCover(musicContainer, musicList),
      title: '用作歌单的封面',
      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
    ),
  ];
}

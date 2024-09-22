import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/pages/local_playlist_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 有三种使用场景: 1. 本地歌单 2. 在线歌单
// 区分:
// 1. 本地歌单的歌曲: from_db == true
// 2. 在线的歌曲: from_db == false

// 可执行的操作:
// 1. 本地歌单的歌曲:查看详情, 编辑信息, 删除歌单
// 2. 在线的歌曲:查看详情,保存为新增歌单, 添加到已有歌单

void showMusicListMenu(
    BuildContext context, Playlist playlist, Rect position, bool inPlaylist) {
  List<dynamic> menuItems;

  if (playlist.fromDb) {
    // 本地歌单
    menuItems = localMusiclistItems(context, playlist, inPlaylist);
  } else {
    // 在线的歌单
    menuItems = onlineMusicListItems(context, playlist);
  }

  List<PullDownMenuEntry> items = [
    PullDownMenuHeader(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      leading: imageWithCache(playlist.cover),
      title: playlist.name,
      subtitle: playlist.summary,
    ),
    const PullDownMenuDivider.large(),
    ...menuItems,
  ];

  showPullDownMenu(
    position: position,
    context: context,
    items: items,
  );
}

// 查看详情, 编辑信息, 删除歌单
List<PullDownMenuEntry> localMusiclistItems(
    BuildContext context, Playlist playlist, bool inPlaylist) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            showMusicListInfoDialog(context,
                defaultPlaylist: playlist, readonly: true);
          },
          title: '查看详情',
          icon: CupertinoIcons.photo,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            await editPlaylistListInfo(context, playlist);
          },
          title: '编辑信息',
          icon: CupertinoIcons.pencil,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            try {
              await playlist.delFromDb();
              if (inPlaylist) {
                if (isDesktop() ||
                    (context.mounted &&
                        isTablet(context) &&
                        isWidthGreaterThanHeight(context))) {
                  globalNavigatorToPage(const DesktopLocalMusicListGridPage());
                  globalSetNavItemSelected("###AllPlaylist###");
                } else {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
              LogToast.success("删除歌单", "删除歌单成功",
                  "[LocalMusicListItemsPullDown] Succeed to delete music list");
              refreshMusicAggregatorListViewPage();
              refreshPlaylistGridViewPage();
            } catch (e) {
              LogToast.error("删除歌单", "删除歌单失败: $e",
                  "[LocalMusicListItemsPullDown] Failed to delete music list: $e");
            }
          },
          title: '删除歌单',
          icon: CupertinoIcons.delete,
        ),
      ],
    ),
  ];
}

// 查看详情,保存为新增歌单, 添加到已有歌单
List<PullDownMenuEntry> onlineMusicListItems(
    BuildContext context, Playlist playlist) {
  return [
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () {
        showMusicListInfoDialog(context,
            defaultPlaylist: playlist, readonly: true);
      },
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        var newPlaylist =
            await showMusicListInfoDialog(context, defaultPlaylist: playlist);
        if (newPlaylist != null) {
          await saveMusicList(newPlaylist);
        }
      },
      title: '保存为新增歌单',
      icon: CupertinoIcons.add_circled,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        var targetMusicList = await showMusicListSelectionDialog(context);
        if (targetMusicList != null) {
          await addAggsOfMusicListToTargetMusicList(playlist, targetMusicList);
        }
      },
      title: '添加到已有歌单',
      icon: CupertinoIcons.add_circled_solid,
    ),
  ];
}

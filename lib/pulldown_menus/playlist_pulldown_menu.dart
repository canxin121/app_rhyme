import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/reorder_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/dialogs/subscriptions_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

void showPlaylistMenu(BuildContext context, Playlist playlist, Rect position,
    bool isDesktop, bool inPlaylist,
    {List<MusicAggregator>? musicAggs}) {
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
      ...playlistMenuItems(context, playlist, isDesktop, inPlaylist)
    ],
  );
}

List<PullDownMenuEntry> playlistMenuItems(
    BuildContext context, Playlist playlist, bool isDesktop, bool inPlaylist,
    {List<MusicAggregator>? musicAggs}) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            showPlaylistInfoDialog(context,
                defaultPlaylist: playlist, readonly: true);
          },
          title: '查看详情',
          icon: CupertinoIcons.photo,
        ),
        if (!playlist.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () async {
              var newPlaylist = await showPlaylistInfoDialog(context,
                  defaultPlaylist: playlist);
              if (newPlaylist != null) {
                await saveMusicList(newPlaylist, true);
              }
            },
            title: '保存为新增歌单',
            icon: CupertinoIcons.add_circled,
          ),
        if (playlist.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () async {
              await delDbPlaylist(playlist, inPlaylist, isDesktop, context);
            },
            title: '删除歌单',
            icon: CupertinoIcons.delete,
          ),
        if (playlist.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () async {
              await editPlaylistListInfo(context, playlist);
            },
            title: '编辑信息',
            icon: CupertinoIcons.pencil,
          ),
      ],
    ),
    if (playlist.fromDb)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          var subscriptions = await showEditSubscriptionsDialog(
              context: context, subscriptions: playlist.subscription);
          playlist.subscription = subscriptions;
          playlist = await playlist.updateToDb();
        },
        title: '编辑订阅',
        icon: CupertinoIcons.pencil,
      ),
    if (playlist.fromDb)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          var results = await playlist.updateSubscription();
          for (var error in results.errors) {
            LogToast.error("更新订阅'${error.$1}'", "更新失败: ${error.$2}",
                "[LocalMusicListItemsPullDown] Failed to update subscription '${error.$1}': ${error.$2}");
          }
          playlist
              .getMusicsFromDb()
              .then((e) => musicAggregatorListUpdateStreamController.add(e));
          LogToast.success("更新订阅", "更新成功",
              "[LocalMusicListItemsPullDown] Succeed to update subscription");
        },
        title: '更新订阅',
        icon: CupertinoIcons.pencil,
      ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        var targetMusicList = await showMusicListSelectionDialog(context);
        if (targetMusicList != null) {
          await addAggsOfPlayListToTargetMusicList(playlist, targetMusicList);
        }
      },
      title: '添加歌曲到已有歌单',
      icon: CupertinoIcons.add_circled_solid,
    ),
    if (playlist.fromDb)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          await importMusicAggrgegatorJson(context, isDesktop,
              targetPlaylist: playlist);
        },
        title: '导入歌曲Json',
        icon: CupertinoIcons.arrow_uturn_up_circle_fill,
      ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () => exportPlaylistsJson(context, [playlist]),
      title: '导出json文件',
      icon: CupertinoIcons.download_circle_fill,
    ),
    if (musicAggs != null)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          for (var musicAgg in musicAggs) {
            await cacheMusicContainer(MusicContainer(musicAgg));
          }
        },
        title: '缓存歌单所有音乐',
        icon: CupertinoIcons.cloud_download,
      ),
    if (musicAggs != null)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          for (var musicContainer in musicAggs) {
            await delMusicAggregatorCache(musicContainer, showToast: false);
          }
          LogToast.success("删除所有音乐缓存", "删除所有音乐缓存成功",
              "[LocalMusicListChoicMenu] Successfully deleted all music caches");
        },
        title: '删除所有音乐缓存',
        icon: CupertinoIcons.delete,
      ),
    if (musicAggs != null)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () {
          if (isDesktop) {
            globalDesktopNavigatorToPage(
                MuiscAggregatorReorderPage(
                  musicAggregators: musicAggs,
                  playlist: playlist,
                  isDesktop: true,
                ),
                replace: false);
          } else {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MuiscAggregatorReorderPage(
                  musicAggregators: musicAggs,
                  playlist: playlist,
                  isDesktop: false,
                ),
              ),
            );
          }
        },
        title: "歌曲排序",
        icon: CupertinoIcons.sort_up_circle,
      ),
    if (musicAggs != null)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () {
          if (isDesktop) {
            globalDesktopNavigatorToPage(
                MusicAggregatorMultiSelectionPage(
                  playlist: playlist,
                  musicAggs: musicAggs,
                  isDesktop: true,
                ),
                replace: false);
          } else {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MusicAggregatorMultiSelectionPage(
                  playlist: playlist,
                  musicAggs: musicAggs,
                  isDesktop: false,
                ),
              ),
            );
          }
        },
        title: "多选操作",
        icon: CupertinoIcons.selection_pin_in_out,
      )
  ];
}

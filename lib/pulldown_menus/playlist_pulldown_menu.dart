import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/reorder_page/music_aggregator.dart';
import 'package:app_rhyme/dialogs/subscriptions_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
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
            showPlaylistDialog(context,
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
              var newPlaylist =
                  await showPlaylistDialog(context, defaultPlaylist: playlist);
              if (newPlaylist == null || !context.mounted) return;
              await saveOnlinePlaylist(
                context,
                newPlaylist,
              );
            },
            title: '保存歌单',
            icon: CupertinoIcons.add_circled,
          ),
        if (playlist.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () async {
              await delDbPlaylist(playlist, inPlaylist, context);
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
          musicAggrgatorsPageRefreshStreamController.add(playlist.identity);
          LogToast.success("更新订阅", "更新成功",
              "[LocalMusicListItemsPullDown] Succeed to update subscription");
        },
        title: '更新订阅',
        icon: CupertinoIcons.pencil,
      ),
    if (playlist.fromDb)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          await importMusicAggrgegatorJson(context, targetPlaylist: playlist);
        },
        title: '导入歌曲Json',
        icon: CupertinoIcons.arrow_uturn_up_circle_fill,
      ),
    if (!playlist.fromDb)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () {
          saveAggsOfPlayList(context, playlist);
        },
        title: '保存歌曲',
        icon: CupertinoIcons.download_circle_fill,
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
            await delMusicCache(musicContainer, showToast: false);
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
          navigate(
              context,
              MuiscAggregatorReorderPage(
                musicAggregators: musicAggs,
                playlist: playlist,
                isDesktop: isDesktop,
              ),
              isDesktop,
              "");
        },
        title: "歌曲排序",
        icon: CupertinoIcons.sort_up_circle,
      ),
    if (musicAggs != null)
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () {
          navigate(
              context,
              MusicAggregatorMultiSelectionPage(
                playlist: playlist,
                musicAggs: musicAggs,
                isDesktop: isDesktop,
              ),
              isDesktop,
              "");
        },
        title: "多选操作",
        icon: CupertinoIcons.selection_pin_in_out,
      )
  ];
}

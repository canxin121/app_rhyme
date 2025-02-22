import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/common_pages/reorder_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/reorder_page/playlist.dart';
import 'package:app_rhyme/common_comps/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/select_create_playlist_collection_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/subscriptions_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 创建歌单
PullDownMenuItem createPlaylistPullDownItem(BuildContext context,
    {PlaylistCollection? playlistCollection}) {
  return PullDownMenuItem(
    title: '创建歌单',
    icon: CupertinoIcons.add,
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      if (context.mounted) {
        var playlist = await showPlaylistDialog(context);
        if (playlist == null) return;
        if (!context.mounted) return;

        playlistCollection ??=
            await showSelectCreatePlaylistCollectionDialog(context);
        if (playlistCollection == null) return;
        await insertPlaylistToDb(playlist, playlistCollection!.id);
      }
    },
  );
}

/// 打开歌单链接
PullDownMenuItem openPlaylistLinkPullDownItem(
    BuildContext context, bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var url = await showInputPlaylistShareLinkDialog(context);
      if (url != null) {
        try {
          var playlist = await Playlist.getFromShare(share: url);
          if (!context.mounted) return;
          navigate(
              context,
              OnlineMusicAggregatorListViewPage(
                playlist: playlist,
                isDesktop: isDesktop,
              ),
              isDesktop,
              "");
        } catch (e) {
          LogToast.error("打开歌单链接", "打开歌单链接失败: $e",
              "[MusicListGridPageMenu] Failed to open playlist link: $e");
        }
      }
    },
    title: '打开歌单链接',
    icon: CupertinoIcons.link,
  );
}

/// 导入歌单Json
PullDownMenuItem importPlaylistJsonPullDownItem(BuildContext context,
    {PlaylistCollection? playlistCollection}) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      await importPlaylistJson(context, playlistCollection: playlistCollection);
    },
    title: '导入歌单Json',
    icon: CupertinoIcons.link,
  );
}

/// 歌单排序
PullDownMenuItem playlistReorderPullDownItem(
    BuildContext context,
    List<Playlist> playlists,
    bool isDesktop,
    PlaylistCollection playlistCollection) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      if (context.mounted) {
        navigate(
            context,
            PlaylistReorderPage(
              playlists: playlists,
              isDesktop: isDesktop,
              playlistCollection: playlistCollection,
            ),
            isDesktop,
            "");
      }
    },
    title: '歌单排序',
    icon: CupertinoIcons.list_number,
  );
}

///歌单多选
PullDownMenuItem playlistMultiSelectionPullDownItem(
    BuildContext context, List<Playlist> playlists, bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      if (context.mounted) {
        navigate(
            context,
            PlaylistMultiSelectionPage(
                playlists: playlists, isDesktop: isDesktop),
            isDesktop,
            "");
      }
    },
    title: '歌单多选',
    icon: CupertinoIcons.selection_pin_in_out,
  );
}

/// 编辑信息 or 查看详情
PullDownMenuItem viewDetailsorEditPlaylistMenuItem(
    BuildContext context, Playlist playlist) {
  if (playlist.fromDb) {
    return PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        await editPlaylistListToDb(context, playlist);
      },
      title: '编辑信息',
      icon: CupertinoIcons.pencil,
    );
  } else {
    return PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () {
        showPlaylistDialog(context, defaultPlaylist: playlist, readonly: true);
      },
      title: '查看详情',
      icon: CupertinoIcons.photo,
    );
  }
}

/// 保存歌单
PullDownMenuItem savePlaylistMenuItem(BuildContext context, Playlist playlist) {
  return PullDownMenuItem(
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
  );
}

/// 删除歌单
PullDownMenuItem deletePlaylistMenuItem(
    BuildContext context, Playlist playlist, bool inPlaylist) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      await delDbPlaylist(playlist, inPlaylist, context);
    },
    title: '删除歌单',
    icon: CupertinoIcons.delete,
  );
}

/// 编辑订阅
PullDownMenuItem editSubscriptionsMenuItem(
    BuildContext context, Playlist playlist) {
  return PullDownMenuItem(
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
  );
}

/// 更新订阅
PullDownMenuItem updateSubscriptionsMenuItem(
    BuildContext context, Playlist playlist) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      if (playlist.subscription == null || playlist.subscription!.isEmpty) {
        LogToast.error("更新订阅", "更新失败: 该歌单没有订阅",
            "[LocalMusicListItemsPullDown] Failed to update subscription: playlist has no subscription");
        return;
      }
      try {
        var results = await playlist.updateSubscription();
        for (var error in results.errors) {
          LogToast.error("更新订阅'${error.$1}'", "更新失败: ${error.$2}",
              "[LocalMusicListItemsPullDown] Failed to update subscription '${error.$1}': ${error.$2}");
        }
        musicAggrgatorsPageRefreshStreamController.add(playlist.identity);
        LogToast.success("更新订阅", "更新成功",
            "[LocalMusicListItemsPullDown] Succeed to update subscription");
      } catch (e) {
        LogToast.error("更新订阅", "更新失败: $e",
            "[LocalMusicListItemsPullDown] Failed to update subscription: $e");
      }
    },
    title: '更新订阅',
    icon: CupertinoIcons.pencil,
  );
}

/// 导入歌曲Json
PullDownMenuItem importMusicAggregatorJsonMenuItem(
    BuildContext context, Playlist playlist) {
  return PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        await importMusicAggrgegatorJson(context, targetPlaylist: playlist);
      },
      title: '导入歌曲Json',
      icon: CupertinoIcons.arrow_uturn_up_circle);
}

/// 保存歌曲
PullDownMenuItem saveMuiscAggregatorsOfPlaylistMenuItem(
    BuildContext context, Playlist playlist) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      saveAggsOfPlayList(context, playlist);
    },
    title: '保存歌曲',
    icon: CupertinoIcons.download_circle,
  );
}

/// 导出歌单Json
PullDownMenuItem exportPlaylistsJsonMenuItem(
    BuildContext context, Playlist playlist) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => exportPlaylistsJson(context, [playlist]),
    title: '导出json文件',
    icon: CupertinoIcons.download_circle,
  );
}

/// 缓存所有音乐
PullDownMenuItem cacheAllMusicMenuItem(
    BuildContext context,
    List<MusicAggregator>? musicAggs,
    PagingController<int, MusicAggregator>? musicAggPageController) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      musicAggs ??= musicAggPageController?.itemList ?? [];
      for (var musicAgg in musicAggs!) {
        await cacheMusicContainer(MusicContainer(musicAgg));
      }
    },
    title: '缓存所有音乐',
    icon: CupertinoIcons.cloud_download,
  );
}

/// 删除所有音乐缓存
PullDownMenuItem deleteAllMusicCacheMenuItem(
    BuildContext context,
    List<MusicAggregator>? musicAggs,
    PagingController<int, MusicAggregator>? musicAggPageController) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      musicAggs ??= musicAggPageController?.itemList ?? [];
      for (var musicContainer in musicAggs!) {
        await delMusicCache(musicContainer, showToast: false);
      }
      LogToast.success("删除所有音乐缓存", "删除所有音乐缓存成功",
          "[LocalMusicListChoicMenu] Successfully deleted all music caches");
    },
    title: '删除所有音乐缓存',
    icon: CupertinoIcons.delete,
  );
}

/// 歌曲排序
PullDownMenuItem musicAggregatorReorderMenuItem(
    BuildContext context,
    Playlist playlist,
    List<MusicAggregator>? musicAggs,
    PagingController<int, MusicAggregator>? musicAggPageController,
    bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      musicAggs ??= musicAggPageController?.itemList ?? [];
      navigate(
          context,
          MuiscAggregatorReorderPage(
            musicAggregators: musicAggs!,
            playlist: playlist,
            isDesktop: isDesktop,
          ),
          isDesktop,
          "");
    },
    title: "歌曲排序",
    icon: CupertinoIcons.sort_up_circle,
  );
}

/// 歌曲多选
PullDownMenuItem musicAggregatorMultiSelectMenuItem(
    BuildContext context,
    Playlist? playlist,
    List<MusicAggregator>? musicAggs,
    PagingController<int, MusicAggregator>? musicAggPageController,
    bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      musicAggs ??= musicAggPageController?.itemList ?? [];
      navigate(
          context,
          MusicAggregatorMultiSelectionPage(
            playlist: playlist,
            musicAggs: musicAggs!,
            isDesktop: isDesktop,
          ),
          isDesktop,
          "");
    },
    title: "歌曲多选",
    icon: CupertinoIcons.selection_pin_in_out,
  );
}

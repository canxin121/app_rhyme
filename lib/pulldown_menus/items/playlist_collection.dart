import 'package:app_rhyme/common_pages/db_playlist_collection_page.dart';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist_collection.dart';
import 'package:app_rhyme/common_pages/reorder_page/playlist_collection.dart';
import 'package:app_rhyme/common_comps/dialogs/playlist_collection_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 创建歌单列表
PullDownMenuItem createPlaylistCollectionPullDownItem(BuildContext context,
    {PlaylistCollection? playlistCollection}) {
  return PullDownMenuItem(
    title: '创建歌单列表',
    icon: CupertinoIcons.add,
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      createPlaylistCollection(context, playlistCollection: playlistCollection);
    },
  );
}

/// 歌单列表多选
PullDownMenuItem playlistCollectionMultiSelectPullDownItem(BuildContext context,
    List<PlaylistCollection> playlistCollections, bool isDesktop) {
  return PullDownMenuItem(
    title: '歌单列表多选',
    icon: CupertinoIcons.selection_pin_in_out,
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      navigate(
          context,
          PlaylistCollectionMultiSelectionPage(
            collections: playlistCollections,
            isDesktop: isDesktop,
          ),
          isDesktop,
          "");
    },
  );
}

/// 歌单列表排序
PullDownMenuItem playlistCollectionReorderPullDownItem(
    BuildContext context, bool isDesktop) {
  return PullDownMenuItem(
    title: "歌单列表排序",
    icon: CupertinoIcons.sort_down,
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var collections = await PlaylistCollection.getFormDb();
      if (!context.mounted) return;
      navigate(
          context,
          PlaylistCollectionReorderPage(
              collections: collections, isDesktop: isDesktop),
          isDesktop,
          "");
    },
  );
}

/// 歌单多选
PullDownMenuItem playlistMultiSelectPullDownItem(
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

/// 编辑歌单列表
PullDownMenuItem editPlaylistCollectionPullDownItem(
    BuildContext context, PlaylistCollection playlistCollection) {
  return PullDownMenuItem(
    title: '编辑歌单列表',
    icon: CupertinoIcons.add,
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var edited = await showPlaylistCollectionDialog(context,
          defaultPlaylistCollection: playlistCollection);
      if (edited == null) return;
      try {
        await edited.updateToDb();
        playlistCollectionUpdateStreamController.add(edited);
      } catch (e) {
        LogToast.error("编辑歌单列表", "编辑歌单列表失败: $e",
            "[MusicListGridPageMenu] Failed to edit music list: $e");
      }
    },
  );
}

/// 删除歌单列表
PullDownMenuItem deletePlaylistCollectionPullDownItem(BuildContext context,
    PlaylistCollection playlistCollection, bool isDesktop) {
  return PullDownMenuItem(
    title: '删除歌单列表',
    icon: CupertinoIcons.add,
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      try {
        await playlistCollection.deleteFromDb();
        playlistCollectionDeleteStreamController.add(playlistCollection.id);

        if (!context.mounted) return;
        if (isDesktop) {
          navigate(context, DbPlaylistCollectionPage(isDesktop: isDesktop),
              isDesktop, "###AllPlaylistCollection###",
              replaceDestkop: true);
        } else {
          popPage(context, isDesktop);
        }
      } catch (e) {
        LogToast.error("删除歌单列表", "删除歌单列表失败: $e",
            "[MusicListGridPageMenu] Failed to delete music list: $e");
      }
    },
  );
}

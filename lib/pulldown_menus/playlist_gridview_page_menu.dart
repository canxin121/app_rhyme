import 'package:app_rhyme/common_pages/db_playlist_collection_page.dart';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/common_pages/reorder_page/playlist.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/dialogs/playlist_collection_dialog.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/dialogs/select_create_playlist_collection_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class PlaylistGridPageMenu extends StatelessWidget {
  const PlaylistGridPageMenu({
    super.key,
    required this.builder,
    required this.playlists,
    required this.isDesktop,
    required this.playlistCollection,
  });
  final List<Playlist> playlists;
  final PlaylistCollection playlistCollection;
  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
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
        ),
        PullDownMenuItem(
          title: '删除歌单列表',
          icon: CupertinoIcons.add,
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            try {
              await playlistCollection.deleteFromDb();
              playlistCollectionDeleteStreamController
                  .add(playlistCollection.id);

              if (!context.mounted) return;
              if (isDesktop) {
                navigate(
                    context,
                    DbPlaylistCollectionPage(isDesktop: isDesktop),
                    isDesktop,
                    "###AllPlaylistCollection###",
                    replaceDestkop: true);
              } else {
                popPage(context, isDesktop);
              }
            } catch (e) {
              LogToast.error("删除歌单列表", "删除歌单列表失败: $e",
                  "[MusicListGridPageMenu] Failed to delete music list: $e");
            }
          },
        ),
        PullDownMenuItem(
          title: '创建歌单',
          icon: CupertinoIcons.add,
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              var playlist = await showPlaylistDialog(context);
              if (playlist == null) return;
              if (!context.mounted) return;
              var playlistCollection =
                  await showSelectCreatePlaylistCollectionDialog(context);
              if (playlistCollection == null) return;
              try {
                await playlist.insertToDb(collectionId: playlistCollection.id);
                playlistCreateStreamController.add(playlist);
              } catch (e) {
                LogToast.error("创建歌单", "创建歌单失败: $e",
                    "[MusicListGridPageMenu] Failed to create music list: $e");
              }
            }
          },
        ),
        PullDownMenuItem(
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
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            await importPlaylistJson(
              context,
            );
          },
          title: '导入歌单Json',
          icon: CupertinoIcons.link,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
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
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              navigate(
                  context,
                  PlaylistMultiSelectionPage(
                      playlists: playlists, isDesktop: isDesktop),
                  isDesktop,
                  "");
            }
          },
          title: '多选操作',
          icon: CupertinoIcons.selection_pin_in_out,
        )
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

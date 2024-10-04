import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/common_pages/reorder_page/playlist.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class MusicListGridPageMenu extends StatelessWidget {
  const MusicListGridPageMenu({
    super.key,
    required this.builder,
    required this.playlists,
    required this.isDesktop,
  });
  final List<Playlist> playlists;
  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              var playlist = await showPlaylistInfoDialog(context);
              if (playlist != null) {
                try {
                  await playlist.insertToDb();
                  Playlist.getFromDb()
                      .then((e) => playlistGridUpdateStreamController.add(e));
                  LogToast.success("创建歌单", "创建歌单成功",
                      "[MusicListGridPageMenu] Successfully created music list");
                } catch (e) {
                  LogToast.error("创建歌单", "创建歌单失败: $e",
                      "[MusicListGridPageMenu] Failed to create music list: $e");
                }
              }
            }
          },
          title: '创建歌单',
          icon: CupertinoIcons.add,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            var url = await showInputPlaylistShareLinkDialog(context);
            if (url != null) {
              try {
                var playlist = await Playlist.getFromShare(share: url);
                if (context.mounted) {
                  globalDesktopNavigatorToPage(
                      OnlineMusicListPage(
                        playlist: playlist,
                        isDesktop: isDesktop,
                      ),
                      replace: false);
                }
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
            await importPlaylistJson(context, true);
          },
          title: '导入歌单Json',
          icon: CupertinoIcons.link,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              globalDesktopNavigatorToPage(
                  PlaylistReorderPage(playlists: playlists, isDesktop: true),
                  replace: false);
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
              var playlists = await Playlist.getFromDb();
              globalDesktopNavigatorToPage(
                  PlaylistMultiSelectionPage(
                      playlists: playlists, isDesktop: true),
                  replace: false);
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

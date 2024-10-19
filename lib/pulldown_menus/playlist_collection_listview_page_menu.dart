import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class PlaylistCollectionPageMenu extends StatelessWidget {
  const PlaylistCollectionPageMenu({
    super.key,
    required this.builder,
    required this.isDesktop,
    required this.playlists,
  });
  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;
  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          title: '创建歌单列表',
          icon: CupertinoIcons.add,
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            createPlaylistCollection(context);
          },
        ),
        PullDownMenuItem(
          title: '创建歌单',
          icon: CupertinoIcons.add,
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            createPlaylist(context);
          },
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
          title: '歌单多选',
          icon: CupertinoIcons.selection_pin_in_out,
        )
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

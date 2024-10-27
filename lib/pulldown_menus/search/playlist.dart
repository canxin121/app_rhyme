import 'package:app_rhyme/pulldown_menus/items/paged.dart';
import 'package:app_rhyme/pulldown_menus/items/playlist.dart';
import 'package:app_rhyme/pulldown_menus/items/playlist_collection.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class SearchPlaylistChoiceMenu extends StatelessWidget {
  const SearchPlaylistChoiceMenu({
    super.key,
    required this.builder,
    required this.fetchAllPlaylists,
    required this.pagingController,
    required this.isDesktop,
  });

  final Future<void> Function() fetchAllPlaylists;
  final PagingController<int, Playlist> pagingController;
  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        // 打开歌单链接
        openPlaylistLinkPullDownItem(context, isDesktop),
        // 加载所有歌单
        loadAllPlaylistsMenuItem(context, fetchAllPlaylists),
        // 歌单多选
        playlistMultiSelectPullDownItem(
            context, pagingController.itemList ?? [], isDesktop),
      ],
      buttonBuilder: builder,
    );
  }
}

import 'package:app_rhyme/pulldown_menus/items/playlist.dart';
import 'package:app_rhyme/pulldown_menus/items/playlist_collection.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class PlaylistCollectionPageMenu extends StatelessWidget {
  const PlaylistCollectionPageMenu({
    super.key,
    required this.builder,
    required this.isDesktop,
    required this.playlists,
    required this.playlistCollections,
  });
  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;
  final List<PlaylistCollection> playlistCollections;
  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        // 创建歌单列表
        createPlaylistCollectionPullDownItem(context),
        // 歌单列表多选
        playlistCollectionMultiSelectPullDownItem(
            context, playlistCollections, isDesktop),
        // 歌单列表排序
        playlistCollectionReorderPullDownItem(context, isDesktop),
        // 创建歌单
        createPlaylistPullDownItem(context),
        // 歌单多选
        playlistMultiSelectPullDownItem(context, playlists, isDesktop),
        // 打开歌单链接
        openPlaylistLinkPullDownItem(context, isDesktop),
        // 导入歌单Json
        importPlaylistJsonPullDownItem(context),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

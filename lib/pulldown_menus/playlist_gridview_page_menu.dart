import 'package:app_rhyme/pulldown_menus/items/playlist.dart';
import 'package:app_rhyme/pulldown_menus/items/playlist_collection.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
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
        // 编辑歌单列表
        editPlaylistCollectionPullDownItem(context, playlistCollection),
        // 删除歌单列表
        deletePlaylistCollectionPullDownItem(
            context, playlistCollection, isDesktop),
        // 创建歌单
        createPlaylistPullDownItem(context,
            playlistCollection: playlistCollection),
        // 打开歌单链接
        openPlaylistLinkPullDownItem(context, isDesktop),
        // 导入歌单Json
        importPlaylistJsonPullDownItem(context,
            playlistCollection: playlistCollection),
        // 歌单排序
        playlistReorderPullDownItem(
            context, playlists, isDesktop, playlistCollection),
        // 歌单多选
        playlistMultiSelectionPullDownItem(context, playlists, isDesktop),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

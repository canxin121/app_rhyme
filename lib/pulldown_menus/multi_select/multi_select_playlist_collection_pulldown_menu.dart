import 'package:app_rhyme/pulldown_menus/items/playlist_collections.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class PlaylistCollectionMutiSelectGridPageMenu extends StatelessWidget {
  const PlaylistCollectionMutiSelectGridPageMenu({
    super.key,
    required this.builder,
    required this.controller,
    required this.playlistCollections,
    required this.setState,
  });

  final PullDownMenuButtonBuilder builder;
  final DragSelectGridViewController controller;
  final List<PlaylistCollection> playlistCollections;
  final void Function() setState;

  List<PlaylistCollection>? getSelectedPlaylists() {
    var selectedPlaylists = controller.value.selectedIndexes
        .map((index) => playlistCollections[index])
        .toList();
    if (selectedPlaylists.isEmpty) {
      LogToast.warning(
        "没有选中的歌单列表",
        "没有选中的歌单列表",
        "[PlaylistCollectionMutiSelectGridPageMenu] No playlist collection selected",
      );
      return null;
    }
    return selectedPlaylists;
  }

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        // 删除选中的歌单列表
        deleteSelectedPlaylistsPullDownItem(
            controller, playlistCollections, setState),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

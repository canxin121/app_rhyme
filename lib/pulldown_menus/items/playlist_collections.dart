import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/multi_select.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 获取选中的歌单列表
List<PlaylistCollection>? getSelectedPlaylists(
    DragSelectGridViewController controller,
    List<PlaylistCollection> playlistCollections) {
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

/// 删除选中的歌单列表
PullDownMenuItem deleteSelectedPlaylistsPullDownItem(
    DragSelectGridViewController controller,
    List<PlaylistCollection> playlistCollections,
    void Function() setState) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var selectedPlaylists =
          getSelectedPlaylists(controller, playlistCollections);
      if (selectedPlaylists == null) {
        return;
      }

      for (var playlistCollection in selectedPlaylists) {
        try {
          await playlistCollection.deleteFromDb();
          playlistCollectionDeleteStreamController.add(playlistCollection.id);
        } catch (e) {
          LogToast.error(
            "删除歌单列表失败",
            "删除歌单列表失败",
            "[PlaylistCollectionMutiSelectGridPageMenu] Failed to delete playlist collection",
          );
        }
      }
      playlistCollections.removeWhere(
          (e) => selectedPlaylists.any((selected) => selected.id == e.id));
      rebuildDragged(controller, playlistCollections.length);
      setState();
    },
    title: '删除歌单列表',
    icon: CupertinoIcons.delete,
  );
}

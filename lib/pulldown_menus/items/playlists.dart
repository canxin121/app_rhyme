import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 获取选中的歌单
List<Playlist>? getSelectedPlaylists(
    DragSelectGridViewController controller, List<Playlist> playlists) {
  var selectedPlaylists = controller.value.selectedIndexes
      .map((index) => playlists[index])
      .toList();
  if (selectedPlaylists.isEmpty) {
    LogToast.warning(
      "没有选中的歌单",
      "没有选中的歌单",
      "[OnlinePlaylistMutiSelectGridPageMenu] No music list selected",
    );
    return null;
  }
  return selectedPlaylists;
}

/// 删除歌单
PullDownMenuItem deleteSelectedPlaylistsPullDownItem(
    DragSelectGridViewController controller,
    List<Playlist> playlists,
    void Function() setState) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var selectedPlaylists = getSelectedPlaylists(controller, playlists);
      if (selectedPlaylists == null) {
        return;
      }
      for (var playlist in selectedPlaylists) {
        try {
          await playlist.delFromDb();
          playlistDeleteStreamController.add(playlist.identity);
        } catch (e) {
          LogToast.error(
            "删除歌单失败",
            "删除歌单'${playlist.name}'失败",
            "[MutliSelectLocalMusicListGridPage] Failed to delete music list: ${playlist.name}, error: $e",
          );
        }
      }

      playlists.removeWhere((playlist) => selectedPlaylists.any(
          (selectedPlaylist) =>
              selectedPlaylist.identity == playlist.identity));

      controller.clear();
      setState();

      LogToast.success(
        "删除歌单成功",
        "删除歌单成功",
        "[MutliSelectLocalMusicListGridPage] Successfully deleted music list",
      );
    },
    title: '删除歌单',
    icon: CupertinoIcons.delete,
  );
}

/// 保存歌单
PullDownMenuItem saveOnlinePlaylistsItemPullDownItem(
    DragSelectGridViewController controller,
    List<Playlist> playlists,
    BuildContext context) {
  return PullDownMenuItem(
    onTap: () {
      var selectedPlaylists = getSelectedPlaylists(controller, playlists);
      if (selectedPlaylists == null) {
        return;
      }
      saveOnlinePlaylists(context, selectedPlaylists);
    },
    title: '保存歌单',
    icon: CupertinoIcons.music_house_fill,
  );
}

/// 保存歌曲
PullDownMenuItem saveMusicAggregatorsFromPlaylistsPullDownItem(
    DragSelectGridViewController controller,
    List<Playlist> playlists,
    BuildContext context) {
  return PullDownMenuItem(
    onTap: () {
      var selectedPlaylists = getSelectedPlaylists(controller, playlists);
      if (selectedPlaylists == null) {
        return;
      }
      saveAggsOfPlaylists(selectedPlaylists, context);
    },
    title: '保存歌曲',
    icon: CupertinoIcons.add_circled_solid,
  );
}

/// 导出Json文件
PullDownMenuItem exportPlaylistsToJsonPullDownItem(
    DragSelectGridViewController controller,
    List<Playlist> playlists,
    BuildContext context) {
  return PullDownMenuItem(
    onTap: () {
      var selectedPlaylists = getSelectedPlaylists(controller, playlists);
      if (selectedPlaylists == null) {
        return;
      }
      exportPlaylistsJson(context, selectedPlaylists);
    },
    title: '导出json文件',
    icon: CupertinoIcons.download_circle,
  );
}

import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/multi_select.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class PlaylistMutiSelectGridPageMenu extends StatelessWidget {
  const PlaylistMutiSelectGridPageMenu({
    super.key,
    required this.builder,
    required this.controller,
    required this.playlists,
    required this.setState,
  });

  final PullDownMenuButtonBuilder builder;
  final DragSelectGridViewController controller;
  final List<Playlist> playlists;
  final void Function() setState;

  List<Playlist>? getSelectedPlaylists() {
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

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        if (playlists.first.fromDb)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () async {
              var selectedPlaylists = getSelectedPlaylists();
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
              for (var index
                  in controller.value.selectedIndexes.toList().reversed) {
                playlists.removeAt(index);
              }
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
          ),
        if (!playlists.first.fromDb)
          PullDownMenuItem(
            onTap: () {
              var selectedPlaylists = getSelectedPlaylists();
              if (selectedPlaylists == null) {
                return;
              }
              saveOnlinePlaylists(context, selectedPlaylists);
            },
            title: '保存歌单',
            icon: CupertinoIcons.music_house_fill,
          ),
        PullDownMenuItem(
          onTap: () {
            var selectedPlaylists = getSelectedPlaylists();
            if (selectedPlaylists == null) {
              return;
            }
            saveAggsOfPlaylists(selectedPlaylists, context);
          },
          title: '保存歌曲',
          icon: CupertinoIcons.add_circled_solid,
        ),
        PullDownMenuItem(
          onTap: () {
            var selectedPlaylists = getSelectedPlaylists();
            if (selectedPlaylists == null) {
              return;
            }

            exportPlaylistsJson(context, selectedPlaylists);
          },
          title: '导出json文件',
          icon: CupertinoIcons.download_circle_fill,
        ),
        PullDownMenuItem(
          onTap: () => selectAll(controller, playlists.length),
          title: '全部选中',
          icon: CupertinoIcons.checkmark_seal_fill,
        ),
        PullDownMenuItem(
          onTap: () {
            controller.clear();
            setState();
          },
          title: '取消选中',
          icon: CupertinoIcons.xmark,
        ),
        PullDownMenuItem(
          onTap: () => reverseSelect(controller, playlists.length),
          title: '反选',
          icon: CupertinoIcons.arrow_swap,
        ),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

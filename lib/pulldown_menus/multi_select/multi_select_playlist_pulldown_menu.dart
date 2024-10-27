import 'package:app_rhyme/pulldown_menus/items/playlists.dart';
import 'package:app_rhyme/pulldown_menus/items/select.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
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

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        if (playlists.first.fromDb)
          // 删除歌单
          deleteSelectedPlaylistsPullDownItem(controller, playlists, setState),
        if (!playlists.first.fromDb)
          // 保存歌单
          saveOnlinePlaylistsItemPullDownItem(controller, playlists, context),
        saveMusicAggregatorsFromPlaylistsPullDownItem(
            controller, playlists, context),
        // 导出Json文件
        exportPlaylistsToJsonPullDownItem(controller, playlists, context),
        // 全部选中
        selectAllPullDownItemPullDownItem(controller, playlists.length),
        // 取消选中
        clearSelectionPullDownItem(
          setState,
          controller,
        ),
        // 反转选中
        reverseSelectionPullDownItem(controller, playlists.length),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

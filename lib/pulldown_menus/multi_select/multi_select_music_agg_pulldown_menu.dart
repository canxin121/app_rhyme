import 'package:app_rhyme/pulldown_menus/items/music_aggregators.dart';
import 'package:app_rhyme/pulldown_menus/items/select.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class MusicAggMultiSelectMenu extends StatelessWidget {
  const MusicAggMultiSelectMenu({
    super.key,
    required this.builder,
    required this.playlist,
    required this.musicAggs,
    required this.setState,
    required this.controller,
  });

  final PullDownMenuButtonBuilder builder;
  final Playlist? playlist;
  final List<MusicAggregator> musicAggs;
  final VoidCallback setState;
  final DragSelectGridViewController controller;

  @override
  Widget build(BuildContext context) {
    final List<PullDownMenuEntry> menuItems = [
      if (playlist != null && playlist!.fromDb) ...[
        PullDownMenuHeader(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          leading: imageWithCache(playlist!.getCover(size: 250),
              height: 100, width: 100),
          title: playlist!.name,
          subtitle: playlist!.summary,
        ),
        const PullDownMenuDivider.large(),
        // 缓存选中音乐
        cacheSelectedMusicAggsPullDownItem(setState, controller, musicAggs),
        // 删除音乐缓存
        deleteSelectedMusicCachePullDownItem(setState, controller, musicAggs),
        // 从歌单删除
        deleteMusicFromPlaylistPullDownItem(
            playlist!, setState, controller, musicAggs),
      ],
      // 添加到歌单
      addSelectedMusicToPlaylistPullDownItem(context, controller, musicAggs),
      // 创建新歌单
      createNewPlaylistFromSelectedPullDownItem(context, controller, musicAggs),
      // 导出为Json文件
      exportSelectedMusicToJsonPullDownItem(context, controller, musicAggs),
      // 全部选中
      selectAllPullDownItemPullDownItem(controller, musicAggs.length),
      // 取消选中
      clearSelectionPullDownItem(setState, controller),
      // 反转选中
      reverseSelectionPullDownItem(controller, musicAggs.length),
    ];

    return PullDownButton(
      itemBuilder: (context) => menuItems,
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

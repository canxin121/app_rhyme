import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/reorder_page/music_aggregator.dart';
import 'package:app_rhyme/common_comps/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 缓存选中音乐
PullDownMenuItem cacheSelectedMusicAggsPullDownItem(VoidCallback setState,
    DragSelectGridViewController controller, List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var selectedMusicAggs = controller.value.selectedIndexes
          .map((index) => musicAggs[index])
          .toList();
      await cacheMusicAggs(selectedMusicAggs);
      setState();
    },
    title: '缓存选中音乐',
    icon: CupertinoIcons.cloud_download,
  );
}

/// 缓存所有音乐
PullDownMenuItem cacheAllMusicAggsPullDownItem(
    BuildContext context, List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      bool? confirm = await showConfirmationDialog(
        context,
        "确定要缓存所有音乐吗？\n这可能需要一些时间,且无法中途取消",
      );
      if (confirm == null || !confirm) {
        return;
      }
      cacheMusicAggs(musicAggs);
    },
    title: '缓存所有音乐',
    icon: CupertinoIcons.cloud_download,
  );
}

/// 删除所有音乐缓存
PullDownMenuItem deleteAllMusicAggsCachePullDownItem(
    List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      for (var musicAgg in musicAggs) {
        await delMusicCache(musicAgg, showToast: false);
      }
      LogToast.success("删除所有音乐缓存", "删除所有音乐缓存成功",
          "[LocalMusicListChoicMenu] Successfully deleted all music caches");
    },
    title: '删除所有音乐缓存',
    icon: CupertinoIcons.delete,
  );
}

/// 删除音乐缓存
PullDownMenuItem deleteSelectedMusicCachePullDownItem(VoidCallback setState,
    DragSelectGridViewController controller, List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      var selectedMusicAggs = controller.value.selectedIndexes
          .map((index) => musicAggs[index])
          .toList();
      deleteMusicsCache(
        selectedMusicAggs,
      );
    },
    title: '删除音乐缓存',
    icon: CupertinoIcons.delete,
  );
}

/// 从歌单删除
PullDownMenuItem deleteMusicFromPlaylistPullDownItem(
    Playlist playlist,
    VoidCallback setState,
    DragSelectGridViewController controller,
    List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      if (playlist.fromDb) {
        var musicAggsToDelete = controller.value.selectedIndexes
            .map((index) => musicAggs[index])
            .toList();
        for (var musicAggToDelete in musicAggsToDelete) {
          try {
            await playlist.delMusicAgg(
                musicAggIdentity: musicAggToDelete.identity());
          } catch (e) {
            LogToast.error("删除失败", "删除音乐失败: $e",
                "[deleteMusicAggsFromDbPlaylist] Failed to delete music: $e");
          }
        }

        musicAggs.removeWhere((musicAgg) => musicAggsToDelete.any(
            (musicAggToDelete) =>
                musicAgg.name == musicAggToDelete.name &&
                musicAgg.artist == musicAggToDelete.artist));
        controller.clear();
        setState();
      }
    },
    title: '从歌单删除',
    icon: CupertinoIcons.trash,
  );
}

/// 添加到歌单
PullDownMenuItem addSelectedMusicToPlaylistPullDownItem(BuildContext context,
    DragSelectGridViewController controller, List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var selectedMusicAggs = controller.value.selectedIndexes
          .map((index) => musicAggs[index])
          .toList();
      await addMusicsToPlayList(context, selectedMusicAggs);
    },
    title: '添加到歌单',
    icon: CupertinoIcons.add,
  );
}

/// 创建新歌单
PullDownMenuItem createNewPlaylistFromSelectedPullDownItem(BuildContext context,
    DragSelectGridViewController controller, List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      var selectedMusicAggs = controller.value.selectedIndexes
          .map((index) => musicAggs[index])
          .toList();
      await createPlaylistFromMusics(context, selectedMusicAggs);
    },
    title: '创建新歌单',
    icon: CupertinoIcons.add_circled,
  );
}

/// 导出为JSON文件
PullDownMenuItem exportSelectedMusicToJsonPullDownItem(BuildContext context,
    DragSelectGridViewController controller, List<MusicAggregator> musicAggs) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => exportMusicAggregatorsJson(
        context,
        controller.value.selectedIndexes
            .map((index) => musicAggs[index])
            .toList()),
    title: '导出为json文件',
    icon: CupertinoIcons.arrow_up_doc_fill,
  );
}

/// 歌曲排序
PullDownMenuItem orderMusicAggsPullDownItem(
  BuildContext context,
  List<MusicAggregator> musicAggs,
  Playlist playlist,
  bool isDesktop,
) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      navigate(
          context,
          MuiscAggregatorReorderPage(
            musicAggregators: musicAggs,
            playlist: playlist,
            isDesktop: isDesktop,
          ),
          isDesktop,
          "");
    },
    title: "歌曲排序",
    icon: CupertinoIcons.sort_up_circle,
  );
}

/// 歌曲多选
PullDownMenuItem multiSelectMusicAggsPullDownItem(
  BuildContext context,
  List<MusicAggregator> musicAggs,
  Playlist playlist,
  bool isDesktop,
) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      navigate(
          context,
          MusicAggregatorMultiSelectionPage(
            playlist: playlist,
            musicAggs: musicAggs,
            isDesktop: isDesktop,
          ),
          isDesktop,
          "");
    },
    title: "歌曲多选",
    icon: CupertinoIcons.selection_pin_in_out,
  );
}

/// 加载所有音乐
PullDownMenuItem fetchAllMusicAggregatorsPullDownMenuItem(
    dynamic fetchAllMusicAggregators) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: fetchAllMusicAggregators,
    title: "加载所有音乐",
    icon: CupertinoIcons.music_note_2,
  );
}

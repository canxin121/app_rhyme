import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/multi_select.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
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
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            var selectedMusicAggs = controller.value.selectedIndexes
                .map((index) => musicAggs[index])
                .toList();
            cacheMusicAggs(selectedMusicAggs, () {
              setState();
              playlist?.getMusicsFromDb().then(
                  (e) => musicAggregatorListUpdateStreamController.add(e));
            });
          },
          title: '缓存选中音乐',
          icon: CupertinoIcons.cloud_download,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            var selectedMusicAggs = controller.value.selectedIndexes
                .map((index) => musicAggs[index])
                .toList();
            deleteMusicAggsCache(selectedMusicAggs, () {
              setState();
            });
          },
          title: '删除音乐缓存',
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (playlist!.fromDb) {
              for (var index in controller.value.selectedIndexes) {
                try {
                  await playlist!.delMusicAgg(
                      musicAggIdentity: musicAggs[index].identity());
                } catch (e) {
                  LogToast.error("删除失败", "删除音乐失败: $e",
                      "[deleteMusicAggsFromDbPlaylist] Failed to delete music: $e");
                }
              }

              var sortedIndexes =
                  List.of(controller.value.selectedIndexes).reversed;
              for (var index in sortedIndexes) {
                musicAggs.removeAt(index);
              }
              controller.clear();
              setState();
              playlist?.getMusicsFromDb().then(
                  (e) => musicAggregatorListUpdateStreamController.add(e));
            }
          },
          title: '从歌单删除',
          icon: CupertinoIcons.trash,
        ),
      ],
      PullDownMenuItem(
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
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          var selectedMusicAggs = controller.value.selectedIndexes
              .map((index) => musicAggs[index])
              .toList();
          await createNewMusicListFromMusics(context, selectedMusicAggs);
        },
        title: '创建新歌单',
        icon: CupertinoIcons.add_circled,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () => selectAll(controller, musicAggs.length),
        title: '全部选中',
        icon: CupertinoIcons.checkmark_seal_fill,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () {
          controller.clear();
          setState();
        },
        title: '取消选中',
        icon: CupertinoIcons.xmark,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () => reverseSelect(controller, musicAggs.length),
        title: '反选',
        icon: CupertinoIcons.arrow_swap,
      ),
    ];

    return PullDownButton(
      itemBuilder: (context) => menuItems,
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_container_list_item.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MutiSelectMusicContainerListPage extends StatefulWidget {
  final List<MusicAggregator> musicAggs;
  final Playlist? musicList;

  const MutiSelectMusicContainerListPage({
    super.key,
    this.musicList,
    required this.musicAggs,
  });

  @override
  MutiSelectMusicContainerListPageState createState() =>
      MutiSelectMusicContainerListPageState();
}

class MutiSelectMusicContainerListPageState
    extends State<MutiSelectMusicContainerListPage>
    with WidgetsBindingObserver {
  DragSelectGridViewController controller = DragSelectGridViewController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void handleDeleteSelected() {
    setState(() {
      widget.musicAggs.removeWhere((element) => controller.value.selectedIndexes
          .contains(widget.musicAggs.indexOf(element)));
      controller.clear();
    });
  }

  void handleRefresh() {
    setState(() {});
  }

  void handleSelectAll() {
    Set<int> selectAllSet =
        Set.from(List.generate(widget.musicAggs.length, (i) => i));
    setState(() {
      controller.clear();
      controller.dispose();
      controller = DragSelectGridViewController(Selection(selectAllSet));
      controller.addListener(
        () => setState(() {}),
      );
    });
  }

  void handleCancelSelectAll() {
    setState(() {
      controller.clear();
    });
  }

  void handleReverseSelect() {
    Set<int> selectAllSet = Set.from(
        List.generate(widget.musicAggs.length, (i) => i, growable: false));
    selectAllSet.removeAll(controller.value.selectedIndexes);
    setState(() {
      controller.clear();
      controller.dispose();
      controller = DragSelectGridViewController(Selection(selectAllSet));
      controller.addListener(
        () => setState(() {}),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);
    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(children: [
        CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 16),
          backgroundColor: backgroundColor,
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          trailing: MutiSelectLocalMusicContainerListChoiceMenu(
            delSelected: handleDeleteSelected,
            refresh: handleRefresh,
            builder: (context, showMenu) => CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: showMenu,
              child: Text(
                '选项',
                style: TextStyle(color: activeIconRed).useSystemChineseFont(),
              ),
            ),
            playlist: widget.musicList,
            musicAggs: controller.value.selectedIndexes
                .map((index) => widget.musicAggs[index])
                .toList(),
            cancelSelectAll: handleCancelSelectAll,
            selectAll: handleSelectAll,
            reverseSelect: handleReverseSelect,
          ),
        ),
        Expanded(
            child: widget.musicAggs.isEmpty
                ? Center(
                    child: Text(
                      "没有音乐",
                      style: TextStyle(
                              color: isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black)
                          .useSystemChineseFont(),
                    ),
                  )
                : Align(
                    key: ValueKey(controller.hashCode),
                    alignment: Alignment.topCenter,
                    child: DragSelectGridView(
                      gridController: controller,
                      padding: const EdgeInsets.only(
                          bottom: 100, top: 10, left: 10, right: 10),
                      itemCount: widget.musicAggs.length,
                      triggerSelectionOnTap: true,
                      itemBuilder: (context, index, selected) {
                        final musicContainer = widget.musicAggs[index];
                        return Column(
                          children: [
                            Row(
                              key: ValueKey(
                                  "${selected}_${musicContainer.name}_${musicContainer.artist}"),
                              children: [
                                Expanded(
                                  child: MusicContainerListItem(
                                    showMenu: false,
                                    musicAgg: musicContainer,
                                    playlist: widget.musicList,
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? CupertinoIcons.check_mark_circled
                                      : CupertinoIcons.circle,
                                  color: selected
                                      ? CupertinoColors.systemGreen
                                      : CupertinoColors.systemGrey4,
                                ),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.only(top: 10)),
                            SizedBox(
                              width: screenWidth * 0.85,
                              child: Divider(
                                color: dividerColor,
                                height: 0.5,
                              ),
                            )
                          ],
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        childAspectRatio: 6,
                      ),
                    ),
                  ))
      ]),
    );
  }
}

@immutable
class MutiSelectLocalMusicContainerListChoiceMenu extends StatelessWidget {
  const MutiSelectLocalMusicContainerListChoiceMenu({
    super.key,
    required this.builder,
    required this.playlist,
    required this.musicAggs,
    required this.refresh,
    required this.cancelSelectAll,
    required this.selectAll,
    required this.delSelected,
    required this.reverseSelect,
  });

  final PullDownMenuButtonBuilder builder;
  final Playlist? playlist;
  final List<MusicAggregator> musicAggs;
  final void Function() refresh;
  final void Function() cancelSelectAll;
  final void Function() selectAll;
  final void Function() delSelected;
  final void Function() reverseSelect;

  Future<void> handleCacheSelected() async {
    for (var musicAgg in musicAggs) {
      await cacheMusicContainer(MusicContainer(musicAgg));
      refresh();
    }
    LogToast.success("缓存选中音乐", "缓存选中音乐成功",
        "[MutiSelectLocalMusicContainerListChoiceMenu] Successfully cached selected music");
  }

  Future<void> handleDeleteCacheSelected() async {
    for (var musicAgg in musicAggs) {
      var defaultMusic = getMusicAggregatorDefaultMusic(musicAgg);
      if (defaultMusic == null) {
        continue;
      }
      await deleteMusicCache(musicInfo: defaultMusic);
      refresh();
    }
    LogToast.success("删除选中音乐缓存", "删除选中音乐缓存成功",
        "[MutiSelectLocalMusicContainerListChoiceMenu] Successfully deleted selected music caches");
  }

  Future<void> handleDeleteFromList() async {
    if (playlist != null) {
      for (var musicAgg in musicAggs) {
        await musicAgg.delFromDb();
      }
      refreshMusicAggregatorListViewPage();
      delSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PullDownMenuEntry> menuItems = [
      if (playlist != null) ...[
        PullDownMenuHeader(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            leading: imageWithCache(playlist!.cover),
            title: playlist!.name,
            subtitle: playlist!.summary),
        const PullDownMenuDivider.large(),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: handleCacheSelected,
          title: '缓存选中音乐',
          icon: CupertinoIcons.cloud_download,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: handleDeleteCacheSelected,
          title: '删除音乐缓存',
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: handleDeleteFromList,
          title: '从歌单删除',
          icon: CupertinoIcons.trash,
        ),
      ],
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          await addMusicsToPlayList(context, musicAggs);
        },
        title: '添加到歌单',
        icon: CupertinoIcons.add,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          await createNewMusicListFromMusics(context, musicAggs);
        },
        title: '创建新歌单',
        icon: CupertinoIcons.add_circled,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: selectAll,
        title: '全部选中',
        icon: CupertinoIcons.checkmark_seal_fill,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: cancelSelectAll,
        title: '取消选中',
        icon: CupertinoIcons.xmark,
      ),
      PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: reverseSelect,
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

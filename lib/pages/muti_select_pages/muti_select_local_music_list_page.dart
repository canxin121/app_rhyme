import 'package:app_rhyme/pages/local_music_container_listview_page.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MutiSelectLocalMusicContainerListPage extends StatefulWidget {
  final List<MusicContainer> musicContainers;
  final MusicListW musicList;

  const MutiSelectLocalMusicContainerListPage({
    super.key,
    required this.musicList,
    required this.musicContainers,
  });

  @override
  MutiSelectLocalMusicContainerListPageState createState() =>
      MutiSelectLocalMusicContainerListPageState();
}

class MutiSelectLocalMusicContainerListPageState
    extends State<MutiSelectLocalMusicContainerListPage>
    with WidgetsBindingObserver {
  DragSelectGridViewController controller = DragSelectGridViewController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(() {
      setState(() {
        print(111);
      });
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
      widget.musicContainers.removeWhere((element) => controller
          .value.selectedIndexes
          .contains(widget.musicContainers.indexOf(element)));
      controller.clear();
    });
  }

  void handleRefresh() {
    setState(() {});
  }

  void handleSelectAll() {
    Set<int> selectAllSet =
        Set.from(List.generate(widget.musicContainers.length, (i) => i));
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
    Set<int> selectAllSet = Set.from(List.generate(
        widget.musicContainers.length, (i) => i,
        growable: false));
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

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
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
          musicListW: widget.musicList,
          musicContainers: controller.value.selectedIndexes
              .map((index) => widget.musicContainers[index])
              .toList(),
          cancelSelectAll: handleCancelSelectAll,
          selectAll: handleSelectAll,
          reverseSelect: handleReverseSelect,
        ),
      ),
      child: widget.musicContainers.isEmpty
          ? Center(
              child: Text(
                "没有音乐",
                style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black),
              ),
            )
          : Align(
              key: ValueKey(controller.hashCode),
              alignment: Alignment.topCenter,
              child: DragSelectGridView(
                gridController: controller,
                padding:
                    const EdgeInsets.only(bottom: 100, left: 10, right: 10),
                itemCount: widget.musicContainers.length,
                triggerSelectionOnTap: true,
                itemBuilder: (context, index, selected) {
                  final musicContainer = widget.musicContainers[index];
                  return Row(
                    key: ValueKey(
                        "${selected}_${musicContainer.hasCache()}_${musicContainer.hashCode}"),
                    children: [
                      Expanded(
                        child: MusicContainerListItem(
                          key: ValueKey(
                              "${musicContainer.hasCache()}_${musicContainer.hashCode}"),
                          showMenu: false,
                          musicContainer: musicContainer,
                          musicListW: widget.musicList,
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
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  childAspectRatio: 8 / 1,
                ),
              ),
            ),
    );
  }
}

@immutable
class MutiSelectLocalMusicContainerListChoiceMenu extends StatelessWidget {
  const MutiSelectLocalMusicContainerListChoiceMenu({
    super.key,
    required this.builder,
    required this.musicListW,
    required this.musicContainers,
    required this.refresh,
    required this.cancelSelectAll,
    required this.selectAll,
    required this.delSelected,
    required this.reverseSelect,
  });

  final PullDownMenuButtonBuilder builder;
  final MusicListW musicListW;
  final List<MusicContainer> musicContainers;
  final void Function() refresh;
  final void Function() cancelSelectAll;
  final void Function() selectAll;
  final void Function() delSelected;
  final void Function() reverseSelect;

  Future<void> handleCacheSelected() async {
    for (var musicContainer in musicContainers) {
      await cacheMusic(musicContainer);
      refresh();
    }
  }

  Future<void> handleDeleteCacheSelected() async {
    for (var musicContainer in musicContainers) {
      await delMusicCache(musicContainer);
      refresh();
    }
  }

  Future<void> handleDeleteFromList() async {
    MusicListInfo musicListInfo = musicListW.getMusiclistInfo();
    SqlFactoryW.delMusics(
      musicListName: musicListInfo.name,
      ids: Int64List.fromList(musicContainers.map((e) => e.info.id).toList()),
    );
    globalMusicContainerListPageRefreshFunction();
    delSelected();
  }

  @override
  Widget build(BuildContext context) {
    MusicListInfo musicListInfo = musicListW.getMusiclistInfo();

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          leading: imageCacheHelper(musicListInfo.artPic),
          title: musicListInfo.name,
          subtitle: musicListInfo.desc,
        ),
        const PullDownMenuDivider.large(),
        PullDownMenuItem(
          onTap: handleCacheSelected,
          title: '缓存选中音乐',
        ),
        PullDownMenuItem(
          onTap: handleDeleteCacheSelected,
          title: '删除音乐缓存',
        ),
        PullDownMenuItem(
          onTap: handleDeleteFromList,
          title: '从歌单删除',
        ),
        PullDownMenuItem(
          onTap: () async {
            await addMusicsToMusicList(context, musicContainers);
          },
          title: '添加到歌单',
        ),
        PullDownMenuItem(
          onTap: () async {
            await createNewMusicListFromMusics(context, musicContainers);
          },
          title: '创建新歌单',
        ),
        PullDownMenuItem(
          onTap: cancelSelectAll,
          title: '取消选中',
        ),
        PullDownMenuItem(
          onTap: selectAll,
          title: '全部选中',
        ),
        PullDownMenuItem(
          onTap: reverseSelect,
          title: '反选',
        ),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

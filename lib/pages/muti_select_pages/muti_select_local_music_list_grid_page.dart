import 'package:flutter/cupertino.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:app_rhyme/pages/local_music_list_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/utils/logger.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MutiSelectLocalMusicListGridPage extends StatefulWidget {
  final List<MusicListW> musicLists;

  const MutiSelectLocalMusicListGridPage({super.key, required this.musicLists});

  @override
  MutiSelectLocalMusicListGridPageState createState() =>
      MutiSelectLocalMusicListGridPageState();
}

class MutiSelectLocalMusicListGridPageState
    extends State<MutiSelectLocalMusicListGridPage>
    with WidgetsBindingObserver {
  DragSelectGridViewController controller = DragSelectGridViewController();

  @override
  void initState() {
    super.initState();
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

  void handleSelectAll() {
    Set<int> selectAllSet =
        Set.from(List.generate(widget.musicLists.length, (i) => i));
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
        List.generate(widget.musicLists.length, (i) => i, growable: false));
    selectAllSet.removeAll(controller.value.selectedIndexes);
    setState(() {
      controller.clear();
      controller.dispose();
      controller =
          DragSelectGridViewController(Selection(Set.from(selectAllSet)));
      controller.addListener(() => setState(() {}));
    });
  }

  Future<void> deleteMusicList() async {
    if (controller.value.selectedIndexes.isEmpty) {
      LogToast.warning(
        "没有选中的歌单",
        "没有选中的歌单",
        "[MutliSelectLocalMusicListGridPage] No music list selected",
      );
      return;
    }
    List<MusicListW> selectedMusicLists = controller.value.selectedIndexes
        .map((index) => widget.musicLists[index])
        .toList();
    try {
      await SqlFactoryW.delMusiclist(
          musiclistNames: selectedMusicLists
              .map((musicList) => musicList.getMusiclistInfo().name)
              .toList());
      setState(() {
        widget.musicLists
            .removeWhere((musicList) => selectedMusicLists.contains(musicList));
        controller.clear();
      });
      globalMusicListGridPageRefreshFunction();
      LogToast.success(
        "删除歌单成功",
        "删除歌单成功",
        "[MutliSelectLocalMusicListGridPage] Successfully deleted music list",
      );
    } catch (e) {
      LogToast.error(
        "删除歌单失败",
        "删除歌单失败: $e",
        "[MutliSelectLocalMusicListGridPage] Failed to delete music list: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: _buildNavigationBar(),
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: widget.musicLists.isEmpty
            ? Center(
                child: Text("没有歌单", style: TextStyle(color: textColor)),
              )
            : _buildMusicListGrid(),
      ),
    );
  }

  CupertinoNavigationBar _buildNavigationBar() {
    return CupertinoNavigationBar(
      padding: const EdgeInsetsDirectional.all(0),
      leading: CupertinoButton(
        padding: const EdgeInsets.all(0),
        child: Icon(CupertinoIcons.back, color: activeIconRed),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      trailing: MutiSelectMusicListGridPageMenu(
        builder: (context, showMenu) => CupertinoButton(
          padding: const EdgeInsets.only(right: 16),
          onPressed: showMenu,
          child: Text(
            "选项",
            style: TextStyle(color: activeIconRed),
          ),
        ),
        deleteMusicList: deleteMusicList,
        selectAll: handleSelectAll,
        cancelSelectAll: handleCancelSelectAll,
        reverseSelect: handleReverseSelect,
      ),
    );
  }

  Widget _buildMusicListGrid() {
    return Align(
      key: ValueKey(controller.hashCode),
      alignment: Alignment.topCenter,
      child: DragSelectGridView(
        gridController: controller,
        padding: const EdgeInsets.only(bottom: 100, left: 10, right: 10),
        itemCount: widget.musicLists.length,
        triggerSelectionOnTap: true,
        itemBuilder: (context, index, selected) {
          final musicList = widget.musicLists[index];
          return Stack(
            key: ValueKey("${selected}_${musicList.hashCode}"),
            children: [
              MusicListImageCard(
                musicListW: musicList,
                online: false,
                cachePic: globalConfig.savePicWhenAddMusicList,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    selected
                        ? CupertinoIcons.check_mark_circled
                        : CupertinoIcons.circle,
                    color: selected
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemGrey4,
                  ),
                ),
              ),
            ],
          );
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 2 / 3,
        ),
      ),
    );
  }
}

@immutable
class MutiSelectMusicListGridPageMenu extends StatelessWidget {
  const MutiSelectMusicListGridPageMenu({
    super.key,
    required this.builder,
    required this.deleteMusicList,
    required this.selectAll,
    required this.cancelSelectAll,
    required this.reverseSelect,
  });

  final PullDownMenuButtonBuilder builder;
  final Future<void> Function() deleteMusicList;
  final void Function() selectAll;
  final void Function() cancelSelectAll;
  final void Function() reverseSelect;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: deleteMusicList,
          title: '删除歌单',
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          onTap: selectAll,
          title: '全部选中',
        ),
        PullDownMenuItem(
          onTap: cancelSelectAll,
          title: '取消选中',
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

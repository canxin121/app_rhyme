import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/pages/local_music_list_grid_page.dart';
import 'package:app_rhyme/pages/local_music_list_page.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:reorderables/reorderables.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/utils/colors.dart';

class ReorderLocalMusicListPage extends StatefulWidget {
  final List<MusicContainer> musicContainers;
  final MusicListW musicList;
  const ReorderLocalMusicListPage(
      {super.key, required this.musicContainers, required this.musicList});

  @override
  ReorderLocalMusicListPageState createState() =>
      ReorderLocalMusicListPageState();
}

class ReorderLocalMusicListPageState extends State<ReorderLocalMusicListPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final double screenWidth = MediaQuery.of(context).size.width;

    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.all(0),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.checkmark, color: activeIconRed),
            onPressed: () async {
              try {
                List<int> musicIds =
                    widget.musicContainers.map((ml) => ml.info.id).toList();
                await SqlFactoryW.reorderMusics(
                    musicListName: widget.musicList.getMusiclistInfo().name,
                    newIds: Int64List.fromList(musicIds));
                await globalMusicContainerListPageRefreshFunction();
                LogToast.success("歌曲排序成功", "歌曲排序成功",
                    "[ReorderLocalMusicListPageState] Music list reordered successfully");
              } catch (e) {
                LogToast.error("歌曲排序失败", "歌曲排序错误:$e",
                    "[ReorderLocalMusicListPageState] Failed to reorder music list: $e");
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        child: widget.musicContainers.isEmpty
            ? Center(
                child: Text("没有歌曲", style: TextStyle(color: textColor)),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: ReorderableWrap(
                  padding: const EdgeInsets.only(
                      top: 50, bottom: 100, left: 0, right: 0),
                  spacing: 8.0,
                  runSpacing: 8.0,
                  needsLongPressDraggable: false,
                  children: widget.musicContainers.map((musicContainer) {
                    return SizedBox(
                        width: screenWidth - 20,
                        child: MusicContainerListItem(
                          musicListW: widget.musicList,
                          musicContainer: musicContainer,
                          onTap: () {},
                        ));
                  }).toList(),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      final MusicContainer item =
                          widget.musicContainers.removeAt(oldIndex);
                      widget.musicContainers.insert(newIndex, item);
                    });
                  },
                ),
              ));
  }
}

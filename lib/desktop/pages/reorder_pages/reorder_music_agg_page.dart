import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/home.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:reorderables/reorderables.dart';
import 'package:app_rhyme/utils/colors.dart';

class DesktopReorderLocalMusicListPage extends StatefulWidget {
  final Playlist playlist;
  const DesktopReorderLocalMusicListPage({super.key, required this.playlist});

  @override
  DesktopReorderLocalMusicListPageState createState() =>
      DesktopReorderLocalMusicListPageState();
}

class DesktopReorderLocalMusicListPageState
    extends State<DesktopReorderLocalMusicListPage>
    with WidgetsBindingObserver {
  List<MusicAggregator> musicAggs = [];

  @override
  void initState() {
    super.initState();
    widget.playlist.getMusicsFromDb().then((e) => {
          setState(() {
            musicAggs = e;
          })
        });
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
        child: Column(
          children: [
            CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.all(0),
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: Icon(CupertinoIcons.back, color: activeIconRed),
                onPressed: () {
                  Navigator.pop(globalDesktopPageContext);
                },
              ),
              trailing: CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: Icon(CupertinoIcons.checkmark, color: activeIconRed),
                onPressed: () async {
                  try {
                    for (int i = 0; i < musicAggs.length; i++) {
                      musicAggs[i].order = i;
                      // 更新到数据库
                      await musicAggs[i].updateOrderToDb(
                          playlistId: int.parse(widget.playlist.identity));
                    }

                    refreshMusicAggregatorListViewPage();
                    LogToast.success("歌曲排序成功", "歌曲排序成功",
                        "[ReorderLocalMusicListPageState] Music list reordered successfully");
                  } catch (e) {
                    LogToast.error("歌曲排序失败", "歌曲排序错误:$e",
                        "[ReorderLocalMusicListPageState] Failed to reorder music list: $e");
                  }
                  if (context.mounted) {
                    Navigator.pop(globalDesktopPageContext);
                  }
                },
              ),
            ),
            Expanded(
                child: musicAggs.isEmpty
                    ? Center(
                        child: Text("没有歌曲",
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: ReorderableWrap(
                          padding: const EdgeInsets.only(bottom: 100, top: 10),
                          spacing: 8.0,
                          runSpacing: 8.0,
                          needsLongPressDraggable: true,
                          scrollAnimationDuration: Duration.zero,
                          reorderAnimationDuration: Duration.zero,
                          children: musicAggs.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final MusicAggregator musicContainer = entry.value;
                            final bool hasBackgroundColor = index % 2 == 0;
                            return SizedBox(
                              width: screenWidth - 20,
                              child: MusicAggregatorListItem(
                                playlist: widget.playlist,
                                musicAgg: musicContainer,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                                hasBackgroundColor: hasBackgroundColor,
                              ),
                            );
                          }).toList(),
                          onReorder: (int oldIndex, int newIndex) {
                            setState(() {
                              final MusicAggregator item =
                                  musicAggs.removeAt(oldIndex);
                              musicAggs.insert(newIndex, item);
                            });
                          },
                        ),
                      ))
          ],
        ));
  }
}

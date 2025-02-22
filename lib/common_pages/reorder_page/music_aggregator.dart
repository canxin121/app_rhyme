import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:reorderables/reorderables.dart';
import 'package:app_rhyme/utils/colors.dart';

class MuiscAggregatorReorderPage extends StatefulWidget {
  final List<MusicAggregator> musicAggregators;
  final Playlist playlist;
  final bool isDesktop;

  const MuiscAggregatorReorderPage({
    super.key,
    required this.musicAggregators,
    required this.playlist,
    required this.isDesktop,
  });

  @override
  MuiscAggregatorReorderPageState createState() =>
      MuiscAggregatorReorderPageState();
}

class MuiscAggregatorReorderPageState extends State<MuiscAggregatorReorderPage>
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
    final double screenWidth = MediaQuery.of(context).size.width;

    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoNavigationBar(
            backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
            padding: const EdgeInsetsDirectional.all(0),
            leading: CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: Icon(CupertinoIcons.back, color: activeIconRed),
              onPressed: () {
                if (context.mounted) popPage(context, widget.isDesktop);
              },
            ),
            trailing: CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: Icon(CupertinoIcons.checkmark, color: activeIconRed),
              onPressed: () async {
                try {
                  for (int i = 0; i < widget.musicAggregators.length; i++) {
                    widget.musicAggregators[i].order = i;
                    // Update to the database
                    await widget.musicAggregators[i].updateOrderToDb(
                        playlistId: int.parse(widget.playlist.identity));
                  }
                  musicAggrgatorsPageRefreshStreamController
                      .add(widget.playlist.identity);
                } catch (e) {
                  LogToast.error("歌曲排序失败", "歌曲排序错误:$e",
                      "[ReorderLocalMusicListPageState] Failed to reorder music list: $e");
                }
                if (context.mounted) popPage(context, widget.isDesktop);
              },
            ),
          ),
          Expanded(
            child: widget.musicAggregators.isEmpty
                ? Center(
                    child: Text(
                      "没有歌曲",
                      style: TextStyle(color: getTextColor(isDarkMode))
                          .useSystemChineseFont(),
                    ),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ReorderableWrap(
                      padding: const EdgeInsets.only(
                          bottom: 100, left: 10, right: 10, top: 10),
                      spacing: 8.0,
                      runSpacing: 8.0,
                      needsLongPressDraggable: true,
                      children:
                          widget.musicAggregators.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final MusicAggregator musicAgg = entry.value;

                        Widget musicAggItem = widget.isDesktop
                            ? DesktopMusicAggregatorListItem(
                                playlist: widget.playlist,
                                musicAgg: musicAgg,
                                onTap: () {},
                                isDarkMode: isDarkMode,
                                hasBackgroundColor: index % 2 == 0,
                              )
                            : MobileMusicAggregatorListItem(
                                playlist: widget.playlist,
                                musicAgg: musicAgg,
                                onTap: () {},
                              );

                        return SizedBox(
                          width: screenWidth - 20,
                          child: musicAggItem,
                        );
                      }).toList(),
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          final MusicAggregator item =
                              widget.musicAggregators.removeAt(oldIndex);
                          widget.musicAggregators.insert(newIndex, item);
                        });
                      },
                    )),
          )
        ],
      ),
    );
  }
}

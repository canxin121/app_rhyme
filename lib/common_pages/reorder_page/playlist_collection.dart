import 'package:app_rhyme/common_comps/playlist_collection/playlist_collection_listitem.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:app_rhyme/utils/colors.dart';

class PlaylistCollectionReorderPage extends StatefulWidget {
  final bool isDesktop;
  final List<PlaylistCollection> collections;
  const PlaylistCollectionReorderPage({
    super.key,
    required this.isDesktop,
    required this.collections,
  });

  @override
  PlaylistCollectionReorderPageState createState() =>
      PlaylistCollectionReorderPageState();
}

class PlaylistCollectionReorderPageState
    extends State<PlaylistCollectionReorderPage> with WidgetsBindingObserver {
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

  Future<void> _updateCollectionsOrder() async {
    try {
      for (int i = 0; i < widget.collections.length; i++) {
        widget.collections[i].order = i;
        widget.collections[i] = await widget.collections[i].updateToDb();
      }
      playlistCollectionsPageRefreshStreamController.add(null);
    } catch (e) {
      LogToast.error("歌单集合排序失败", "歌单集合排序错误: $e",
          "[_updateCollectionsOrder] Failed to reorder playlist collection: $e");
    }
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
              backgroundColor: getNavigatorBarColor(isDarkMode),
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
                  await _updateCollectionsOrder();
                  if (context.mounted) popPage(context, widget.isDesktop);
                },
              ),
            ),
            Expanded(
              child: widget.collections.isEmpty
                  ? Center(
                      child: Text("没有歌单集合",
                          style: TextStyle(color: getTextColor(isDarkMode))
                              .useSystemChineseFont()),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: ReorderableWrap(
                        padding: const EdgeInsets.only(
                            bottom: 100, left: 10, right: 10, top: 10),
                        spacing: 8.0,
                        runSpacing: 8.0,
                        needsLongPressDraggable: true,
                        children: widget.collections
                            .map((collection) => Column(
                                  children: [
                                    SizedBox(
                                      width: screenWidth - 20,
                                      child: PlaylistCollectionItem(
                                        collection: collection,
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      height: 1,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ],
                                ))
                            .toList(),
                        onReorder: (int oldIndex, int newIndex) {
                          setState(() {
                            final PlaylistCollection item =
                                widget.collections.removeAt(oldIndex);
                            widget.collections.insert(newIndex, item);
                          });
                        },
                      )),
            ),
          ],
        ));
  }
}

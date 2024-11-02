import 'package:app_rhyme/common_comps/playlist_collection/playlist_collection_listitem.dart';
import 'package:app_rhyme/pulldown_menus/multi_select/multi_select_playlist_collection_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PlaylistCollectionMultiSelectionPage extends StatefulWidget {
  final List<PlaylistCollection> collections;
  final bool isDesktop;

  const PlaylistCollectionMultiSelectionPage({
    super.key,
    required this.collections,
    required this.isDesktop,
  });

  @override
  PlaylistCollectionMultiSelectionPageState createState() =>
      PlaylistCollectionMultiSelectionPageState();
}

class PlaylistCollectionMultiSelectionPageState
    extends State<PlaylistCollectionMultiSelectionPage>
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

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);
    final double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 16),
          backgroundColor: getNavigatorBarColor(isDarkMode),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              if (context.mounted) popPage(context, widget.isDesktop);
            },
          ),
          trailing: PlaylistCollectionMutiSelectGridPageMenu(
            setState: () => setState(() {}),
            builder: (context, showMenu) => CupertinoButton(
              padding: const EdgeInsets.all(0),
              onPressed: showMenu,
              child: Text(
                '选项',
                style: TextStyle(color: activeIconRed).useSystemChineseFont(),
              ),
            ),
            controller: controller,
            playlistCollections: widget.collections,
          ),
        ),
        Expanded(
          child: widget.collections.isEmpty
              ? Center(
                  child: Text(
                    "没有歌单集合",
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
                    padding: EdgeInsets.only(
                      bottom: 100,
                      top: 10,
                      left: widget.isDesktop ? 0 : 10,
                      right: widget.isDesktop ? 0 : 10,
                    ),
                    itemCount: widget.collections.length,
                    triggerSelectionOnTap: true,
                    itemBuilder: (context, index, selected) {
                      final collection = widget.collections[index];

                      Widget collectionItem = PlaylistCollectionItem(
                        collection: collection,
                        isDarkMode: isDarkMode,
                      );

                      return Column(
                        children: [
                          Row(
                            key: ValueKey("${selected}_${collection.id}"),
                            children: [
                              Expanded(
                                child: collectionItem,
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
                    gridDelegate: const SliverGridDelegateWithFixedRowHeight(
                      rowHeight: 60,
                    ),
                  )),
        )
      ]),
    );
  }
}

class SliverGridDelegateWithFixedRowHeight extends SliverGridDelegate {
  final double rowHeight;

  const SliverGridDelegateWithFixedRowHeight({required this.rowHeight});

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const crossAxisCount = 1;
    final crossAxisExtent = constraints.crossAxisExtent / crossAxisCount;

    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: rowHeight,
      crossAxisStride: crossAxisExtent,
      childMainAxisExtent: rowHeight,
      childCrossAxisExtent: crossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithFixedRowHeight oldDelegate) {
    return oldDelegate.rowHeight != rowHeight;
  }
}

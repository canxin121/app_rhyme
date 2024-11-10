import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';

class PagedMusicAggregatorList extends StatefulWidget {
  final bool isDesktop;
  final PagingController<int, MusicAggregator> pagingController;

  const PagedMusicAggregatorList({
    super.key,
    required this.isDesktop,
    required this.pagingController,
  });

  @override
  PagedMusicAggregatorListState createState() =>
      PagedMusicAggregatorListState();
}

class PagedMusicAggregatorListState extends State<PagedMusicAggregatorList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildDesktopList(BuildContext context, Color textColor,
      double screenHeight, bool isDarkMode) {
    return Column(
      children: [
        if (widget.pagingController.itemList != null &&
            widget.pagingController.itemList!.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: MusicAggregatorListHeaderRow(),
          ),
        Expanded(
            child: PagedListView(
          pagingController: widget.pagingController,
          padding: EdgeInsets.only(bottom: screenHeight * 0.2),
          builderDelegate: PagedChildBuilderDelegate<MusicAggregator>(
            noItemsFoundIndicatorBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '没有找到音乐',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                    ).useSystemChineseFont(),
                  ),
                ],
              ),
            ),
            itemBuilder: (context, musicAggregator, index) {
              return DesktopMusicAggregatorListItem(
                musicAgg: musicAggregator,
                isDarkMode: isDarkMode,
                hasBackgroundColor: (index - 1) % 2 == 0,
              );
            },
          ),
        ))
      ],
    );
  }

  Widget buildMobileList(BuildContext context, Color textColor,
      double screenHeight, bool isDarkMode) {
    return PagedListView.separated(
        pagingController: widget.pagingController,
        padding: EdgeInsets.only(bottom: screenHeight * 0.2),
        separatorBuilder: (context, index) => Divider(
              color: isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey4,
              indent: 30,
              endIndent: 30,
            ),
        builderDelegate: PagedChildBuilderDelegate<MusicAggregator>(
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Center(
              child: Text(
                '没有找到音乐',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                ).useSystemChineseFont(),
              ),
            ),
          ),
          itemBuilder: (context, musicAggregator, index) {
            return MobileMusicAggregatorListItem(
              musicAgg: musicAggregator,
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return widget.isDesktop
        ? buildDesktopList(context, textColor, screenHeight, isDarkMode)
        : buildMobileList(context, textColor, screenHeight, isDarkMode);
  }
}

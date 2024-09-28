import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_container_list_item.dart';
import 'package:app_rhyme/mobile/pages/search_page/combined_search_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

final PagingController<int, MusicAggregator> _pagingController =
    PagingController(firstPageKey: 1);
final TextEditingController _inputContentController = TextEditingController();

class MusicAggregatorSearchPage extends StatefulWidget {
  final bool isDesktop;
  const MusicAggregatorSearchPage({super.key, required this.isDesktop});

  @override
  MusicAggregatorSearchPageState createState() =>
      MusicAggregatorSearchPageState();
}

class MusicAggregatorSearchPageState extends State<MusicAggregatorSearchPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMusicAggregators(pageKey);
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

  Future<void> _fetchMusicAggregators(int pageKey) async {
    try {
      if (_inputContentController.value.text.isEmpty) {
        _pagingController.appendLastPage([]);
        return;
      }

      int originLength = _pagingController.itemList?.length ?? 0;

      _pagingController.value = PagingState<int, MusicAggregator>(
        nextPageKey: pageKey + 1,
        itemList: await MusicAggregator.searchOnline(
          aggs: _pagingController.itemList ?? [],
          servers: MusicServer.all(),
          content: _inputContentController.value.text,
          page: pageKey,
          size: 30,
        ),
      );

      _pagingController.nextPageKey =
          _pagingController.itemList!.length > originLength
              ? pageKey + 1
              : null;
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchAllMusicAggregators() async {
    while (_pagingController.nextPageKey != null) {
      await _fetchMusicAggregators(_pagingController.nextPageKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final ScrollController scrollController = ScrollController();
    return CupertinoPageScaffold(
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      child: Column(
        children: [
          CupertinoNavigationBar(
            backgroundColor: getNavigatorBarColor(isDarkMode),
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '搜索歌曲',
                  style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor)
                      .useSystemChineseFont(),
                ),
              ),
            ),
            trailing: SearchMusicAggregatorChoiceMenu(
              pagingController: _pagingController,
              builder:
                  (BuildContext context, Future<void> Function() showMenu) =>
                      CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                ),
              ),
              fetchAllMusicAggregators: _fetchAllMusicAggregators,
              isDesktop: widget.isDesktop,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
            child: CupertinoSearchTextField(
              style: TextStyle(color: textColor).useSystemChineseFont(),
              controller: _inputContentController,
              onSubmitted: (String value) {
                if (value.isNotEmpty) {
                  _pagingController.refresh();
                }
              },
            ),
          ),
          if (widget.isDesktop &&
              _pagingController.itemList != null &&
              _pagingController.itemList!.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: MusicAggregatorListHeaderRow(),
            ),
          Expanded(
            child: widget.isDesktop
                ? _buildDesktopList(context, scrollController, textColor,
                    screenHeight, isDarkMode)
                : _buildMobileList(context, scrollController, textColor,
                    screenHeight, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopList(
      BuildContext context,
      ScrollController scrollController,
      Color textColor,
      double screenHeight,
      bool isDarkMode) {
    return CupertinoScrollbar(
      thickness: 10,
      radius: const Radius.circular(10),
      controller: scrollController,
      child: PagedListView(
        scrollController: scrollController,
        pagingController: _pagingController,
        padding: EdgeInsets.only(bottom: screenHeight * 0.2),
        builderDelegate: PagedChildBuilderDelegate<MusicAggregator>(
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '输入关键词以搜索单曲',
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
      ),
    );
  }

  Widget _buildMobileList(
      BuildContext context,
      ScrollController scrollController,
      Color textColor,
      double screenHeight,
      bool isDarkMode) {
    return CupertinoScrollbar(
        thickness: 10,
        radius: const Radius.circular(10),
        controller: scrollController,
        child: PagedListView.separated(
          scrollController: scrollController,
          pagingController: _pagingController,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '输入关键词以搜索单曲',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                    ).useSystemChineseFont(),
                  ),
                  Text(
                    '点击右上角图标切换搜索歌单',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                    ).useSystemChineseFont(),
                  ),
                ],
              ),
            ),
            itemBuilder: (context, musicAggregator, index) {
              return MobileMusicAggregatorListItem(
                musicAgg: musicAggregator,
              );
            },
          ),
        ));
  }
}

@immutable
class SearchMusicAggregatorChoiceMenu extends StatelessWidget {
  const SearchMusicAggregatorChoiceMenu({super.key, 
    required this.builder,
    required this.fetchAllMusicAggregators,
    required this.pagingController,
    required this.isDesktop,
  });
  final PagingController<int, MusicAggregator> pagingController;
  final Future<void> Function() fetchAllMusicAggregators;
  final PullDownMenuButtonBuilder builder;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        if (!isDesktop)
          PullDownMenuItem(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            onTap: () {
              globalMobileToggleSearchPage();
            },
            title: "搜索歌单",
            icon: CupertinoIcons.music_albums,
          ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            await fetchAllMusicAggregators();
            LogToast.success(
              "加载所有歌曲",
              "已加载所有歌曲",
              "[SearchMusicAggregatorPage] Succeed to fetch all music aggregators",
            );
          },
          title: "加载所有歌曲",
          icon: CupertinoIcons.music_note_2,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            LogToast.info(
              "多选操作",
              "正在加载所有歌曲,请稍等",
              "[SearchMusicAggregatorPage] Multi select operation, wait to fetch all music aggregators",
            );
            await fetchAllMusicAggregators();
            if (pagingController.itemList == null) return;
            if (pagingController.itemList!.isEmpty) return;
            if (context.mounted) {
              globalSetNavItemSelected("");
              globalNavigatorToPage(
                  MusicAggregatorMultiSelectionPage(
                    musicAggs: pagingController.itemList!,
                    isDesktop: true,
                  ),
                  replace: false);
            }
          },
          title: "多选操作",
          icon: CupertinoIcons.selection_pin_in_out,
        )
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

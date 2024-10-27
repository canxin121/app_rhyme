import 'package:app_rhyme/common_comps/paged/paged_music_agg_listview.dart';
import 'package:app_rhyme/pulldown_menus/musics_playlist_smart_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/search_controllers.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

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
    pagingControllerMusicAggregator.addPageRequestListener((pageKey) {
      fetchItemWithInputPagingController(
          inputController: inputContentController,
          pagingController: pagingControllerMusicAggregator,
          fetchFunction: (
            int page,
            int pageSize,
            String content,
          ) async {
            return await MusicAggregator.searchOnline(
              aggs: pagingControllerMusicAggregator.itemList ?? [],
              servers: MusicServer.all(),
              content: content,
              page: pageKey,
              size: pageSize,
            );
          },
          pageKey: pageKey,
          itemName: '歌曲');
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

  Future<void> _fetchAllMusicAggregators() async {
    await fetchAllItemsWithPagingController((int page, int limit) async {
      return await MusicAggregator.searchOnline(
        aggs: pagingControllerMusicAggregator.itemList ?? [],
        servers: MusicServer.all(),
        content: inputContentController.value.text,
        page: page,
        size: limit,
      );
    }, pagingControllerMusicAggregator, "歌曲");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color primaryColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor:
            widget.isDesktop ? getNavigatorBarColor(isDarkMode) : primaryColor,
        middle: Text(
          '搜索歌曲',
          style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 24, color: textColor)
              .useSystemChineseFont(),
        ),
        trailing: MusicPlaylistSmartPullDownMenu(
          musicAggPageController: pagingControllerMusicAggregator,
          builder: (BuildContext context, Future<void> Function() showMenu) =>
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
      backgroundColor: widget.isDesktop
          ? getPrimaryBackgroundColor(isDarkMode)
          : primaryColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
            child: CupertinoSearchTextField(
              style: TextStyle(color: textColor).useSystemChineseFont(),
              controller: inputContentController,
              onSubmitted: (String value) {
                if (value.isNotEmpty) {
                  pagingControllerMusicAggregator.refresh();
                }
              },
            ),
          ),
          Expanded(
              child: PagedMusicAggregatorList(
                  isDesktop: widget.isDesktop,
                  pagingController: pagingControllerMusicAggregator)),
        ],
      ),
    );
  }
}

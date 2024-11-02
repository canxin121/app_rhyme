import 'package:app_rhyme/common_pages/online_playlist_gridview_page.dart';
import 'package:app_rhyme/pulldown_menus/musics_playlist_smart_pulldown_menu.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/common_comps/paged/paged_music_agg_listview.dart';
import 'package:app_rhyme/common_comps/paged/paged_playlist_gridview.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/search_controllers.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';

enum SearchSegment {
  music,
  playlist,
}

extension SearchSegmentExtension on SearchSegment {
  String get displayName {
    switch (this) {
      case SearchSegment.music:
        return '歌曲';
      case SearchSegment.playlist:
        return '歌单';
      default:
        return '';
    }
  }
}

class SearchPageMobile extends StatefulWidget {
  const SearchPageMobile({super.key});
  @override
  State<SearchPageMobile> createState() => _SearchPageMobileState();
}

class _SearchPageMobileState extends State<SearchPageMobile> {
  SearchSegment _selectedSegment = SearchSegment.music; // 使用枚举
  @override
  void initState() {
    super.initState();
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
          itemName: "歌曲");
    });
    pagingControllerPlaylist.addPageRequestListener((pageKey) {
      fetchItemWithInputPagingController(
          inputController: inputContentController,
          pagingController: pagingControllerPlaylist,
          fetchFunction: (
            int page,
            int pageSize,
            String content,
          ) async {
            return await Playlist.searchOnline(
              servers: MusicServer.all(),
              content: content,
              page: pageKey,
              size: pageSize,
            );
          },
          pageKey: pageKey,
          itemName: "歌单");
    });
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

  Future<void> _fetchAllPlaylists() async {
    await fetchAllItemsWithPagingController((int page, int limit) async {
      return await Playlist.searchOnline(
        servers: [MusicServer.kuwo, MusicServer.netease],
        content: inputContentController.value.text,
        page: page,
        size: limit,
      );
    }, pagingControllerPlaylist, "歌单");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoNavigationBar(
            backgroundColor: getNavigatorBarColor(isDarkMode),
            middle: Text(
              '搜索${_selectedSegment.displayName}', // 使用 displayName 方法展示名称
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textColor,
              ).useSystemChineseFont(),
            ),
            trailing: _selectedSegment == SearchSegment.music
                ? MusicPlaylistSmartPullDownMenu(
                    fetchAllMusicAggregators: _fetchAllMusicAggregators,
                    musicAggPageController: pagingControllerMusicAggregator,
                    builder: (BuildContext context,
                            Future<void> Function() showMenu) =>
                        CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: showMenu,
                            child: Text(
                              '选项',
                              style: TextStyle(color: activeIconRed)
                                  .useSystemChineseFont(),
                            )),
                    isDesktop: false,
                  )
                : SearchPlaylistPullDownMenu(
                    pagingController: pagingControllerPlaylist,
                    builder: (BuildContext context,
                            Future<void> Function() showMenu) =>
                        CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: showMenu,
                            child: Text(
                              '选项',
                              style: TextStyle(color: activeIconRed)
                                  .useSystemChineseFont(),
                            )),
                    fetchAllMusicAggregators: _fetchAllPlaylists,
                    isDesktop: false,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
            child: CupertinoSearchTextField(
              style: TextStyle(color: textColor).useSystemChineseFont(),
              controller: inputContentController,
              onSubmitted: (String value) {
                if (value.isNotEmpty) {
                  if (_selectedSegment == SearchSegment.music) {
                    pagingControllerMusicAggregator.refresh();
                  } else {
                    pagingControllerPlaylist.refresh();
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: CupertinoSlidingSegmentedControl<SearchSegment>(
              groupValue: _selectedSegment,
              onValueChanged: (SearchSegment? value) {
                if (value != null) {
                  setState(() {
                    _selectedSegment = value;
                  });
                }
              },
              children: {
                SearchSegment.music: Text(
                  SearchSegment.music.displayName,
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
                SearchSegment.playlist: Text(
                  SearchSegment.playlist.displayName,
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
              },
            ),
          ),
          Expanded(
            child: _selectedSegment == SearchSegment.music
                ? PagedMusicAggregatorList(
                    isDesktop: false,
                    pagingController: pagingControllerMusicAggregator,
                  )
                : PagedPlaylistGridview(
                    isDesktop: false,
                    pagingController: pagingControllerPlaylist,
                  ),
          ),
        ],
      ),
    );
  }
}

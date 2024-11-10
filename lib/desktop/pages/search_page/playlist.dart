import 'package:app_rhyme/common_comps/paged/paged_playlist_gridview.dart';
import 'package:app_rhyme/common_pages/online_playlist_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/search_controllers.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class PlaylistSearchPage extends StatefulWidget {
  const PlaylistSearchPage({super.key, required this.isDesktop});

  final bool isDesktop;

  @override
  SearchMusicListState createState() => SearchMusicListState();
}

class SearchMusicListState extends State<PlaylistSearchPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pagingControllerPlaylist.addPageRequestListener((pageKey) {
      fetchItemWithInputPagingController(
          inputController: inputContentController,
          pagingController: pagingControllerPlaylist,
          fetchFunction: (
            int page,
            int pageSize,
            String content,
            List<Playlist> playlists,
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  Future<void> _fetchAllMusicLists() async {
    await fetchAllItemsWithPagingController(
        fetchItems: (int page, int limit, List<Playlist> playlists) async {
          return await Playlist.searchOnline(
              servers: [MusicServer.kuwo, MusicServer.netease],
              content: inputContentController.value.text,
              page: page,
              size: limit);
        },
        pagingController: pagingControllerPlaylist,
        itemName: "歌单");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoNavigationBar(
            backgroundColor: getNavigatorBarColor(isDarkMode),
            middle: Text(
              '搜索歌单',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: textColor,
              ).useSystemChineseFont(),
            ),
            trailing: SearchPlaylistPullDownMenu(
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
              fetchAllMusicAggregators: _fetchAllMusicLists,
              pagingController: pagingControllerPlaylist,
              isDesktop: widget.isDesktop,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
            child: CupertinoSearchTextField(
              style: TextStyle(color: textColor).useSystemChineseFont(),
              controller: inputContentController,
              onSubmitted: (String value) {
                if (value.isNotEmpty) {
                  pagingControllerPlaylist.refresh();
                }
              },
            ),
          ),
          Expanded(
            child: PagedPlaylistGridview(
                isDesktop: widget.isDesktop,
                pagingController: pagingControllerPlaylist),
          ),
        ],
      ),
    );
  }
}

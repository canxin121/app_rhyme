import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/desktop/pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/mobile/pages/online_playlist_page.dart';
import 'package:app_rhyme/mobile/pages/search_page/combined_search_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class PlaylistSearchPage extends StatefulWidget {
  const PlaylistSearchPage({super.key, required this.isDesktop});

  final bool isDesktop;

  @override
  SearchMusicListState createState() => SearchMusicListState();
}

class SearchMusicListState extends State<PlaylistSearchPage>
    with WidgetsBindingObserver {
  final PagingController<int, Playlist> _pagingController =
      PagingController(firstPageKey: 1);
  final TextEditingController _inputContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMusicLists(pageKey);
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
    while (_pagingController.nextPageKey != null) {
      await _fetchMusicLists(_pagingController.nextPageKey!);
    }
  }

  Future<void> _fetchMusicLists(int pageKey) async {
    try {
      if (_inputContentController.value.text.isEmpty) {
        _pagingController.appendLastPage([]);
      }
      var musiclists = await Playlist.searchOnline(
          servers: [MusicServer.kuwo, MusicServer.netease],
          content: _inputContentController.value.text,
          page: pageKey,
          size: 30);
      if (musiclists.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        _pagingController.appendPage(musiclists, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final ScrollController scrollController = ScrollController();
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

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
                  '搜索歌单',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: textColor,
                  ).useSystemChineseFont(),
                ),
              ),
            ),
            trailing: SearchPlaylistChoiceMenu(
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
              pagingController: _pagingController,
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
          Expanded(
            child: CupertinoScrollbar(
              thickness: 10,
              radius: const Radius.circular(10),
              controller: scrollController,
              child: PagedGridView(
                scrollController: scrollController,
                padding: EdgeInsets.only(bottom: screenHeight * 0.2),
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Playlist>(
                  noItemsFoundIndicatorBuilder: (context) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '输入关键词以搜索歌单',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          if (!widget.isDesktop)
                            Text(
                              '点击右上角图标切换搜索单曲',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont(),
                            ),
                        ],
                      ),
                    );
                  },
                  itemBuilder: (context, musicListW, index) {
                    return Container(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: widget.isDesktop
                          ? DesktopPlaylistImageCard(
                              showDesc: false,
                              playlist: musicListW,
                              onTap: () {
                                globalNavigatorToPage(
                                  DesktopOnlineMusicListPage(
                                    playlist: musicListW,
                                  ),
                                  replace: false,
                                );
                              },
                            )
                          : MobileMusicListImageCard(
                              showDesc: false,
                              playlist: musicListW,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        MobileOnlineMusicListPage(
                                      playlist: musicListW,
                                    ),
                                  ),
                                );
                              },
                              online: true,
                            ),
                    );
                  },
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.isDesktop ? 4 : 2,
                  childAspectRatio: widget.isDesktop ? 0.9 : 0.8,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class SearchPlaylistChoiceMenu extends StatelessWidget {
  const SearchPlaylistChoiceMenu({
    super.key,
    required this.builder,
    required this.fetchAllMusicAggregators,
    required this.pagingController,
    required this.isDesktop,
  });

  final Future<void> Function() fetchAllMusicAggregators;
  final PagingController<int, Playlist> pagingController;
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
            title: "搜索歌曲",
            icon: CupertinoIcons.double_music_note,
          ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont(),
          ),
          onTap: () => openSharePlaylist(context, isDesktop),
          title: '打开歌单链接',
          icon: CupertinoIcons.link,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont(),
          ),
          onTap: () async {
            await fetchAllMusicAggregators();
            LogToast.success(
              "加载所有歌单",
              "已加载所有歌单",
              "[SearchMusicListPage] Succeed to fetch all music lists",
            );
          },
          title: "加载所有歌单",
          icon: CupertinoIcons.music_note_2,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont(),
          ),
          onTap: () async {
            LogToast.info(
              "多选操作",
              "多选操作,正在加载所有歌单",
              "[SearchMusicListPage] Multi select playlist, going to select playlists",
            );
            await fetchAllMusicAggregators();
            if (pagingController.itemList!.isEmpty) {
              LogToast.error(
                "多选操作",
                "没有查找到歌单",
                "[SearchMusicListPage] No playlists to select",
              );
              return;
            }

            LogToast.success(
              "加载所有歌单",
              "已加载所有歌单",
              "[SearchMusicListPage] Succeed to fetch all music lists",
            );
            if (isDesktop) {
              globalNavigatorToPage(
                PlaylistMultiSelectionPage(
                  playlists: pagingController.itemList!,
                  isDesktop: isDesktop,
                ),
                replace: false,
              );
            } else {
              if (context.mounted) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => PlaylistMultiSelectionPage(
                      playlists: pagingController.itemList!,
                      isDesktop: isDesktop,
                    ),
                  ),
                );
              }
            }
          },
          title: "多选操作",
          icon: CupertinoIcons.music_note_list,
        ),
      ],
      buttonBuilder: builder,
    );
  }
}

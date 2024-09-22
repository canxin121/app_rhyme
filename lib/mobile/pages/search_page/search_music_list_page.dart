import 'package:app_rhyme/mobile/comps/musiclist_comp/playlist_image_card.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/mobile/pages/muti_select_pages/muti_select_online_music_list_gridview_page.dart';
import 'package:app_rhyme/mobile/pages/online_playlist_page.dart';
import 'package:app_rhyme/mobile/pages/search_page/combined_search_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class SearchMusicListPage extends StatefulWidget {
  const SearchMusicListPage({super.key});

  @override
  _SearchMusicListState createState() => _SearchMusicListState();
}

class _SearchMusicListState extends State<SearchMusicListPage>
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
    _pagingController.dispose();
    _inputContentController.dispose();
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

    return CupertinoPageScaffold(
        // 下面地方如果直接使用safeArea会ios上底部有一块空白
        child: Column(
      children: [
        CupertinoNavigationBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '搜索歌单',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ).useSystemChineseFont(),
                ),
              ),
            ),
            trailing: SearchMusicListChoiceMenu(
              builder:
                  (BuildContext context, Future<void> Function() showMenu) =>
                      CupertinoButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: showMenu,
                          child: Text(
                            '选项',
                            style: TextStyle(color: activeIconRed)
                                .useSystemChineseFont(),
                          )),
              fetchAllMusicAggregators: _fetchAllMusicLists,
              openShareMusicList: () async {
                var url = await showInputPlaylistShareLinkDialog(context);
                if (url != null) {
                  var musicListW = await Playlist.getFromShare(share: url);

                  if (context.mounted) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => MobileOnlineMusicListPage(
                                playlist: musicListW,
                              )),
                    );
                  }
                }
              },
              musicListController: _pagingController,
            )),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10.0),
          child: CupertinoSearchTextField(
            style: TextStyle(
              color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ).useSystemChineseFont(),
            controller: _inputContentController,
            onSubmitted: (String value) {
              if (value.isNotEmpty) {
                _pagingController.refresh();
              }
            },
          ),
        ),
        Expanded(
          child: PagedGridView(
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
                        style: TextStyle(
                          color: isDarkMode
                              ? CupertinoColors.systemGrey2
                              : CupertinoColors.black,
                        ).useSystemChineseFont(),
                      ),
                      Text(
                        '点击右上角图标切换搜索单曲',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                                color: isDarkMode
                                    ? CupertinoColors.systemGrey2
                                    : CupertinoColors.black)
                            .useSystemChineseFont(),
                      ),
                    ],
                  ),
                );
              }, itemBuilder: (context, musicListW, index) {
                return Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: MusicListImageCard(
                      showDesc: false,
                      playlist: musicListW,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => MobileOnlineMusicListPage(
                                    playlist: musicListW,
                                  )),
                        );
                      },
                      online: true,
                    ));
              }),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.8)),
        ),
      ],
    ));
  }
}

@immutable
class SearchMusicListChoiceMenu extends StatelessWidget {
  const SearchMusicListChoiceMenu({
    super.key,
    required this.builder,
    required this.openShareMusicList,
    required this.fetchAllMusicAggregators,
    required this.musicListController,
  });

  final void Function() openShareMusicList;
  final Future<void> Function() fetchAllMusicAggregators;
  final PagingController<int, Playlist> musicListController;
  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: globalToggleSearchPage,
          title: '搜索歌曲',
          icon: CupertinoIcons.photo,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: openShareMusicList,
          title: '打开歌单链接',
          icon: CupertinoIcons.link,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
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
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            LogToast.info(
              "多选操作",
              "多选操作,正在加载所有歌单",
              "[SearchMusicListPage] Multi select operation, wait to fetch all music lists",
            );
            await fetchAllMusicAggregators();

            if (musicListController.itemList == null) return;
            if (musicListController.itemList!.isEmpty) return;
            if (context.mounted) {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => MutiSelectOnlineMusicListGridPage(
                    playlists: musicListController.itemList!,
                  ),
                ),
              );
            }
          },
          title: '多选操作',
          icon: CupertinoIcons.selection_pin_in_out,
        ),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

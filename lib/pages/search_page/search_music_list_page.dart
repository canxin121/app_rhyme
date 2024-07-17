import 'package:app_rhyme/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/pages/online_music_list_page.dart';
import 'package:app_rhyme/pages/search_page/combined_search_page.dart';
import 'package:app_rhyme/src/rust/api/bind/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/const_vars.dart';
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
  final PagingController<int, MusicListW> _pagingController =
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
      var musiclists = await OnlineFactoryW.searchMusiclist(
          sources: [sourceAll],
          content: _inputContentController.value.text,
          page: pageKey,
          limit: 30);
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
        navigationBar: CupertinoNavigationBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '搜索歌曲',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
              ),
            ),
            trailing: SearchMusicListChoiceMenu(
              builder:
                  (BuildContext context, Future<void> Function() showMenu) {
                return GestureDetector(
                  child: Text(
                    '选项',
                    style: TextStyle(color: activeIconRed),
                  ),
                  onTapDown: (details) {
                    showMenu();
                  },
                );
              },
              fetchAllMusicAggregators: _fetchAllMusicLists,
              openShareMusicList: () async {
                var url = await showInputPlaylistShareLinkDialog(context);
                if (url != null) {
                  var result =
                      await OnlineFactoryW.getMusiclistFromShare(shareUrl: url);
                  var musicListW = result.$1;
                  var musicAggregators = result.$2;
                  if (context.mounted) {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => OnlineMusicListPage(
                                musicList: musicListW,
                                firstPageMusicAggregators: musicAggregators,
                              )),
                    );
                  }
                }
              },
            )),
        child: SafeArea(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, bottom: 8.0, top: 10.0),
              child: CupertinoSearchTextField(
                style: TextStyle(
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
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
                  builderDelegate: PagedChildBuilderDelegate<MusicListW>(
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
                            ),
                          ),
                          Text(
                            '点击右上角图标切换搜索单曲',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: isDarkMode
                                    ? CupertinoColors.systemGrey2
                                    : CupertinoColors.black),
                          ),
                        ],
                      ),
                    );
                  }, itemBuilder: (context, musicListW, index) {
                    return Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 20),
                        child: MusicListImageCard(
                          musicListW: musicListW,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => OnlineMusicListPage(
                                        musicList: musicListW,
                                      )),
                            );
                          },
                          online: true,
                        ));
                  }),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.7)),
            ),
          ],
        )));
  }
}

@immutable
class SearchMusicListChoiceMenu extends StatelessWidget {
  final void Function() openShareMusicList;
  final Future<void> Function() fetchAllMusicAggregators;
  const SearchMusicListChoiceMenu({
    super.key,
    required this.builder,
    required this.openShareMusicList,
    required this.fetchAllMusicAggregators,
  });

  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: globalToggleSearchPage,
          title: '搜索歌曲',
          icon: CupertinoIcons.photo,
        ),
        PullDownMenuItem(
            onTap: () async {
              await fetchAllMusicAggregators();
              LogToast.success(
                "加载所有歌单",
                "已加载所有歌单",
                "[SearchMusicListPage] Succeed to fetch all music lists",
              );
            },
            title: "加载所有歌单"),
        PullDownMenuItem(
          onTap: openShareMusicList,
          title: '打开歌单链接',
          icon: CupertinoIcons.pencil,
        ),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

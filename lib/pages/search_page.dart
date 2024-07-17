import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/pages/online_music_list_page.dart';
import 'package:app_rhyme/src/rust/api/bind/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class SearchMusicAggregatorPage extends StatefulWidget {
  const SearchMusicAggregatorPage({super.key});

  @override
  _SearchMusicAggregatorPageState createState() =>
      _SearchMusicAggregatorPageState();
}

class _SearchMusicAggregatorPageState extends State<SearchMusicAggregatorPage>
    with WidgetsBindingObserver {
  final PagingController<int, MusicAggregatorW> _pagingController =
      PagingController(firstPageKey: 1);
  final TextEditingController _inputContentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();
  MusicFuzzFilter? filter;
  bool _isFilterSectionVisible = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMusicAggregators(pageKey);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pagingController.dispose();
    _inputContentController.dispose();
    _nameController.dispose();
    _artistController.dispose();
    _albumController.dispose();
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

      _pagingController.value = PagingState<int, MusicAggregatorW>(
          nextPageKey: pageKey + 1,
          itemList: await AggregatorOnlineFactoryW.searchMusicAggregator(
              aggregators:
                  _pagingController.itemList?.map((a) => a.clone()).toList() ??
                      [],
              sources: [sourceAll],
              content: _inputContentController.value.text,
              page: pageKey,
              limit: 30,
              filter: filter));

      _pagingController.nextPageKey =
          _pagingController.itemList!.length > originLength
              ? pageKey + 1
              : null;
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _applyFilter() {
    setState(() {
      // 如果三个输入框都为空，则不应用筛选条件
      if (_nameController.text.isEmpty &&
          _artistController.text.isEmpty &&
          _albumController.text.isEmpty) {
        filter = null;
      } else {
        filter = MusicFuzzFilter(
          name: _nameController.text.isEmpty ? null : _nameController.text,
          artist: _artistController.text.isNotEmpty
              ? _artistController.text.split(',')
              : [],
          album: _albumController.text.isEmpty ? null : _albumController.text,
        );
      }
      _isFilterSectionVisible = false;
    });
    _pagingController.refresh();
  }

  void _clearFilter() {
    setState(() {
      _nameController.clear();
      _artistController.clear();
      _albumController.clear();
      filter = null;
      _isFilterSectionVisible = false;
    });
    _pagingController.refresh();
  }

  void _toggleFilterSection() {
    setState(() {
      _isFilterSectionVisible = !_isFilterSectionVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          const SafeArea(child: SizedBox(height: 0)),
          // 搜索框和过滤按钮
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSearchTextField(
                    style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ).useSystemChineseFont(),
                    controller: _inputContentController,
                    onSubmitted: (String value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _isFilterSectionVisible = false;
                        });
                        _pagingController.refresh();
                      }
                    },
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: _toggleFilterSection,
                  child: const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
          // 编辑 MusicFuzzFilter 的 Section
          if (_isFilterSectionVisible)
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: Text('筛选条件', style: TextStyle(color: textColor)),
                    children: [
                      CupertinoFormRow(
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child:
                              Text('歌曲名', style: TextStyle(color: textColor)),
                        ),
                        child: CupertinoTextField(
                          controller: _nameController,
                          placeholder: '输入曲名',
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child:
                              Text('演唱者', style: TextStyle(color: textColor)),
                        ),
                        child: CupertinoTextField(
                          controller: _artistController,
                          placeholder: '输入演唱者 (多个用逗号分隔)',
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child:
                              Text('专辑名', style: TextStyle(color: textColor)),
                        ),
                        child: CupertinoTextField(
                          controller: _albumController,
                          placeholder: '输入专辑名',
                        ),
                      ),
                      CupertinoFormRow(
                        padding: EdgeInsets.zero,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              onPressed: _applyFilter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CupertinoColors.activeBlue,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Text(
                                  '应用筛选条件',
                                  style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                  ),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              onPressed: _clearFilter,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CupertinoColors.systemRed,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Text(
                                  '清空筛选条件',
                                  style: TextStyle(
                                    color: CupertinoColors.systemRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Expanded(
            child: PagedListView.separated(
              pagingController: _pagingController,
              padding: EdgeInsets.only(bottom: screenHeight * 0.1),
              separatorBuilder: (context, index) => Divider(
                color: isDarkMode
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey4,
                indent: 30,
                endIndent: 30,
              ),
              builderDelegate: PagedChildBuilderDelegate<MusicAggregatorW>(
                noItemsFoundIndicatorBuilder: (context) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '输入关键词以搜索单曲',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode
                                ? CupertinoColors.systemGrey2
                                : CupertinoColors.black,
                          ),
                        ),
                        Text(
                          '点击右上角图标切换搜索歌单',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode
                                ? CupertinoColors.systemGrey2
                                : CupertinoColors.black,
                          ),
                        ),
                        Text(
                          '点击输入框右侧按钮进行设置筛选条件',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode
                                ? CupertinoColors.systemGrey2
                                : CupertinoColors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemBuilder: (context, musicAggregator, index) =>
                    MusicContainerListItem(
                  musicContainer: MusicContainer(musicAggregator),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

    return Column(
      children: [
        const SafeArea(
            child: SizedBox(
          height: 0,
        )),
        // 搜索框
        Padding(
          padding: const EdgeInsets.all(8.0),
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
                        left: 10,
                        right: 10,
                        bottom: 20), // Increased bottom padding
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
    );
  }
}

class CombinedSearchPage extends StatefulWidget {
  const CombinedSearchPage({super.key});

  @override
  _CombinedSearchPageState createState() => _CombinedSearchPageState();
}

class _CombinedSearchPageState extends State<CombinedSearchPage>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  void _onToggle() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % 2;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 添加观察者
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor:
          isDarkMode ? CupertinoColors.black : CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedIndex == 0 ? '搜索单曲' : '搜索歌单',
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
          trailing: ChoiceMenu(
            builder: (BuildContext context, Future<void> Function() showMenu) {
              return GestureDetector(
                child: Text(
                  '选项',
                  style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.systemRed
                          : activeIconRed),
                ),
                onTapDown: (details) {
                  showMenu();
                },
              );
            },
            toggle: _onToggle,
            selectedIndex: _selectedIndex,
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
      child: IndexedStack(
        index: _selectedIndex,
        children: const [
          SearchMusicAggregatorPage(),
          SearchMusicListPage(),
        ],
      ),
    );
  }
}

@immutable
class ChoiceMenu extends StatelessWidget {
  final void Function() toggle;
  final int selectedIndex;
  final void Function() openShareMusicList;
  const ChoiceMenu({
    super.key,
    required this.builder,
    required this.toggle,
    required this.selectedIndex,
    required this.openShareMusicList,
  });

  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: toggle,
          title: selectedIndex == 0 ? '搜索歌单' : '搜索歌曲',
          icon: CupertinoIcons.photo,
        ),
        if (selectedIndex == 1)
          PullDownMenuItem(
            onTap: openShareMusicList,
            title: '打开歌单链接',
            icon: CupertinoIcons.pencil,
          ),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

// ignore_for_file: unused_import

import 'dart:io';

import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/pages/muti_select_pages/muti_select_music_container_listview_page.dart';
import 'package:app_rhyme/pages/search_page/combined_search_page.dart';
import 'package:app_rhyme/src/rust/api/bind/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
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

  Future<void> _fetchAllMusicAggregators() async {
    while (_pagingController.nextPageKey != null) {
      await _fetchMusicAggregators(_pagingController.nextPageKey!);
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
      // 下面地方如果直接使用safeArea会ios上底部有一块空白
      child: Column(
        children: [
          CupertinoNavigationBar(
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
                    ).useSystemChineseFont(),
                  ),
                ),
              ),
              trailing: SearchMusicAggregatroChoiceMenu(
                musicAggregatorController: _pagingController,
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
                fetchAllMusicAggregators: _fetchAllMusicAggregators,
              )),
          // 搜索框和过滤按钮
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 8, right: 0),
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
            CupertinoFormSection.insetGrouped(
              header: Text('筛选条件',
                  style: TextStyle(color: textColor).useSystemChineseFont()),
              children: [
                CupertinoFormRow(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text('歌曲名',
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                  ),
                  child: CupertinoTextField(
                    style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ).useSystemChineseFont(),
                    controller: _nameController,
                    placeholder: '输入曲名',
                  ),
                ),
                CupertinoFormRow(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text('演唱者',
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                  ),
                  child: CupertinoTextField(
                    style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ).useSystemChineseFont(),
                    controller: _artistController,
                    placeholder: '输入演唱者 (多个用逗号分隔)',
                  ),
                ),
                CupertinoFormRow(
                  prefix: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text('专辑名',
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                  ),
                  child: CupertinoTextField(
                    style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ).useSystemChineseFont(),
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
                          child: Text(
                            '应用筛选条件',
                            style: const TextStyle(
                              color: CupertinoColors.activeBlue,
                            ).useSystemChineseFont(),
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
                          child: Text(
                            '清空筛选条件',
                            style: const TextStyle(
                              color: CupertinoColors.systemRed,
                            ).useSystemChineseFont(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                          ).useSystemChineseFont(),
                        ),
                        Text(
                          '点击右上角图标切换搜索歌单',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode
                                ? CupertinoColors.systemGrey2
                                : CupertinoColors.black,
                          ).useSystemChineseFont(),
                        ),
                        Text(
                          '点击输入框右侧按钮进行设置筛选条件',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode
                                ? CupertinoColors.systemGrey2
                                : CupertinoColors.black,
                          ).useSystemChineseFont(),
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

@immutable
class SearchMusicAggregatroChoiceMenu extends StatelessWidget {
  const SearchMusicAggregatroChoiceMenu({
    super.key,
    required this.builder,
    required this.fetchAllMusicAggregators,
    required this.musicAggregatorController,
  });
  final PagingController<int, MusicAggregatorW> musicAggregatorController;
  final Future<void> Function() fetchAllMusicAggregators;
  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: globalToggleSearchPage,
          title: '搜索歌单',
          icon: CupertinoIcons.photo,
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
            if (musicAggregatorController.itemList == null) return;
            if (musicAggregatorController.itemList!.isEmpty) return;
            if (context.mounted) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => MutiSelectMusicContainerListPage(
                      musicContainers: musicAggregatorController.itemList!
                          .map((e) => MusicContainer(e))
                          .toList()),
                ),
              );
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

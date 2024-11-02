import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_aggs_header.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_aggs_header.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/pulldown_menus/musics_playlist_smart_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class OnlineMusicAggregatorListViewPage extends StatefulWidget {
  final Playlist? playlist;
  final List<MusicAggregator>? firstPageMusicAggregators;
  final bool isDesktop;
  final Future<List<MusicAggregator>> Function(int page, int limit)?
      fetchMusicAggregators;
  final String? title;
  final String? summary;
  final String? cover;

  const OnlineMusicAggregatorListViewPage({
    super.key,
    this.playlist,
    this.firstPageMusicAggregators,
    required this.isDesktop,
    this.fetchMusicAggregators,
    this.title,
    this.summary,
    this.cover,
  });

  @override
  OnlineMusicAggregatorListViewPageState createState() =>
      OnlineMusicAggregatorListViewPageState();
}

class OnlineMusicAggregatorListViewPageState
    extends State<OnlineMusicAggregatorListViewPage> {
  final PagingController<int, MusicAggregator> _pagingController =
      PagingController(firstPageKey: 1);

  Future<List<MusicAggregator>> _fetchMusicAggregators(
      int page, int pageSize) async {
    if (widget.playlist != null) {
      return await widget.playlist!.fetchMusicsOnline(page: page, limit: 30);
    } else if (widget.fetchMusicAggregators != null) {
      return widget.fetchMusicAggregators!(page, 30);
    } else {
      throw "must provide 'playlist' or 'fetchMusicAggregators'";
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.firstPageMusicAggregators != null) {
      _pagingController.appendPage(
        widget.firstPageMusicAggregators!,
        2,
      );
    }

    _pagingController.addPageRequestListener((pageKey) async {
      fetchItemWithPagingController(
          pagingController: _pagingController,
          fetchFunction: _fetchMusicAggregators,
          pageKey: pageKey,
          itemName: "歌曲");
    });
  }

  Future<void> _fetchAllMusicAggregators() async {
    await fetchAllItemsWithPagingController(
      _fetchMusicAggregators,
      _pagingController,
      "音乐",
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return widget.isDesktop
        ? _buildDesktop(context, isDarkMode)
        : _buildMobile(context, isDarkMode);
  }

  Widget _buildDesktop(BuildContext context, bool isDarkMode) {
    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
        backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
                backgroundColor: getNavigatorBarColor(isDarkMode),
                middle: Text(
                  widget.playlist?.name ?? widget.title ?? "在线歌曲",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: getTextColor(isDarkMode))
                      .useSystemChineseFont(),
                ),
                leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.back,
                      color: activeIconRed,
                    ),
                    onPressed: () {
                      popPage(context, widget.isDesktop);
                    }),
                trailing: MusicPlaylistSmartPullDownMenu(
                  musicAggPageController: _pagingController,
                  builder: (context, showMenu) => CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: showMenu,
                      child: Text(
                        '选项',
                        style: TextStyle(color: activeIconRed)
                            .useSystemChineseFont(),
                      )),
                  playlist: widget.playlist,
                  fetchAllMusicAggregators: _fetchAllMusicAggregators,
                  isDesktop: widget.isDesktop,
                )),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  if (widget.playlist != null)
                    MusicListHeader(
                      playlist: widget.playlist!,
                      isDarkMode: isDarkMode,
                      screenWidth: screenWidth,
                      fetchAllMusicAggregators: () async {
                        await _fetchAllMusicAggregators();
                        return _pagingController.itemList ?? [];
                      },
                      cacheCover: false,
                      musicAggregators: _pagingController.itemList ?? [],
                    ),
                  if (widget.playlist == null && widget.title != null)
                    DesktopMusicAggsHeader(
                      title: widget.title!,
                      summary: widget.summary,
                      cover: widget.cover,
                      isDarkMode: isDarkMode,
                      screenWidth: screenWidth,
                      fetchAllMusicAggregators: () async {
                        await _fetchAllMusicAggregators();
                        return _pagingController.itemList ?? [];
                      },
                      cacheCover: false,
                      musicAggregators: _pagingController.itemList ?? [],
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                  PagedSliverList(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<MusicAggregator>(
                        noItemsFoundIndicatorBuilder: (context) {
                      return Center(
                        child: Text(
                          '没有找到任何音乐',
                          style: TextStyle(color: getTextColor(isDarkMode))
                              .useSystemChineseFont(),
                        ),
                      );
                    }, itemBuilder: (context, musicAggregator, index) {
                      if (index == 0) {
                        return Column(
                          children: [
                            const MusicAggregatorListHeaderRow(),
                            DesktopMusicAggregatorListItem(
                              musicAgg: musicAggregator,
                              isDarkMode: isDarkMode,
                              hasBackgroundColor: index % 2 == 1,
                            )
                          ],
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 2,
                            bottom: 2,
                          ),
                          child: DesktopMusicAggregatorListItem(
                            musicAgg: musicAggregator,
                            isDarkMode: isDarkMode,
                            hasBackgroundColor: index % 2 == 1,
                          ),
                        );
                      }
                    }),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 200),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  Widget _buildMobile(BuildContext context, bool isDarkMode) {
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);

    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
                backgroundColor: getNavigatorBarColor(isDarkMode),
                middle: Text(
                  widget.playlist?.name ?? widget.title ?? "在线歌曲",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: getTextColor(isDarkMode))
                      .useSystemChineseFont(),
                ),
                leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.back,
                      color: activeIconRed,
                    ),
                    onPressed: () {
                      popPage(context, widget.isDesktop);
                    }),
                trailing: MusicPlaylistSmartPullDownMenu(
                  musicAggPageController: _pagingController,
                  builder: (context, showMenu) => CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: showMenu,
                      child: Text(
                        '选项',
                        style: TextStyle(color: activeIconRed)
                            .useSystemChineseFont(),
                      )),
                  playlist: widget.playlist,
                  fetchAllMusicAggregators: _fetchAllMusicAggregators,
                  isDesktop: widget.isDesktop,
                )),
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  if (widget.playlist != null)
                    MobilePlaylistHeader(
                      playlist: widget.playlist!,
                      musicAggregators: _pagingController.itemList ?? [],
                      fetchAllMusicAggregators: () async {
                        await _fetchAllMusicAggregators();
                        return _pagingController.itemList ?? [];
                      },
                      isDarkMode: isDarkMode,
                    ),
                  if (widget.playlist == null && widget.title != null)
                    MobileMusicAggsHeader(
                      title: widget.title!,
                      summary: widget.summary,
                      cover: widget.cover,
                      isDarkMode: isDarkMode,
                      musicAggregators: [],
                      fetchAllMusicAggregators: () async {
                        await _fetchAllMusicAggregators();
                        return _pagingController.itemList ?? [];
                      },
                    ),
                  PagedSliverList(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<MusicAggregator>(
                        noItemsFoundIndicatorBuilder: (context) {
                      return Center(
                        child: Text(
                          '没有找到任何音乐',
                          style: TextStyle(color: getTextColor(isDarkMode))
                              .useSystemChineseFont(),
                        ),
                      );
                    }, itemBuilder: (context, musicAggregator, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            MobileMusicAggregatorListItem(
                              musicAgg: musicAggregator,
                            ),
                            Divider(
                              color: dividerColor,
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.only(top: 200)),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

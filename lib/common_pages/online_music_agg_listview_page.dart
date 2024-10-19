import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

// must provide playlist or fetchMusicAggregators
class OnlineMusicAggregatorListViewPage extends StatefulWidget {
  final Playlist? playlist;
  final List<MusicAggregator>? firstPageMusicAggregators;
  final bool isDesktop;
  final Future<List<MusicAggregator>> Function(int page, int limit)?
      fetchMusicAggregators;

  const OnlineMusicAggregatorListViewPage({
    super.key,
    this.playlist,
    this.firstPageMusicAggregators,
    required this.isDesktop,
    this.fetchMusicAggregators,
  });

  @override
  OnlineMusicAggregatorListViewPageState createState() =>
      OnlineMusicAggregatorListViewPageState();
}

class OnlineMusicAggregatorListViewPageState
    extends State<OnlineMusicAggregatorListViewPage> {
  final PagingController<int, MusicAggregator> _pagingController =
      PagingController(firstPageKey: 1);

  Future<List<MusicAggregator>> Function(int page, int limit)?
      fetchMusicAggregators;

  @override
  void initState() {
    super.initState();

    if (widget.playlist != null) {
      fetchMusicAggregators = (int page, int limit) async {
        return await widget.playlist!
            .fetchMusicsOnline(page: page, limit: limit);
      };
    } else if (widget.fetchMusicAggregators != null) {
      fetchMusicAggregators = widget.fetchMusicAggregators;
    } else {
      throw Exception("fetchMusicAggregators is null");
    }

    _pagingController.addPageRequestListener((pageKey) async {
      try {
        var aggs = await fetchMusicAggregators!(pageKey, 30);
        if (aggs.isEmpty) {
          _pagingController.appendLastPage([]);
        } else {
          _pagingController.appendPage(aggs, pageKey + 1);
        }
      } catch (error) {
        setState(() {
          _pagingController.error = error;
        });
      }
    });

    if (widget.firstPageMusicAggregators != null) {
      _pagingController.appendPage(
        widget.firstPageMusicAggregators!,
        2,
      );
    }
  }

  Future<void> _fetchAllMusicAggregators() async {
    LogToast.info("加载所有歌单", "正在加载所有歌单,请稍等",
        "[OnlineMusicListPage] MultiSelect wait to fetch all music aggregators");
    const int pageSize = 100;
    try {
      var fetchedPlaylists = await fetchMusicAggregators!(1, pageSize);
      _pagingController.value =
          PagingState(itemList: fetchedPlaylists, nextPageKey: 2);
    } catch (e) {
      _pagingController.error = e;
      return;
    }

    try {
      while (_pagingController.nextPageKey != null) {
        var fetchedPlaylists = await fetchMusicAggregators!(
            _pagingController.nextPageKey!, pageSize);

        if (fetchedPlaylists.isEmpty) {
          _pagingController.appendLastPage([]);
        } else {
          _pagingController.appendPage(
              fetchedPlaylists, _pagingController.nextPageKey! + 1);
        }
      }
    } catch (e) {
      LogToast.error("获取歌曲失败", "获取歌曲失败: $e",
          "[fetchAllMusicAgrgegatorsFromPlaylist] Failed to fetch music from playlist: $e");
    }

    LogToast.success("加载所有歌曲", '已加载所有歌曲',
        "[OnlineMusicListPage] Succeed to fetch all music aggregators");
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return widget.isDesktop
        ? _buildDesktopLayout(context, textColor, isDarkMode)
        : _buildMobileLayout(context, textColor, isDarkMode);
  }

  Widget _buildDesktopLayout(
      BuildContext context, Color textColor, bool isDarkMode) {
    double screenWidth = MediaQuery.of(context).size.width;
    final ScrollController controller = ScrollController();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: getNavigatorBarColor(isDarkMode),
          middle: widget.playlist != null
              ? Text(
                  widget.playlist!.name,
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                )
              : null,
          leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.back,
                color: textColor,
              ),
              onPressed: () {
                popPage(context, widget.isDesktop);
              }),
          trailing: OnlineMusicListChoicMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            playlist: widget.playlist,
            musicAggregatorsController: _pagingController,
            fetchAllMusicAggregators: _fetchAllMusicAggregators,
            isDesktop: widget.isDesktop,
          )),
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      child: CupertinoScrollbar(
          thickness: 10,
          radius: const Radius.circular(10),
          controller: controller,
          child: CustomScrollView(
            controller: controller,
            slivers: <Widget>[
              const SliverToBoxAdapter(
                child: SafeArea(child: SizedBox()),
              ),
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
                      style: TextStyle(color: textColor).useSystemChineseFont(),
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
          )),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, Color textColor, bool isDarkMode) {
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 16),
          backgroundColor: backgroundColor,
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          trailing: OnlineMusicListChoicMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            playlist: widget.playlist,
            musicAggregatorsController: _pagingController,
            fetchAllMusicAggregators: _fetchAllMusicAggregators,
            isDesktop: widget.isDesktop,
          )),
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
          PagedSliverList(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<MusicAggregator>(
                noItemsFoundIndicatorBuilder: (context) {
              return Center(
                child: Text(
                  '没有找到任何音乐',
                  style: TextStyle(color: textColor).useSystemChineseFont(),
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
    );
  }
}

@immutable
class OnlineMusicListChoicMenu extends StatelessWidget {
  const OnlineMusicListChoicMenu({
    super.key,
    required this.builder,
    required this.playlist,
    required this.fetchAllMusicAggregators,
    required this.musicAggregatorsController,
    required this.isDesktop,
  });
  final PagingController<int, MusicAggregator> musicAggregatorsController;
  final PullDownMenuButtonBuilder builder;
  final Playlist? playlist;
  final Future<void> Function() fetchAllMusicAggregators;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        if (playlist != null)
          PullDownMenuHeader(
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            leading: imageWithCache(playlist!.getCover(size: 250),
                height: 100, width: 100),
            title: playlist!.name,
            subtitle: playlist!.summary ?? "",
          ),
        const PullDownMenuDivider.large(),
        if (playlist != null)
          ...playlistMenuItems(context, playlist!, true, true),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: fetchAllMusicAggregators,
          title: "加载所有音乐",
          icon: CupertinoIcons.music_note_2,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (musicAggregatorsController.itemList == null) return;
            if (context.mounted) {
              navigate(
                  context,
                  MusicAggregatorMultiSelectionPage(
                    musicAggs: musicAggregatorsController.itemList!,
                    isDesktop: isDesktop,
                  ),
                  isDesktop,
                  "");
            }
          },
          title: "多选操作",
          icon: CupertinoIcons.selection_pin_in_out,
        )
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

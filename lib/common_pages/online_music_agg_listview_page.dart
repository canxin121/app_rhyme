import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/mobile/comps/chores/button.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class OnlineMusicListPage extends StatefulWidget {
  final Playlist playlist;
  final List<MusicAggregator>? firstPageMusicAggregators;
  final bool isDesktop;

  const OnlineMusicListPage({
    super.key,
    required this.playlist,
    this.firstPageMusicAggregators,
    required this.isDesktop,
  });

  @override
  OnlineMusicListPageState createState() => OnlineMusicListPageState();
}

class OnlineMusicListPageState extends State<OnlineMusicListPage> {
  final PagingController<int, MusicAggregator> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMusicAggregators(pageKey);
    });

    if (widget.firstPageMusicAggregators != null) {
      _pagingController.appendPage(
        widget.firstPageMusicAggregators!,
        2,
      );
    }
  }

  Future<void> _fetchAllMusics() async {
    LogToast.info("加载所有音乐", "正在加载所有音乐,请稍等",
        "[OnlineMusicListPage] MultiSelect wait to fetch all music aggregators");
    var allMusicAggregators =
        await widget.playlist.fetchMusicsOnline(page: 1, limit: 2333);
    _pagingController.itemList = allMusicAggregators;
    _pagingController.appendLastPage([]);
    LogToast.success("加载所有音乐", '已加载所有音乐',
        "[OnlineMusicListPage] Succeed to fetch all music aggregators");
  }

  Future<void> _fetchMusicAggregators(int pageKey) async {
    try {
      var aggs =
          await widget.playlist.fetchMusicsOnline(page: pageKey, limit: 30);
      if (aggs.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        _pagingController.appendPage(
          aggs,
          pageKey + 1,
        );
      }
    } catch (error) {
      _pagingController.error = error;
    }
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
        middle: Text(
          widget.playlist.name,
          style: TextStyle(color: textColor).useSystemChineseFont(),
        ),
        leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.back,
              color: textColor,
            ),
            onPressed: () {
              globalDesktopPopPage();
            }),
      ),
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
              MusicListHeader(
                playlist: widget.playlist,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
                pagingController: _pagingController,
                fetchAllMusicAggregators: _fetchAllMusics,
                cacheCover: false,
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
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);
    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 16),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          trailing: OnlineMusicListChoicMenu(
            builder: (context, showMenu) => GestureDetector(
              child: Text(
                '选项',
                style: TextStyle(color: activeIconRed).useSystemChineseFont(),
              ),
              onTapDown: (details) {
                showMenu();
              },
            ),
            playlist: widget.playlist,
            musicAggregatorsController: _pagingController,
            fetchAllMusicAggregators: _fetchAllMusics,
          )),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.1,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1),
                child: SafeArea(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.7,
                    ),
                    child: MobilePlaylistImageCard(
                      playlist: widget.playlist,
                    ),
                  ),
                )),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton(
                    context,
                    icon: CupertinoIcons.play_fill,
                    label: '播放全部',
                    onPressed: () async {
                      await _fetchAllMusics();
                      if (_pagingController.itemList != null &&
                          _pagingController.itemList!.isNotEmpty) {
                        globalAudioHandler.clearReplaceMusicAll(
                            _pagingController.itemList!
                                .map((a) => MusicContainer(a))
                                .toList());
                      }
                    },
                  ),
                  buildButton(
                    context,
                    icon: Icons.shuffle,
                    label: '随机播放',
                    onPressed: () async {
                      await _fetchAllMusics();
                      if (_pagingController.itemList != null &&
                          _pagingController.itemList!.isNotEmpty) {
                        await globalAudioHandler.clearReplaceMusicAll(
                            _pagingController.itemList!
                                .map((a) => MusicContainer(a))
                                .toList());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider()),
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
                    if (index == 0) const MusicAggregatorListHeaderRow(),
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
  });
  final PagingController<int, MusicAggregator> musicAggregatorsController;
  final PullDownMenuButtonBuilder builder;
  final Playlist playlist;
  final Future<void> Function() fetchAllMusicAggregators;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          leading: imageWithCache(playlist.getCover(size: 250),
              height: 100, width: 100),
          title: playlist.name,
          subtitle: playlist.summary ?? "",
        ),
        const PullDownMenuDivider.large(),
        ...playlistMenuItems(context, playlist, true, true),
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
            LogToast.info("多选操作", "正在加载所有音乐,请稍等",
                "[OnlineMusicListPage] MultiSelect wait to fetch all music aggregators");
            await fetchAllMusicAggregators();
            if (musicAggregatorsController.itemList == null) return;

            if (context.mounted) {
              globalDesktopNavigatorToPage(
                  MusicAggregatorMultiSelectionPage(
                    musicAggs: musicAggregatorsController.itemList!,
                    isDesktop: true,
                  ),
                  replace: false);
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

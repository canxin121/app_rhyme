import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/musiclist_comp/musiclist_header.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/home.dart';
import 'package:app_rhyme/desktop/pages/muti_select_pages/muti_select_music_container_listview_page.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class DesktopOnlineMusicListPage extends StatefulWidget {
  final Playlist playlist;
  final List<MusicAggregator>? firstPageMusicAggregators;

  const DesktopOnlineMusicListPage(
      {super.key, required this.playlist, this.firstPageMusicAggregators});

  @override
  DesktopOnlineMusicListPageState createState() =>
      DesktopOnlineMusicListPageState();
}

class DesktopOnlineMusicListPageState
    extends State<DesktopOnlineMusicListPage> {
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
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    double screenWidth = MediaQuery.of(context).size.width;

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
              if (globalDesktopPageContext.mounted) {
                Navigator.of(globalDesktopPageContext).pop();
              }
            }),
      ),
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      child: CustomScrollView(
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
                    MusicAggregatorListItem(
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
                  child: MusicAggregatorListItem(
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
          leading: imageWithCache(playlist.cover),
          title: playlist.name,
          subtitle: playlist.summary ?? "",
        ),
        const PullDownMenuDivider.large(),
        ...onlineMusicListItems(context, playlist),
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
              globalNavigatorToPage(DesktopMutiSelectMusicContainerListPage(
                  musicAggs: musicAggregatorsController.itemList!));
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

import 'package:app_rhyme/common_comps/paged/paged_playlist_gridview.dart';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class OnlinePlaylistGridViewPage extends StatefulWidget {
  const OnlinePlaylistGridViewPage(
      {super.key,
      required this.isDesktop,
      required this.fetchPlaylists,
      this.title = "在线歌单"});
  final String title;
  final Future<List<Playlist>> Function(int page, int limit) fetchPlaylists;
  final bool isDesktop;

  @override
  SearchMusicListState createState() => SearchMusicListState();
}

class SearchMusicListState extends State<OnlinePlaylistGridViewPage>
    with WidgetsBindingObserver {
  final PagingController<int, Playlist> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pagingController.addPageRequestListener((pageKey) async {
      if (_pagingController.nextPageKey == null) return;
      try {
        var fetchedPlaylists = await widget.fetchPlaylists(pageKey, 30);
        _pagingController.appendPage(
            fetchedPlaylists, _pagingController.nextPageKey! + 1);
      } catch (e) {
        _pagingController.error = e;
      }
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

  Future<void> _fetchAllPlaylists() async {
    LogToast.info("加载所有歌单", "正在加载所有歌单,请稍等",
        "[OnlineMusicListPage] MultiSelect wait to fetch all music aggregators");
    const int pageSize = 500;

    try {
      var fetchedPlaylists = await widget.fetchPlaylists(1, pageSize);
      _pagingController.value =
          PagingState(itemList: fetchedPlaylists, nextPageKey: 2);
    } catch (e) {
      _pagingController.error = e;
      return;
    }

    try {
      while (_pagingController.nextPageKey != null) {
        var fetchedPlaylists = await widget.fetchPlaylists(
            _pagingController.nextPageKey!, pageSize);

        if (fetchedPlaylists.isEmpty) {
          _pagingController.appendLastPage([]);
        } else {
          _pagingController.appendPage(
              fetchedPlaylists, _pagingController.nextPageKey! + 1);
        }
      }
    } catch (e) {
      LogToast.error("获取歌单失败", "获取歌单失败: $e",
          "[fetchAllMusicAgrgegatorsFromPlaylist] Failed to fetch music from playlist: $e");
    }

    LogToast.success("加载所有歌单", '已加载所有歌单',
        "[OnlineMusicListPage] Succeed to fetch all music aggregators");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final ScrollController scrollController = ScrollController();
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color primaryColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor:
            widget.isDesktop ? getNavigatorBarColor(isDarkMode) : primaryColor,
        leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.back,
              color: activeIconRed,
            ),
            onPressed: () {
              popPage(context, widget.isDesktop);
            }),
        middle: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: textColor,
          ).useSystemChineseFont(),
        ),
        trailing: SearchPlaylistChoiceMenu(
          builder: (BuildContext context, Future<void> Function() showMenu) =>
              CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: showMenu,
            child: Text(
              '选项',
              style: TextStyle(color: activeIconRed).useSystemChineseFont(),
            ),
          ),
          fetchAllMusicAggregators: _fetchAllPlaylists,
          pagingController: _pagingController,
          isDesktop: widget.isDesktop,
        ),
      ),
      backgroundColor: widget.isDesktop
          ? getPrimaryBackgroundColor(isDarkMode)
          : primaryColor,
      child: Column(
        children: [
          Expanded(
            child: CupertinoScrollbar(
              thickness: 10,
              radius: const Radius.circular(10),
              controller: scrollController,
              child: PagedPlaylistGridview(
                  isDesktop: widget.isDesktop,
                  pagingController: _pagingController),
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
            if (!context.mounted) return;
            navigate(
                context,
                PlaylistMultiSelectionPage(
                  playlists: pagingController.itemList!,
                  isDesktop: isDesktop,
                ),
                isDesktop,
                "");
          },
          title: "多选操作",
          icon: CupertinoIcons.music_note_list,
        ),
      ],
      buttonBuilder: builder,
    );
  }
}

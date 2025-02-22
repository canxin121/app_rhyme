import 'package:app_rhyme/common_comps/paged/paged_playlist_gridview.dart';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
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
  final Future<List<Playlist>> Function(
      int page, int limit, List<Playlist> playlists) fetchPlaylists;
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
        var fetchedPlaylists = await widget.fetchPlaylists(pageKey, 30, []);
        _pagingController.appendPage(
            fetchedPlaylists, _pagingController.nextPageKey! + 1);
      } catch (e) {
        LogToast.error("获取歌单", "获取歌单失败: $e",
            "[OnlinePlaylistGridViewPage] failed to get playlists: $e");
        _pagingController.appendLastPage([]);
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
    await fetchAllItemsWithPagingController(
      fetchItems: widget.fetchPlaylists,
      pagingController: _pagingController,
      itemName: "歌单",
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoNavigationBar(
            backgroundColor: getNavigatorBarColor(isDarkMode),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: textColor,
              ).useSystemChineseFont(),
            ),
            trailing: SearchPlaylistPullDownMenu(
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
              fetchAllMusicAggregators: _fetchAllPlaylists,
              pagingController: _pagingController,
              isDesktop: widget.isDesktop,
            ),
          ),
          Expanded(
            child: PagedPlaylistGridview(
                isDesktop: widget.isDesktop,
                pagingController: _pagingController),
          ),
        ],
      ),
    );
  }
}

@immutable
class SearchPlaylistPullDownMenu extends StatelessWidget {
  const SearchPlaylistPullDownMenu({
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

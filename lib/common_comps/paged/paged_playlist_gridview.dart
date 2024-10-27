import 'package:app_rhyme/common_comps/card/playlist_card.dart';
import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagedPlaylistGridview extends StatefulWidget {
  final bool isDesktop;
  final PagingController<int, Playlist> pagingController;
  const PagedPlaylistGridview(
      {super.key, required this.isDesktop, required this.pagingController});

  @override
  State<StatefulWidget> createState() {
    return PagedPlaylistGridviewState();
  }
}

class PagedPlaylistGridviewState extends State<PagedPlaylistGridview> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onTap(Playlist playlist) {
    navigate(
        context,
        OnlineMusicAggregatorListViewPage(
          playlist: playlist,
          isDesktop: widget.isDesktop,
        ),
        widget.isDesktop,
        "");
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;

    return PagedGridView(
      scrollController: scrollController,
      padding: EdgeInsets.only(bottom: screenHeight * 0.2, top: 20),
      pagingController: widget.pagingController,
      builderDelegate: PagedChildBuilderDelegate<Playlist>(
        noItemsFoundIndicatorBuilder: (context) {
          return Center(
            child: Text(
              '没有找到歌单',
              textAlign: TextAlign.center,
              style: TextStyle(color: getTextColor(isDarkMode))
                  .useSystemChineseFont(),
            ),
          );
        },
        itemBuilder: (context, playlist, index) {
          return Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: PlaylistCard(
                  playlist: playlist,
                  onTap: () {
                    onTap(playlist);
                  }));
        },
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.isDesktop ? 4 : 2,
        childAspectRatio: 0.8,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
    );
  }
}

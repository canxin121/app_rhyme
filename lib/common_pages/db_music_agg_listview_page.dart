import 'dart:async';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/pulldown_menus/items/music_aggregators.dart';
import 'package:app_rhyme/pulldown_menus/musics_playlist_smart_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class DbMusicContainerListPage extends StatefulWidget {
  final Playlist playlist;
  final bool isDesktop;

  const DbMusicContainerListPage({
    super.key,
    required this.playlist,
    required this.isDesktop,
  });

  @override
  DbMusicContainerListPageState createState() =>
      DbMusicContainerListPageState();
}

class DbMusicContainerListPageState extends State<DbMusicContainerListPage>
    with WidgetsBindingObserver {
  late Playlist playlist;
  List<MusicAggregator> musicAggs = [];
  late StreamSubscription<String> musicAggrgatorsPageRefreshStreamSubscription;
  late StreamSubscription<Playlist> playlistUpdateSubscription;
  late StreamSubscription<String> musicAggregatorDeleteStreamSubscription;
  late StreamSubscription<void> popPageSubscription;

  @override
  void initState() {
    playlist = widget.playlist;
    WidgetsBinding.instance.addObserver(this);

    playlistUpdateSubscription =
        playlistUpdateStreamController.stream.listen((newPlaylist) {
      setState(() {
        playlist = newPlaylist;
      });
    });

    musicAggrgatorsPageRefreshStreamSubscription =
        musicAggrgatorsPageRefreshStreamController.stream.listen((id) {
      if (id == widget.playlist.identity) {
        widget.playlist.getMusicsFromDb().then((newMusicAggs) {
          setState(() {
            musicAggs = newMusicAggs;
          });
        });
      }
    });

    musicAggregatorDeleteStreamSubscription =
        musicAggregatorDeleteStreamController.stream.listen((mId) {
      setState(() {
        musicAggs.removeWhere((element) => element.identity() == mId);
      });
    });

    popPageSubscription = dbPlaylistPagePopStreamController.stream.listen((_) {
      if (!mounted) return;
      popPage(context, widget.isDesktop);
    });

    loadMusicContainers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    musicAggrgatorsPageRefreshStreamSubscription.cancel();
    playlistUpdateSubscription.cancel();
    popPageSubscription.cancel();
    musicAggregatorDeleteStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  Future<void> loadMusicContainers() async {
    try {
      var newMuiscAggs = await playlist.getMusicsFromDb();

      setState(() {
        musicAggs = newMuiscAggs;
      });
    } catch (e) {
      LogToast.error("加载歌曲列表", "加载歌曲列表失败!:$e",
          "[loadMusicContainers] Failed to load music list: $e");
      setState(() {
        musicAggs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return widget.isDesktop
        ? _buildDesktopLayout(isDarkMode, widget.isDesktop)
        : _buildMobileLayout(isDarkMode, widget.isDesktop);
  }

  Widget _buildMobileLayout(bool isDarkMode, bool isDesktop) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
        backgroundColor: getBackgroundColor(isDesktop, isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
                padding: const EdgeInsetsDirectional.only(end: 16),
                backgroundColor: getNavigatorBarColor(isDarkMode),
                leading: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Icon(CupertinoIcons.back, color: activeIconRed),
                  onPressed: () {
                    popPage(context, isDesktop);
                  },
                ),
                middle: Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(isDarkMode),
                  ).useSystemChineseFont(),
                ),
                trailing: DbMusicListChoicMenu(
                  isDesktop: widget.isDesktop,
                  builder: (context, showMenu) => CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: showMenu,
                      child: Text(
                        '选项',
                        style: TextStyle(color: activeIconRed)
                            .useSystemChineseFont(),
                      )),
                  playlist: playlist,
                  musicAggs: musicAggs,
                )),
            Expanded(
                child: CustomScrollView(
              slivers: <Widget>[
                MobilePlaylistHeader(
                    playlist: playlist,
                    musicAggregators: musicAggs,
                    isDarkMode: isDarkMode),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      bool isFirst = index == 0;
                      bool isLastItem = index == musicAggs.length - 1;

                      final musicAgg = musicAggs[index];
                      return Column(
                        children: [
                          if (isFirst)
                            const Padding(padding: EdgeInsets.only(top: 5)),
                          Padding(
                            padding: const EdgeInsets.only(top: 5, bottom: 5),
                            child: MobileMusicAggregatorListItem(
                              key: ValueKey(musicAgg.identity()),
                              musicAgg: musicAgg,
                              playlist: widget.playlist,
                              cacheCover: globalConfig.storageConfig.saveCover,
                            ),
                          ),
                          if (!isLastItem)
                            Center(
                              child: SizedBox(
                                width: screenWidth * 0.85,
                                child: Divider(
                                  color: getDividerColor(isDarkMode),
                                  height: 0.5,
                                ),
                              ),
                            )
                        ],
                      );
                    },
                    childCount: musicAggs.length,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 200),
                  ),
                ),
              ],
            )),
          ],
        ));
  }

  Widget _buildDesktopLayout(bool isDarkMode, bool isDesktop) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
        backgroundColor: getBackgroundColor(isDesktop, isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
                padding: const EdgeInsetsDirectional.only(end: 16),
                backgroundColor: getBackgroundColor(isDesktop, isDarkMode),
                middle: Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(isDarkMode),
                  ).useSystemChineseFont(),
                ),
                leading: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Icon(CupertinoIcons.back, color: activeIconRed),
                  onPressed: () {
                    popPage(context, isDesktop);
                  },
                ),
                trailing: DbMusicListChoicMenu(
                  isDesktop: widget.isDesktop,
                  builder: (context, showMenu) => CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: showMenu,
                      child: Text(
                        '选项',
                        style: TextStyle(color: activeIconRed)
                            .useSystemChineseFont(),
                      )),
                  playlist: playlist,
                  musicAggs: musicAggs,
                )),
            Expanded(
                child: CustomScrollView(
              slivers: <Widget>[
                MusicListHeader(
                  playlist: playlist,
                  musicAggregators: musicAggs,
                  isDarkMode: isDarkMode,
                  screenWidth: screenWidth,
                  cacheCover: globalConfig.storageConfig.saveCover,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                MusicAggregatorList(
                  musicAggs: musicAggs,
                  playlist: playlist,
                  cacheCover: globalConfig.storageConfig.saveCover,
                ),
              ],
            )),
          ],
        ));
  }
}

@immutable
class DbMusicListChoicMenu extends StatelessWidget {
  const DbMusicListChoicMenu({
    super.key,
    required this.builder,
    required this.playlist,
    required this.musicAggs,
    required this.isDesktop,
  });

  final PullDownMenuButtonBuilder builder;
  final Playlist playlist;
  final List<MusicAggregator> musicAggs;
  final bool isDesktop;

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
          subtitle: playlist.summary,
        ),
        const PullDownMenuDivider.large(),
        ...musicPlaylistMenuSmartItems(context, playlist, false, true),
        // 缓存所有音乐
        cacheAllMusicAggsPullDownItem(
          context,
          musicAggs,
        ),
        // 删除所有音乐缓存
        deleteAllMusicAggsCachePullDownItem(musicAggs),
        // 歌曲排序
        orderMusicAggsPullDownItem(context, musicAggs, playlist, isDesktop),
        // 歌曲多选
        multiSelectMusicAggsPullDownItem(
            context, musicAggs, playlist, isDesktop),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

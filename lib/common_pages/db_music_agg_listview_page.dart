import 'dart:async';
import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/reorder_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/mobile/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
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
        setState(() async {
          musicAggs = await widget.playlist.getMusicsFromDb();
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
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);
    final double screenWidth = MediaQuery.of(context).size.width;

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
          trailing: DbMusicListChoicMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            playlist: playlist,
            musicAggs: musicAggs,
          )),
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
                            color: dividerColor,
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
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDarkMode, bool isDesktop) {
    final ScrollController controller = ScrollController();
    final double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 16),
          backgroundColor: getPrimaryBackgroundColor(isDarkMode),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              popPage(context, isDesktop);
            },
          ),
          trailing: DbMusicListChoicMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            playlist: playlist,
            musicAggs: musicAggs,
          )),
      child: CupertinoScrollbar(
        controller: controller,
        thickness: 10,
        radius: const Radius.circular(10),
        child: CustomScrollView(
          controller: controller,
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
        ),
      ),
    );
  }
}

@immutable
class DbMusicListChoicMenu extends StatelessWidget {
  const DbMusicListChoicMenu({
    super.key,
    required this.builder,
    required this.playlist,
    required this.musicAggs,
  });

  final PullDownMenuButtonBuilder builder;
  final Playlist playlist;
  final List<MusicAggregator> musicAggs;

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
        ...playlistMenuItems(context, playlist, false, true),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            for (var musicAgg in musicAggs) {
              await cacheMusicContainer(MusicContainer(musicAgg));
            }
          },
          title: '缓存歌单所有音乐',
          icon: CupertinoIcons.cloud_download,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            for (var musicAgg in musicAggs) {
              await delMusicCache(musicAgg, showToast: false);
            }
            LogToast.success("删除所有音乐缓存", "删除所有音乐缓存成功",
                "[LocalMusicListChoicMenu] Successfully deleted all music caches");
          },
          title: '删除所有音乐缓存',
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => MuiscAggregatorReorderPage(
                  musicAggregators: musicAggs,
                  playlist: playlist,
                  isDesktop: false,
                ),
              ),
            );
          },
          title: "歌曲排序",
          icon: CupertinoIcons.sort_up_circle,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => MusicAggregatorMultiSelectionPage(
                  playlist: playlist,
                  musicAggs: musicAggs,
                  isDesktop: false,
                ),
              ),
            );
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

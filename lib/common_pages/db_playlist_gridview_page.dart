import 'dart:async';
import 'dart:io';
import 'package:app_rhyme/common_pages/db_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/comps/delegate.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/pulldown_menus/playlist_gridview_page_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class DbPlaylistGridPage extends StatefulWidget {
  final bool isDesktop;
  final PlaylistCollection playlistCollection;
  final List<Playlist> playlists;

  const DbPlaylistGridPage({
    super.key,
    required this.isDesktop,
    required this.playlists,
    required this.playlistCollection,
  });

  @override
  DbPlaylistGridPageState createState() => DbPlaylistGridPageState();
}

class DbPlaylistGridPageState extends State<DbPlaylistGridPage>
    with WidgetsBindingObserver {
  late List<Playlist> playlists;
  late PlaylistCollection playlistCollection;

  late StreamSubscription<int> playlistsPageRefreshStreamSubscription;
  late StreamSubscription<Playlist> playlistUpdateStreamSubscription;
  late StreamSubscription<PlaylistCollection>
      playlistCollectionUpdateStreamSubscription;
  late StreamSubscription<String> playlistDeleteStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    playlistCollection = widget.playlistCollection;
    playlists = widget.playlists;

    playlistsPageRefreshStreamSubscription =
        playlistsPageRefreshStreamController.stream.listen((id) {
      if (id == widget.playlistCollection.id) {
        widget.playlistCollection.getPlaylistsFromDb().then((ps) {
          setState(() {
            playlists = ps;
          });
        });
      }
    });

    playlistUpdateStreamSubscription =
        playlistUpdateStreamController.stream.listen((p) {
      var index =
          playlists.indexWhere((element) => element.identity == p.identity);
      if (index != -1) {
        setState(() {
          playlists[index] = p;
        });
      }
    });

    playlistCollectionUpdateStreamSubscription =
        playlistCollectionUpdateStreamController.stream.listen((pc) {
      if (pc.id == playlistCollection.id) {
        setState(() {
          playlistCollection = pc;
        });
      }
    });

    playlistDeleteStreamSubscription =
        playlistDeleteStreamController.stream.listen((id) {
      var index = playlists.indexWhere((element) => element.identity == id);
      if (index != -1) {
        setState(() {
          playlists.removeAt(index);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    playlistsPageRefreshStreamSubscription.cancel();
    playlistUpdateStreamSubscription.cancel();
    playlistCollectionUpdateStreamSubscription.cancel();

    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return widget.isDesktop
        ? buildDesktopUI(isDarkMode)
        : buildMobileUI(isDarkMode);
  }

  /// 桌面端 UI 构建
  Widget buildDesktopUI(bool isDarkMode) {
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color navigatorBarColor = getNavigatorBarColor(isDarkMode);
    final ScrollController controller = ScrollController();

    return CupertinoPageScaffold(
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      child: Column(
        children: [
          CupertinoNavigationBar(
            backgroundColor: navigatorBarColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  playlistCollection.name,
                  style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor)
                      .useSystemChineseFont(),
                ),
              ),
            ),
            trailing: PlaylistGridPageMenu(
              playlists: playlists,
              builder: (context, showMenu) => CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: showMenu,
                  child: Text(
                    '选项',
                    style:
                        TextStyle(color: activeIconRed).useSystemChineseFont(),
                  )),
              isDesktop: true,
              playlistCollection: playlistCollection,
            ),
          ),
          Expanded(
            child: playlists.isEmpty
                ? Center(
                    child: Text("没有歌单",
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                  )
                : buildDesktopGrid(controller, textColor),
          ),
        ],
      ),
    );
  }

  /// 移动端 UI 构建
  Widget buildMobileUI(bool isDarkMode) {
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  playlistCollection.name,
                  style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: textColor)
                      .useSystemChineseFont(),
                ),
              ),
            ),
            trailing: PlaylistGridPageMenu(
              playlists: playlists,
              builder: (context, showMenu) => CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: showMenu,
                  child: Text(
                    '选项',
                    style:
                        TextStyle(color: activeIconRed).useSystemChineseFont(),
                  )),
              isDesktop: false,
              playlistCollection: playlistCollection,
            ),
          ),
          Expanded(
            child: playlists.isEmpty
                ? Center(
                    child: Text("没有歌单",
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                  )
                : buildMobileGrid(textColor),
          ),
        ],
      ),
    );
  }

  Widget buildDesktopGrid(ScrollController controller, Color textColor) {
    return SafeArea(
      child: CupertinoScrollbar(
        thickness: 10,
        radius: const Radius.circular(10),
        controller: controller,
        child: CustomScrollView(
          controller: controller,
          slivers: [
            SliverPadding(
              padding:
                  EdgeInsets.symmetric(horizontal: Platform.isIOS ? 0.0 : 10.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithResponsiveColumnCount(
                  minColumnWidth: 200.0,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  minColumnCount: 4,
                  maxColumnCount: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    var musicList = playlists[index];
                    return DesktopPlaylistImageCard(
                      key: ValueKey(musicList.identity),
                      playlist: musicList,
                      showDesc: false,
                      onTap: () {
                        navigate(
                            context,
                            DbMusicContainerListPage(
                              playlist: musicList,
                              isDesktop: widget.isDesktop,
                            ),
                            widget.isDesktop,
                            "###Playlist_${musicList.identity}###");
                      },
                      cacheCover: globalConfig.storageConfig.saveCover,
                    );
                  },
                  childCount: playlists.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileGrid(Color textColor) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding:
              EdgeInsets.symmetric(horizontal: Platform.isIOS ? 0.0 : 10.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                var playlisy = playlists[index];
                return MobilePlaylistImageCard(
                  key: ValueKey(playlisy.identity),
                  playlist: playlisy,
                  showDesc: false,
                  cacheCover: globalConfig.storageConfig.saveCover,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => DbMusicContainerListPage(
                          playlist: playlisy,
                          isDesktop: false,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: playlists.length,
            ),
          ),
        ),
      ],
    );
  }
}

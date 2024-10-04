import 'dart:async';
import 'dart:io';
import 'package:app_rhyme/common_pages/db_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/comps/delegate.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/pulldown_menus/playlist_gridview_page_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class DbMusicListGridPage extends StatefulWidget {
  final bool isDesktop;

  const DbMusicListGridPage({
    super.key,
    required this.isDesktop,
  });

  @override
  DbMusicListGridPageState createState() => DbMusicListGridPageState();
}

class DbMusicListGridPageState extends State<DbMusicListGridPage>
    with WidgetsBindingObserver {
  List<Playlist> playlists = [];
  late StreamSubscription<List<Playlist>> playlistGridUpdateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    playlistGridUpdateSubscription =
        playlistGridUpdateStreamController.stream.listen((e) {
      setState(() {
        playlists = e;
      });
    });
    Playlist.getFromDb().then((e) => setState(() {
          playlists = e;
        }));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    playlistGridUpdateSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void loadMusicLists() async {
    try {
      List<Playlist> loadedLists = await Playlist.getFromDb();
      setState(() {
        playlists = loadedLists;
      });
    } catch (e) {
      LogToast.error("加载歌单列表", "加载歌单列表失败: $e",
          "[loadMusicLists] Failed to load music lists: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor = isDarkMode
        ? getPrimaryBackgroundColor(isDarkMode)
        : CupertinoColors.white;
    final Color navigatorBarColor = getNavigatorBarColor(isDarkMode);
    final ScrollController controller = ScrollController();

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          CupertinoNavigationBar(
            backgroundColor: navigatorBarColor,
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment:
                    widget.isDesktop ? Alignment.center : Alignment.centerLeft,
                child: Text(
                  widget.isDesktop ? '所有播放列表' : '资料库',
                  style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: widget.isDesktop ? 16 : 24,
                          color: textColor)
                      .useSystemChineseFont(),
                ),
              ),
            ),
            trailing: MusicListGridPageMenu(
              playlists: playlists,
              builder: (context, showMenu) => CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: showMenu,
                  child: Text(
                    '选项',
                    style:
                        TextStyle(color: activeIconRed).useSystemChineseFont(),
                  )),
              isDesktop: widget.isDesktop,
            ),
          ),
          Expanded(
            child: playlists.isEmpty
                ? Center(
                    child: Text("没有歌单",
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                  )
                : widget.isDesktop
                    ? buildDesktopGrid(controller, textColor)
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
                        globalSetNavItemSelected(
                            "###Playlist_${musicList.identity}###");
                        globalDesktopNavigatorToPage(
                          DbMusicContainerListPage(
                            playlist: musicList,
                            isDesktop: true,
                          ),
                        );
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

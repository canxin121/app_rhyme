import 'dart:io';
import 'package:app_rhyme/pulldown_menus/playlist_gridview_page_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/mobile/pages/db_music_aggregator_listview_page.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

void Function() globalMobileMusicListGridPageRefreshFunction = () {};

class LocalMusicListGridPage extends StatefulWidget {
  const LocalMusicListGridPage({super.key});

  @override
  LocalMusicListGridPageState createState() => LocalMusicListGridPageState();
}

class LocalMusicListGridPageState extends State<LocalMusicListGridPage>
    with WidgetsBindingObserver {
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    globalMobileMusicListGridPageRefreshFunction = () {
      loadMusicLists();
    };
    loadMusicLists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    globalMobileMusicListGridPageRefreshFunction = () {};
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  // Function to load music lists
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
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(children: [
        CupertinoNavigationBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '资料库',
                style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: textColor)
                    .useSystemChineseFont(),
              ),
            ),
          ),
          trailing: MusicListGridPageMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            playlists: playlists,
          ),
        ),
        Expanded(
            child: playlists.isEmpty
                ? Center(
                    child: Text("没有歌单",
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()))
                : CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Platform.isIOS ? 0.0 : 10.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                cacheCover:
                                    globalConfig.storageConfig.saveCover,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          LocalMusicContainerListPage(
                                        playlist: playlisy,
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
                  ))
      ]),
    );
  }
}

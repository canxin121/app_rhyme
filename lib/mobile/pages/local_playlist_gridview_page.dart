import 'dart:io';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/common_pages/reorder_page/playlist.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/mobile/comps/musiclist_comp/playlist_image_card.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/mobile/pages/local_music_aggregator_listview_page.dart';
import 'package:app_rhyme/mobile/pages/online_playlist_page.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

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
                              return MobileMusicListImageCard(
                                key: ValueKey(playlisy.identity),
                                playlist: playlisy,
                                online: false,
                                showDesc: false,
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
                                cachePic: globalConfig.storageConfig.savePic,
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

@immutable
class MusicListGridPageMenu extends StatelessWidget {
  const MusicListGridPageMenu({
    super.key,
    required this.builder,
    required this.playlists,
  });
  final PullDownMenuButtonBuilder builder;
  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              var playlist = await showPlaylistInfoDialog(context);
              if (playlist != null) {
                try {
                  await playlist.insertToDb();
                  refreshPlaylistGridViewPage();
                  LogToast.success("创建歌单", "创建歌单成功",
                      "[MusicListGridPageMenu] Successfully created music list");
                } catch (e) {
                  LogToast.error("创建歌单", "创建歌单失败: $e",
                      "[MusicListGridPageMenu] Failed to create music list: $e");
                }
              }
            }
          },
          title: '创建歌单',
          icon: CupertinoIcons.add,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            var share = await showInputPlaylistShareLinkDialog(context);
            if (share != null) {
              var playlist = await Playlist.getFromShare(share: share);
              if (context.mounted) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) => MobileOnlineMusicListPage(
                            playlist: playlist,
                          )),
                );
              }
            }
          },
          title: '打开歌单链接',
          icon: CupertinoIcons.link,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => PlaylistReorderPage(
                    playlists: playlists,
                    isDesktop: false,
                  ),
                ),
              );
            }
          },
          title: '手动排序',
          icon: CupertinoIcons.list_number,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            if (context.mounted) {
              Navigator.of(context).push(
                CupertinoPageRoute(
                    builder: (context) => PlaylistMultiSelectionPage(
                          playlists: playlists,
                          isDesktop: false,
                        )),
              );
            }
          },
          title: '多选操作',
          icon: CupertinoIcons.selection_pin_in_out,
        )
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

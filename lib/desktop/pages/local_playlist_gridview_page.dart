import 'dart:io';
import 'package:app_rhyme/common_pages/multi_selection_page/playlist.dart';
import 'package:app_rhyme/common_pages/reorder_page/playlist.dart';
import 'package:app_rhyme/desktop/comps/delegate.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/pages/local_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

void Function() globalDesktopMusicListGridPageRefreshFunction = () {};

class DesktopLocalMusicListGridPage extends StatefulWidget {
  const DesktopLocalMusicListGridPage({super.key});

  @override
  DesktopLocalMusicListGridPageState createState() =>
      DesktopLocalMusicListGridPageState();
}

class DesktopLocalMusicListGridPageState
    extends State<DesktopLocalMusicListGridPage> with WidgetsBindingObserver {
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();

    globalDesktopMusicListGridPageRefreshFunction = () async {
      try {
        var newPlaylists = await Playlist.getFromDb();
        setState(() {
          playlists = newPlaylists;
        });
      } catch (e) {
        LogToast.error("加载歌单列表", "加载歌单列表失败: $e",
            "[loadMusicLists] Failed to load music lists: $e");
      }
    };

    refreshPlaylistGridViewPage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    globalDesktopMusicListGridPageRefreshFunction = () {};
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
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor = getPrimaryBackgroundColor(isDarkMode);
    final Color navigatorBarColor = getNavigatorBarColor(isDarkMode);
    final ScrollController controller = ScrollController();

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(children: [
        CupertinoNavigationBar(
          backgroundColor: navigatorBarColor,
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '所有播放列表',
                style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
          ),
        ),
        Expanded(
            child: SafeArea(
          child: playlists.isEmpty
              ? Center(
                  child: Text("没有歌单",
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()))
              : CupertinoScrollbar(
                  thickness: 10,
                  radius: const Radius.circular(10),
                  controller: controller,
                  child: CustomScrollView(
                    controller: controller,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Platform.isIOS ? 0.0 : 10.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithResponsiveColumnCount(
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
                                  globalNavigatorToPage(
                                      LocalMusicContainerListPage(
                                    playlist: musicList,
                                  ));
                                },
                                cachePic: globalConfig.storageConfig.savePic,
                              );
                            },
                            childCount: playlists.length,
                          ),
                        ),
                      ),
                    ],
                  )),
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
  final List<Playlist> playlists;
  final PullDownMenuButtonBuilder builder;

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
            var url = await showInputPlaylistShareLinkDialog(context);
            if (url != null) {
              try {
                var playlist = await Playlist.getFromShare(share: url);
                if (context.mounted) {
                  globalNavigatorToPage(
                      DesktopOnlineMusicListPage(
                        playlist: playlist,
                      ),
                      replace: false);
                }
              } catch (e) {
                LogToast.error("打开歌单链接", "打开歌单链接失败: $e",
                    "[MusicListGridPageMenu] Failed to open playlist link: $e");
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
              globalNavigatorToPage(
                  PlaylistReorderPage(playlists: playlists, isDesktop: true),
                  replace: false);
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
              var playlists = await Playlist.getFromDb();
              globalNavigatorToPage(
                  PlaylistMultiSelectionPage(
                      playlists: playlists, isDesktop: true),
                  replace: false);
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

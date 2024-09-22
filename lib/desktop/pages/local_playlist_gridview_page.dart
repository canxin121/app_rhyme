import 'dart:io';
import 'package:app_rhyme/desktop/comps/delegate.dart';
import 'package:app_rhyme/desktop/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/pages/local_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/pages/muti_select_pages/muti_select_local_music_list_gridview_page.dart';
import 'package:app_rhyme/desktop/pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/pages/reorder_pages/reorder_playlist_grid_page.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
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
  List<Playlist> musicLists = [];

  @override
  void initState() {
    super.initState();
    globalDesktopMusicListGridPageRefreshFunction = () {
      loadMusicLists();
    };
    loadMusicLists();
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

  void loadMusicLists() async {
    try {
      var newMusicLists = await Playlist.getFromDb();
      setState(() {
        musicLists = newMusicLists;
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
    final Color backgroundColor = getPrimaryBackgroundColor(isDarkMode);
    final Color navigatorBarColor = getNavigatorBarColor(isDarkMode);
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
          child: musicLists.isEmpty
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
                            const SliverGridDelegateWithResponsiveColumnCount(
                          minColumnWidth: 200.0,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          minColumnCount: 4,
                          maxColumnCount: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            var musicList = musicLists[index];
                            return MusicListImageCard(
                              key: ValueKey(musicList.identity),
                              playlist: musicList,
                              online: false,
                              showDesc: false,
                              onTap: () {
                                globalSetNavItemSelected(
                                    "###Playlist_${musicList.identity}###");
                                globalNavigatorToPage(
                                    LocalMusicContainerListPage(
                                  playlist: musicList,
                                ));
                              },
                              cachePic: globalConfig.savePicWhenAddMusicList,
                            );
                          },
                          childCount: musicLists.length,
                        ),
                      ),
                    ),
                  ],
                ),
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
  });
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
              var playlist = await showMusicListInfoDialog(context);
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
                  globalNavigatorToPage(DesktopOnlineMusicListPage(
                    playlist: playlist,
                  ));
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
                  const DesktopReorderLocalMusicListGridPage());
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
              globalNavigatorToPage(DesktopMutiSelectLocalMusicListGridPage(
                  playlists: playlists));
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

import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:reorderables/reorderables.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/colors.dart';

class PlaylistReorderPage extends StatefulWidget {
  final bool isDesktop;
  final List<Playlist> playlists;
  const PlaylistReorderPage({
    super.key,
    required this.isDesktop,
    required this.playlists,
  });

  @override
  PlaylistReorderPageState createState() => PlaylistReorderPageState();
}

class PlaylistReorderPageState extends State<PlaylistReorderPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
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

  Future<void> _updatePlaylistsOrder() async {
    try {
      for (int i = 0; i < widget.playlists.length; i++) {
        widget.playlists[i].order = i;
        widget.playlists[i] = await widget.playlists[i].updateToDb();
      }
      LogToast.success("歌单排序成功", "歌单排序成功",
          "[ReorderLocalMusicListGridPageState] Music list reordered successfully");
      refreshPlaylistGridViewPage();
    } catch (e) {
      LogToast.error("歌单排序失败", "歌单排序错误: $e",
          "[ReorderLocalMusicListGridPageState] Failed to reorder music list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final ScrollController scrollController = ScrollController();

    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Column(
          children: [
            CupertinoNavigationBar(
              padding: const EdgeInsetsDirectional.all(0),
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: Icon(CupertinoIcons.back, color: activeIconRed),
                onPressed: () {
                  if (widget.isDesktop) {
                    globalPopPage();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              trailing: CupertinoButton(
                padding: const EdgeInsets.all(0),
                child: Icon(CupertinoIcons.checkmark, color: activeIconRed),
                onPressed: () async {
                  await _updatePlaylistsOrder();
                  if (context.mounted) {
                    if (widget.isDesktop) {
                      globalPopPage();
                    } else {
                      Navigator.pop(context);
                    }
                  }
                  refreshPlaylistGridViewPage();
                },
              ),
            ),
            Expanded(
              child: widget.playlists.isEmpty
                  ? Center(
                      child: Text("没有歌单",
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont()),
                    )
                  : Align(
                      alignment: Alignment.topCenter,
                      child: CupertinoScrollbar(
                          controller: scrollController,
                          thickness: 10,
                          radius: const Radius.circular(10),
                          child: ReorderableWrap(
                            controller: scrollController,
                            padding: const EdgeInsets.only(
                                bottom: 100, left: 10, right: 10, top: 10),
                            spacing: 8.0,
                            runSpacing: 8.0,
                            needsLongPressDraggable: true,
                            children: widget.playlists.map((musicList) {
                              return SizedBox(
                                width: widget.isDesktop
                                    ? 200
                                    : screenWidth / 2 - 20,
                                child: widget.isDesktop
                                    ? DesktopPlaylistImageCard(
                                        showDesc: false,
                                        key: ValueKey(musicList.identity),
                                        playlist: musicList,
                                        onTap: () {},
                                        cachePic:
                                            globalConfig.storageConfig.savePic,
                                      )
                                    : MobileMusicListImageCard(
                                        showDesc: false,
                                        key: ValueKey(musicList.identity),
                                        playlist: musicList,
                                        online: false,
                                        onTap: () {},
                                        cachePic:
                                            globalConfig.storageConfig.savePic,
                                      ),
                              );
                            }).toList(),
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                final Playlist item =
                                    widget.playlists.removeAt(oldIndex);
                                widget.playlists.insert(newIndex, item);
                              });
                            },
                          )),
                    ),
            )
          ],
        ));
  }
}

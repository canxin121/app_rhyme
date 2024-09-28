import 'package:app_rhyme/desktop/comps/delegate.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/pulldown_menus/multi_select_playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/utils/colors.dart';

class PlaylistMultiSelectionPage extends StatefulWidget {
  final List<Playlist> playlists;
  final bool isDesktop;

  const PlaylistMultiSelectionPage(
      {super.key, required this.playlists, required this.isDesktop});

  @override
  PlaylistMultiSelectionPageState createState() =>
      PlaylistMultiSelectionPageState();
}

class PlaylistMultiSelectionPageState extends State<PlaylistMultiSelectionPage>
    with WidgetsBindingObserver {
  DragSelectGridViewController controller = DragSelectGridViewController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final ScrollController scrollController = ScrollController();
    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Column(children: [
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
            trailing: PlaylistMutiSelectGridPageMenu(
              controller: controller,
              playlists: widget.playlists,
              setState: refreshPage,
              builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.only(right: 16),
                onPressed: showMenu,
                child: Text(
                  "选项",
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                ),
              ),
            ),
          ),
          widget.playlists.isEmpty
              ? Center(
                  child: Text("没有歌单",
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                )
              : Expanded(
                  child: Align(
                    key: ValueKey(controller.hashCode),
                    alignment: Alignment.topCenter,
                    child: CupertinoScrollbar(
                        thickness: 10,
                        radius: const Radius.circular(10),
                        controller: scrollController,
                        child: DragSelectGridView(
                          gridController: controller,
                          scrollController: scrollController,
                          padding: const EdgeInsets.only(
                              bottom: 100, top: 10, left: 10, right: 10),
                          itemCount: widget.playlists.length,
                          triggerSelectionOnTap: true,
                          itemBuilder: (context, index, selected) {
                            final playlist = widget.playlists[index];

                            // Use different card widgets for desktop and mobile
                            Widget playlistCard = widget.isDesktop
                                ? DesktopPlaylistImageCard(
                                    playlist: playlist,
                                    showDesc: false,
                                    cachePic:
                                        globalConfig.storageConfig.savePic,
                                  )
                                : MobileMusicListImageCard(
                                    playlist: playlist,
                                    online: false,
                                    showDesc: false,
                                    cachePic:
                                        globalConfig.storageConfig.savePic,
                                  );

                            return Stack(
                              key: ValueKey("${selected}_${playlist.identity}"),
                              children: [
                                playlistCard,
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      selected
                                          ? CupertinoIcons.check_mark_circled
                                          : CupertinoIcons.circle,
                                      color: selected
                                          ? CupertinoColors.systemGreen
                                          : CupertinoColors.systemGrey4,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          gridDelegate: widget.isDesktop
                              ? const SliverGridDelegateWithResponsiveColumnCount(
                                  minColumnWidth: 200.0,
                                  mainAxisSpacing: 10.0,
                                  crossAxisSpacing: 10.0,
                                  minColumnCount: 4,
                                  maxColumnCount: 8,
                                )
                              : const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8.0,
                                  crossAxisSpacing: 8.0,
                                  childAspectRatio: 0.75,
                                ),
                        )),
                  ),
                )
        ]));
  }
}
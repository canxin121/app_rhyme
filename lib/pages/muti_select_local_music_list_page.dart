import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MutiSelectLocalMusicContainerListPage extends StatefulWidget {
  final List<MusicContainer> musicContainers;
  final MusicListW musicList;

  const MutiSelectLocalMusicContainerListPage({
    super.key,
    required this.musicList,
    required this.musicContainers,
  });

  @override
  MutiSelectLocalMusicContainerListPageState createState() =>
      MutiSelectLocalMusicContainerListPageState();
}

class MutiSelectLocalMusicContainerListPageState
    extends State<MutiSelectLocalMusicContainerListPage>
    with WidgetsBindingObserver {
  final DragSelectGridViewController controller =
      DragSelectGridViewController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
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
    setState(() {
      // 重建界面以响应亮暗模式变化
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

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
          trailing: MutiSelectLocalMusicContainerListChoicMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            musicListW: widget.musicList,
            musicContainers: widget.musicContainers,
          )),
      child: widget.musicContainers.isEmpty
          ? Center(
              child: Text("没有音乐",
                  style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black)),
            )
          : Align(
              alignment: Alignment.topCenter,
              child: DragSelectGridView(
                gridController: controller,
                padding: const EdgeInsets.only(
                    bottom: 100, top: 60, left: 10, right: 10),
                itemCount: widget.musicContainers.length,
                triggerSelectionOnTap: true,
                itemBuilder: (context, index, selected) {
                  final musicContainer = widget.musicContainers[index];
                  return Stack(
                    key: ValueKey(musicContainer.hashCode),
                    children: [
                      MusicContainerListItem(
                        musicContainer: musicContainer,
                        musicListW: widget.musicList,
                      ),
                      if (selected)
                        const Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              CupertinoIcons.check_mark_circled,
                              color: CupertinoColors.systemGreen,
                            ),
                          ),
                        ),
                    ],
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 3 / 1),
              ),
            ),
    );
  }
}

@immutable
class MutiSelectLocalMusicContainerListChoicMenu extends StatelessWidget {
  const MutiSelectLocalMusicContainerListChoicMenu({
    super.key,
    required this.builder,
    required this.musicListW,
    required this.musicContainers,
  });

  final PullDownMenuButtonBuilder builder;
  final MusicListW musicListW;
  final List<MusicContainer> musicContainers;

  @override
  Widget build(BuildContext context) {
    MusicListInfo musicListInfo = musicListW.getMusiclistInfo();

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          leading: imageCacheHelper(musicListInfo.artPic),
          title: musicListInfo.name,
          subtitle: musicListInfo.desc,
        ),
        const PullDownMenuDivider.large(),
        PullDownMenuItem(
          onTap: () async {
            for (var musicContainer in musicContainers) {
              await cacheMusicHelper(musicContainer);
            }
          },
          title: '缓存选中音乐',
        ),
        PullDownMenuItem(
          onTap: () async {
            for (var musicContainer in musicContainers) {
              await deleteMusicCache(musicContainer);
            }
          },
          title: '取消缓存音乐',
        ),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

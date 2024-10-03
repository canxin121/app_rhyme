import 'package:app_rhyme/mobile/comps/music_agg_comp/music_container_list_item.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MusicList extends StatelessWidget {
  final bool isDarkMode;

  const MusicList({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var musicContainerList = globalAudioHandler.musicContainerList;
      return Expanded(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList.separated(
              separatorBuilder: (context, index) => Divider(
                color: isDarkMode
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey4,
                indent: 50,
                endIndent: 50,
              ),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: MobileMusicAggregatorListItem(
                  key: ValueKey(musicContainerList[index].musicAggregator.identity()),
                  musicAgg: musicContainerList[index].musicAggregator,
                  isDark: isDarkMode,
                  onTap: () {
                    globalAudioHandler.seek(Duration.zero, index: index);
                  },
                  index: index,
                ),
              ),
              itemCount: musicContainerList.length,
            ),
          ],
        ),
      );
    });
  }
}

class PlaylistContainer extends StatelessWidget {
  final double maxHeight;
  final bool isDarkMode;
  final double width;

  const PlaylistContainer({
    super.key,
    required this.maxHeight,
    required this.isDarkMode,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isDarkMode
        ? const Color.fromARGB(255, 46, 46, 46)
        : const Color.fromARGB(255, 249, 249, 249);
    Color borderColor = isDarkMode
        ? const Color.fromARGB(255, 62, 62, 62)
        : const Color.fromARGB(255, 237, 237, 237);
    Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    return Container(
      height: maxHeight,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
      ),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    '播放列表',
                    style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor)
                        .useSystemChineseFont(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 20),
                  child: CupertinoButton(
                    onPressed: () {
                      globalAudioHandler.clear();
                    },
                    child: Text(
                      '移除所有',
                      style: TextStyle(fontSize: 16, color: textColor)
                          .useSystemChineseFont(),
                    ),
                  ),
                ),
              ],
            ),
            MusicList(
              isDarkMode: isDarkMode,
            )
          ],
        ),
      ),
    );
  }
}

void showPlaylistPopup(BuildContext context, bool isDarkMode) {
  Navigator.push(
    context,
    PlaylistPopupRoute(
      maxHeight: MediaQuery.of(context).size.height,
      isDarkMode: isDarkMode,
    ),
  );
}

class PlaylistPopupRoute extends PopupRoute<void> {
  final double maxHeight;
  final bool isDarkMode;

  PlaylistPopupRoute({
    required this.maxHeight,
    required this.isDarkMode,
  });

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'PlaylistPopup';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    const containerWidth = 350.0;

    return FadeTransition(
      opacity: animation,
      child: Align(
        alignment: Alignment.centerRight,
        child: PlaylistContainer(
          maxHeight: maxHeight,
          isDarkMode: isDarkMode,
          width: containerWidth,
        ),
      ),
    );
  }
}

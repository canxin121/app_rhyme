import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:app_rhyme/pages/play_display_page.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';

class MusicControlBar extends StatelessWidget {
  final double maxHeight;
  const MusicControlBar({super.key, required this.maxHeight});

  // 定义动态颜色
  static const CupertinoDynamicColor barBackgroundDynamicColor =
      CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white, // light mode color
    darkColor: CupertinoColors.black, // dark mode color
  );

  static const CupertinoDynamicColor iconColorDynamic =
      CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.black, // light mode color
    darkColor: CupertinoColors.white, // dark mode color
  );

  static const CupertinoDynamicColor textColorDynamic =
      CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.black, // light mode color
    darkColor: CupertinoColors.white, // dark mode color
  );

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final Color barBackgroundColor =
        CupertinoDynamicColor.resolve(barBackgroundDynamicColor, context);
    final Color iconColor =
        CupertinoDynamicColor.resolve(iconColorDynamic, context);
    final Color textColor =
        CupertinoDynamicColor.resolve(textColorDynamic, context);
    final Color borderColor = brightness == Brightness.light
        ? CupertinoColors.systemGrey3
        : CupertinoColors.systemGrey;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy < 0) {
            navigateToSongDisplayPage(context);
          }
        },
        onTap: () {
          navigateToSongDisplayPage(context);
        },
        child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            color: barBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: borderColor,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(() => imageCacheHelper(
                    globalAudioHandler.playingMusic.value?.info.artPic)),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    globalAudioHandler.playingMusic.value?.info.name ?? "Music",
                    style: TextStyle(fontSize: 15.0, color: textColor),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      globalAudioHandler.seekToPrevious();
                    },
                    child: Icon(
                      CupertinoIcons.backward_fill,
                      color: iconColor,
                    ),
                  ),
                  Obx(() {
                    if (globalAudioUiController.playerState.value.playing) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.pause_solid,
                          color: iconColor,
                        ),
                        onPressed: () {
                          globalAudioHandler.pause();
                        },
                      );
                    } else {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.play_arrow_solid,
                          color: iconColor,
                        ),
                        onPressed: () {
                          globalAudioHandler.play();
                        },
                      );
                    }
                  }),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      globalAudioHandler.seekToNext();
                    },
                    child: Icon(
                      CupertinoIcons.forward_fill,
                      color: iconColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

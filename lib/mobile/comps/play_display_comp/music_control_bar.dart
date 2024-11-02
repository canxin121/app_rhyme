import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:app_rhyme/mobile/pages/play_display_page.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';

class MusicControlBar extends StatefulWidget {
  final double height;
  const MusicControlBar({super.key, required this.height});

  @override
  MusicControlBarState createState() => MusicControlBarState();
}

class MusicControlBarState extends State<MusicControlBar>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color iconColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return SizedBox(
      height: widget.height,
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
          color: getBackgroundColor(false, isDarkMode),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: Obx(() => SizedBox(
                        width: widget.height - 16, // 确保图片是正方形
                        height: widget.height - 16,
                        child: imageWithCache(
                          globalAudioHandler.playingMusic.value?.currentMusic
                              .getCover(size: 250),
                          height: widget.height - 16,
                          width: widget.height - 16,
                        ),
                      )),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    globalAudioHandler.playingMusic.value?.currentMusic.name ??
                        "Music",
                    style: TextStyle(fontSize: 15.0, color: textColor)
                        .useSystemChineseFont(),
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

import 'dart:async';
import 'package:app_rhyme/desktop/comps/popup_comp/lyric.dart';
import 'package:app_rhyme/desktop/comps/popup_comp/playlist.dart';
import 'package:app_rhyme/desktop/comps/popup_comp/volume_slider.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:interactive_slider/interactive_slider.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    Color backgroundColor = isDarkMode
        ? const Color.fromARGB(255, 42, 42, 42)
        : const Color.fromARGB(255, 247, 247, 247);
    Color dividerColor = getDividerColor(isDarkMode);
    bool isDesktop_ = isDesktopDevice();
    final childWidget = GestureDetector(
      onPanStart: (details) {
        if (isDesktop_) {
          appWindow.startDragging();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(
              color: dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 10, left: 30),
                    child: ControlButton(
                      buttonSize: 20,
                      buttonSpacing: 10,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: PlayDisplayCard(isDarkMode: isDarkMode),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 30, right: 30),
                    child: FunctionButtons(
                      buttonSize: 20,
                      buttonSpacing: 10,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop_) WindowButtons(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );

    return isDesktop_ ? WindowTitleBarBox(child: childWidget) : childWidget;
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key, required this.isDarkMode});
  final bool isDarkMode;

  @override
  WindowButtonsState createState() => WindowButtonsState();
}

class WindowButtonsState extends State<WindowButtons> {
  @override
  Widget build(BuildContext context) {
    Brightness brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    Color buttonColor = isDarkMode
        ? const Color.fromARGB(255, 222, 222, 222)
        : const Color.fromARGB(255, 38, 38, 38);
    bool isMaximized = appWindow.isMaximized;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.minus,
              color: buttonColor,
              size: 20,
            ),
            onPressed: () {
              appWindow.minimize();
            },
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: isMaximized
                ? Icon(
                    CupertinoIcons.fullscreen_exit,
                    color: buttonColor,
                    size: 20,
                  )
                : Icon(
                    CupertinoIcons.fullscreen,
                    color: buttonColor,
                    size: 20,
                  ),
            onPressed: () {
              appWindow.maximizeOrRestore();
              setState(() {
                isMaximized = appWindow.isMaximized;
              });
            },
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.clear,
              color: buttonColor,
              size: 20,
            ),
            onPressed: () {
              appWindow.close();
            },
          ),
        ),
      ],
    );
  }
}

class PlayDisplayCard extends StatefulWidget {
  const PlayDisplayCard({super.key, required this.isDarkMode});
  final bool isDarkMode;

  @override
  PlayDisplayCardState createState() => PlayDisplayCardState();
}

class PlayDisplayCardState extends State<PlayDisplayCard> {
  final ValueNotifier<bool> _isDragging = ValueNotifier<bool>(false);
  final InteractiveSliderController _progressController =
      InteractiveSliderController(0);
  late StreamSubscription<double> listen1;

  @override
  void initState() {
    super.initState();
    listen1 = globalAudioUiController.playProgress.listen((p0) {
      if (!_isDragging.value) {
        if (!p0.isNaN) {
          try {
            _progressController.value = p0;
          } catch (e) {
            if (e.toString().contains("disposed")) {
              listen1.cancel();
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    listen1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        widget.isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color textColor2 = widget.isDarkMode
        ? const Color.fromARGB(255, 142, 142, 142)
        : const Color.fromARGB(255, 129, 129, 129);
    final Color backgroundColor = widget.isDarkMode
        ? const Color.fromARGB(255, 57, 57, 57)
        : const Color.fromARGB(255, 249, 249, 249);
    final Color sliderBackgroundColor = widget.isDarkMode
        ? const Color.fromARGB(255, 102, 102, 102)
        : const Color.fromARGB(255, 206, 206, 206);
    final Color sliderForegroundColor = widget.isDarkMode
        ? const Color.fromARGB(255, 221, 221, 221)
        : const Color.fromARGB(255, 103, 103, 103);
    final Color borderColor = widget.isDarkMode
        ? const Color.fromARGB(255, 30, 30, 35)
        : const Color.fromARGB(255, 230, 230, 230);

    return GestureDetector(
      onPanStart: (details) {},
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 30, 30, 35),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Obx(() => ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: imageWithCache(
                          globalAudioHandler.playingMusic.value?.currentMusic
                              .getCover(size: 250),
                          width: 47,
                          height: 47),
                    )),
              ),
              SizedBox(
                width: 300,
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Center(
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Obx(() => Text(
                                    globalAudioHandler.playingMusic.value
                                            ?.currentMusic.name ??
                                        "Music",
                                    style: TextStyle(
                                            color: textColor, fontSize: 13)
                                        .useSystemChineseFont(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Obx(() => Text(
                                  globalAudioHandler.playingMusic.value
                                          ?.currentMusic.artists
                                          .map((e) => e.name)
                                          .join(", ") ??
                                      "Artist",
                                  style:
                                      TextStyle(color: textColor2, fontSize: 12)
                                          .useSystemChineseFont(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                                  formatDuration(globalAudioUiController
                                      .position.value.inSeconds),
                                  style:
                                      TextStyle(color: textColor2, fontSize: 12)
                                          .useSystemChineseFont(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            Obx(() => Text(
                                  formatDuration(globalAudioUiController
                                      .duration.value.inSeconds),
                                  style:
                                      TextStyle(color: textColor2, fontSize: 12)
                                          .useSystemChineseFont(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: InteractiveSlider(
                        controller: _progressController,
                        backgroundColor: sliderBackgroundColor,
                        foregroundColor: sliderForegroundColor,
                        focusedMargin: const EdgeInsets.all(0),
                        unfocusedMargin: const EdgeInsets.all(0),
                        focusedHeight: 5,
                        unfocusedHeight: 3,
                        padding: const EdgeInsets.all(0),
                        isDragging: _isDragging,
                        onProgressUpdated: (value) {
                          var toSeek = globalAudioUiController
                              .seekDurationFromPercent(value);
                          globalLogger.info(
                              "[Slider] Call seek to ${formatDuration(toSeek.inSeconds)}");
                          globalAudioHandler.seek(toSeek);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ControlButton extends StatefulWidget {
  final double buttonSize;
  final double buttonSpacing;
  final bool isDarkMode;

  const ControlButton({
    super.key,
    required this.buttonSize,
    required this.buttonSpacing,
    required this.isDarkMode,
  });

  @override
  State<StatefulWidget> createState() => ControlButtonState();
}

class ControlButtonState extends State<ControlButton> {
  @override
  Widget build(BuildContext context) {
    Color buttonColor = widget.isDarkMode
        ? const Color.fromARGB(255, 222, 222, 222)
        : const Color.fromARGB(255, 38, 38, 38);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CupertinoButton(
          padding: EdgeInsets.only(right: widget.buttonSpacing),
          child: Icon(CupertinoIcons.backward_fill,
              color: buttonColor, size: widget.buttonSize),
          onPressed: () {
            globalAudioHandler.seekToPrevious();
          },
        ),
        Obx(() {
          if (globalAudioUiController.playerState.value.playing) {
            return CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: Icon(CupertinoIcons.pause_solid,
                  color: buttonColor, size: widget.buttonSize),
              onPressed: () {
                globalAudioHandler.pause();
              },
            );
          } else {
            return CupertinoButton(
              padding: const EdgeInsets.all(0),
              child: Icon(CupertinoIcons.play_arrow_solid,
                  color: buttonColor, size: widget.buttonSize),
              onPressed: () {
                globalAudioHandler.play();
              },
            );
          }
        }),
        CupertinoButton(
          padding: EdgeInsets.only(left: widget.buttonSpacing),
          child: Icon(CupertinoIcons.forward_fill,
              color: buttonColor, size: widget.buttonSize),
          onPressed: () {
            globalAudioHandler.seekToNext();
          },
        ),
      ],
    );
  }
}

class FunctionButtons extends StatelessWidget {
  const FunctionButtons({
    super.key,
    required this.buttonSize,
    required this.buttonSpacing,
    required this.isDarkMode,
  });
  final double buttonSize;
  final double buttonSpacing;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    Color buttonColor = isDarkMode
        ? const Color.fromARGB(255, 222, 222, 222)
        : const Color.fromARGB(255, 38, 38, 38);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTapDown: (details) {
            final Offset tapPosition = details.globalPosition;
            final Rect position =
                Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
            showVolumeSlider(context, position, isDarkMode);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              CupertinoIcons.volume_up,
              color: buttonColor,
              size: buttonSize,
            ),
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            showLyricPopup(context, isDarkMode);
          },
          child: Icon(
            CupertinoIcons.quote_bubble,
            color: buttonColor,
            size: buttonSize,
          ),
        ),
        CupertinoButton(
          padding: EdgeInsets.only(left: buttonSpacing),
          onPressed: () {
            showPlaylistPopup(context, isDarkMode);
          },
          child: Icon(
            CupertinoIcons.list_bullet,
            color: buttonColor,
            size: buttonSize,
          ),
        ),
      ],
    );
  }
}

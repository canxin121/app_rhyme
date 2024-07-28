import 'dart:async';
import 'package:app_rhyme/types/lyric_ui.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

class LyricComp extends StatefulWidget {
  final double maxHeight;
  const LyricComp({
    super.key,
    required this.maxHeight,
  });

  @override
  LyricCompState createState() => LyricCompState();
}

class LyricCompState extends State<LyricComp> {
  var lyricModel =
      LyricsModelBuilder.create().bindLyricToMain("[00:00.00]无歌词").getModel();
  late LyricUI lyricUI;
  late StreamSubscription<MusicContainer?> stream;

  @override
  void initState() {
    super.initState();
    lyricUI = AppleMusicLyricUi();
    lyricModel = LyricsModelBuilder.create()
        .bindLyricToMain(globalAudioHandler.playingMusic.value?.info.lyric ??
            "[00:00.00]无歌词")
        .getModel();
    stream = globalAudioHandler.playingMusic.listen((p0) {
      setState(() {
        lyricModel = LyricsModelBuilder.create()
            .bindLyricToMain(p0?.info.lyric ?? "[00:00.00]无歌词")
            .getModel();
      });
    });
  }

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color decorationColor = CupertinoColors.white;
    Color iconColor = CupertinoColors.white;
    return Obx(() => LyricsReader(
          playing: globalAudioHandler.playingMusic.value != null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          emptyBuilder: () => Center(
            child: Text(
              "No lyrics",
              style: lyricUI.getOtherMainTextStyle().useSystemChineseFont(),
            ),
          ),
          model: lyricModel,
          position: globalAudioUiController.position.value.inMilliseconds,
          lyricUi: lyricUI,
          size: Size(double.infinity, widget.maxHeight),
          selectLineBuilder: (progress, confirm) {
            return Row(
              children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      var toSeek = Duration(milliseconds: progress);
                      globalAudioHandler.seek(toSeek).then((value) {
                        confirm.call();
                        // 这里是考虑到在暂停状态下。需要开启播放
                        if (!globalAudioHandler.isPlaying) {
                          globalAudioHandler.play();
                        }
                      });
                    },
                    icon: Icon(Icons.play_arrow, color: iconColor)),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: decorationColor),
                    height: 1,
                    width: double.infinity,
                  ),
                ),
                Text(
                  formatDuration(Duration(milliseconds: progress).inSeconds),
                  style:
                      TextStyle(color: decorationColor).useSystemChineseFont(),
                )
              ],
            );
          },
        ));
  }
}

class LyricPopupRoute extends PopupRoute<void> {
  final double maxHeight;
  LyricPopupRoute({
    required this.maxHeight,
  });

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'LyricPopup';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    const containerWidth = 450.0;

    return FadeTransition(
      opacity: animation,
      child: Align(
        alignment: Alignment.centerRight,
        child: LyricContainer(
          maxHeight: maxHeight,
          width: containerWidth,
        ),
      ),
    );
  }
}

class LyricContainer extends StatelessWidget {
  final double maxHeight;
  final double width;

  const LyricContainer({
    super.key,
    required this.maxHeight,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = const Color.fromARGB(255, 46, 46, 46);

    Color borderColor = const Color.fromARGB(255, 62, 62, 62);

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
      child: LyricComp(
        maxHeight: maxHeight,
      ),
    );
  }
}

void showLyricPopup(BuildContext context, bool isDarkMode) {
  Navigator.push(
    context,
    LyricPopupRoute(
      maxHeight: MediaQuery.of(context).size.height,
    ),
  );
}

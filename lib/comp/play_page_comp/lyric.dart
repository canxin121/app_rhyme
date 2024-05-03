import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/time_parse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';

class LyricDisplay extends StatefulWidget {
  final double maxHeight;
  const LyricDisplay({super.key, required this.maxHeight});

  @override
  LyricDisplayState createState() => LyricDisplayState();
}

class LyricDisplayState extends State<LyricDisplay> {
  var lyricModel =
      LyricsModelBuilder.create().bindLyricToMain("[00:00.00]无歌词").getModel();
  var lyricUI = UINetease(lyricAlign: LyricAlign.CENTER, highlight: true);
  @override
  void initState() {
    super.initState();
    lyricModel = LyricsModelBuilder.create()
        .bindLyricToMain(globalAudioHandler.playingMusic.value?.info.lyric ??
            "[00:00.00]无歌词")
        .getModel();
    globalAudioHandler.playingMusic.listen((p0) {
      setState(() {
        lyricModel = LyricsModelBuilder.create()
            .bindLyricToMain(p0?.info.lyric ?? "[00:00.00]无歌词")
            .getModel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => LyricsReader(
          playing: globalAudioHandler.playingMusic.value != null,
          emptyBuilder: () => Center(
            child: Text(
              "No lyrics",
              style: lyricUI.getOtherMainTextStyle(),
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
                    onPressed: () {
                      globalAudioHandler
                          .seek(Duration(milliseconds: progress))
                          .then((value) {
                        confirm.call();
                        if (!globalAudioHandler.isPlaying()) {
                          globalAudioHandler.play();
                        }
                      });
                    },
                    icon: const Icon(Icons.play_arrow,
                        color: CupertinoColors.white)),
                Expanded(
                  child: Container(
                    decoration:
                        const BoxDecoration(color: CupertinoColors.white),
                    height: 1,
                    width: double.infinity,
                  ),
                ),
                Text(
                  formatDuration(Duration(milliseconds: progress).inSeconds),
                  style: const TextStyle(color: CupertinoColors.white),
                )
              ],
            );
          },
        ));
  }
}

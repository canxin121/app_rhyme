import 'dart:async';

import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/time_parse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';

class LyricDisplay extends StatefulWidget {
  final double maxHeight;
  const LyricDisplay({super.key, required this.maxHeight});

  @override
  LyricDisplayState createState() => LyricDisplayState();
}

class LyricDisplayState extends State<LyricDisplay> {
  bool playing = false;
  int position = 0;
  late StreamSubscription<Duration> stream1;
  late StreamSubscription<Duration> stream2;
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

    playing = globalAudioHandler.playingMusic.value != null;
    stream1 = globalAudioHandler
        .createPositionStream(
            maxPeriod: const Duration(milliseconds: 5),
            minPeriod: const Duration(milliseconds: 5))
        .listen((event) {
      setState(() {
        position = event.inMilliseconds;
      });
    });

    stream2 = globalAudioUiController.duration.listen((p0) {
      setState(() {
        lyricModel = LyricsModelBuilder.create()
            .bindLyricToMain(
                globalAudioHandler.playingMusic.value?.info.lyric ??
                    "[00:00.00]无歌词")
            .getModel();
      });
    });
  }

  @override
  void dispose() {
    stream1.cancel();
    stream2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LyricsReader(
      playing: playing,
      emptyBuilder: () => Center(
        child: Text(
          "No lyrics",
          style: lyricUI.getOtherMainTextStyle(),
        ),
      ),
      model: lyricModel,
      position: position,
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
                  });
                },
                icon:
                    const Icon(Icons.play_arrow, color: CupertinoColors.white)),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: CupertinoColors.white),
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
    );
  }
}

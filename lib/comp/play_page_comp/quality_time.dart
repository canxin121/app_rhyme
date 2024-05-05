import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/selection.dart';
import 'package:app_rhyme/util/time_parse.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class QualityTime extends StatefulWidget {
  final double padding;
  final double fontHeight;
  const QualityTime({super.key, this.padding = 20.0, required this.fontHeight});

  @override
  State<StatefulWidget> createState() => QualityTimeState();
}

class QualityTimeState extends State<QualityTime> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: widget.padding, right: widget.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
                formatDuration(
                    globalAudioUiController.position.value.inSeconds),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: CupertinoColors.systemGrey6,
                  fontWeight: FontWeight.w300,
                  fontSize: widget.fontHeight,
                ),
              )),
          // 音质信息按钮
          CupertinoButton(
            minSize: 0,
            padding: const EdgeInsets.all(0),
            alignment: Alignment.topCenter,
            child: Obx(() {
              return Text(
                playingMusicQualityShort,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: widget.fontHeight,
                  fontWeight: FontWeight.normal,
                ),
              );
            }),
            onPressed: () {
              List<Quality>? qualityOptions =
                  globalAudioHandler.playingMusic.value?.info.qualities;
              List<String>? qualityStrs =
                  qualityOptions?.map((e) => e.short).toList();
              if (qualityOptions != null && qualityOptions.isNotEmpty) {
                showCupertinoPopupWithSameAction(
                    context: context,
                    options: qualityStrs!,
                    actionCallbacks: (index) async {
                      var playingMusic = globalAudioHandler.playingMusic.value;
                      if (playingMusic != null) {
                        var displayData = DisplayMusic(playingMusic.ref,
                            info_: playingMusic.info);
                        var newPlayMusic = await display2PlayMusic(
                            displayData, qualityOptions[index]);
                        if (newPlayMusic == null) return;
                        await globalAudioHandler
                            .replacePlayingMusic(newPlayMusic);
                      }
                    });
              }
            },
          ),
          Obx(() => Text(
                formatDuration(
                    globalAudioUiController.duration.value.inSeconds),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: CupertinoColors.systemGrey6,
                  fontWeight: FontWeight.w300,
                  fontSize: widget.fontHeight, // 小字体
                ),
              )),
        ],
      ),
    );
  }
}

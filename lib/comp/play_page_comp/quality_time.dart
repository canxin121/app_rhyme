import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/selection.dart';
import 'package:app_rhyme/util/time_parse.dart';
import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class QualityTime extends StatefulWidget {
  final double padding;
  const QualityTime({super.key, this.padding = 20.0});

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
                style: const TextStyle(
                  color: CupertinoColors.systemGrey6,
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
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
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.normal,
                ),
              ).frosted(
                blur: 10,
                frostColor: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 5, bottom: 5),
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
                style: const TextStyle(
                  color: CupertinoColors.systemGrey6,
                  fontWeight: FontWeight.w300,
                  fontSize: 12, // 小字体
                ),
              )),
        ],
      ),
    );
  }
}

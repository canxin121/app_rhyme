import 'dart:async';

import 'package:app_rhyme/util/audio_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:interactive_slider/interactive_slider.dart';

class ProgressSlider extends StatefulWidget {
  const ProgressSlider({super.key});
  @override
  ProgressSliderState createState() => ProgressSliderState();
}

// 这个组件代表了一个音乐播放详情页面的播放进度条等内容
class ProgressSliderState extends State<ProgressSlider> {
  InteractiveSliderController progressController =
      InteractiveSliderController(0);
  late StreamSubscription<double> listen1;
  bool isPressing = false;

  @override
  void initState() {
    super.initState();
    listen1 = globalAudioUiController.playProgress.listen((p0) {
      if (!isPressing) {
        if (!p0.isNaN) {
          try {
            progressController.value = p0;
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: GestureDetector(
        child: InteractiveSlider(
          padding: const EdgeInsets.all(0),
          controller: progressController,
          onProgressUpdated: (value) {
            isPressing = false;
            var toSeek = globalAudioUiController.getToSeek(value);
            globalAudioServiceHandler.seek(toSeek);
          },
        ),
        onTap: () {
          isPressing = true;
        },
        onLongPress: () {
          isPressing = true;
        },
        onLongPressMoveUpdate: (_) {
          isPressing = true;
        },
        onPanDown: (_) {
          isPressing = true;
        },
        onPanStart: (_) {
          isPressing = true;
        },
      ),
    );
  }
}

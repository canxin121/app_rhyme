import 'dart:async';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interactive_slider/interactive_slider.dart';

class ProgressSlider extends StatefulWidget {
  final EdgeInsets padding;
  final bool isDarkMode;
  const ProgressSlider(
      {super.key, required this.padding, required this.isDarkMode});
  @override
  ProgressSliderState createState() => ProgressSliderState();
}

// 这个组件代表了一个音乐播放详情页面的播放进度条等内容
class ProgressSliderState extends State<ProgressSlider> {
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
    return Container(
      padding: widget.padding,
      child: GestureDetector(
        child: InteractiveSlider(
          brightness: widget.isDarkMode ? Brightness.light : Brightness.dark,
          padding: const EdgeInsets.all(0),
          controller: _progressController,
          onProgressUpdated: (value) {
            var toSeek = globalAudioUiController.seekDurationFromPercent(value);
            globalLogger.info(
                "[Slider] Call seek to ${formatDuration(toSeek.inSeconds)}");
            globalAudioHandler.seek(toSeek);
          },
          isDragging: _isDragging,
        ),
      ),
    );
  }
}

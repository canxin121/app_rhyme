import 'package:app_rhyme/util/audio_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ControlButton extends StatefulWidget {
  // button的尺寸
  final double buttonSize;
  // button之间的距离
  final double buttonSpacing;
  const ControlButton(
      {super.key,
      required this.buttonSize,
      required this.buttonSpacing}); // 修改构造函数

  @override
  State<StatefulWidget> createState() => ControlButtonState();
}

class ControlButtonState extends State<ControlButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Hero(
            tag: "SkipToPreviousButton",
            child: CupertinoButton(
              padding: EdgeInsets.only(right: widget.buttonSpacing),
              child: Icon(CupertinoIcons.backward_fill,
                  color: CupertinoColors.white, size: widget.buttonSize),
              onPressed: () {
                globalAudioHandler.seekToPrevious();
              },
            )),
        Obx(() {
          if (globalAudioUiController.playerState.value.playing) {
            return Hero(
                tag: "PlayOrPauseButton",
                child: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Icon(CupertinoIcons.pause_solid,
                      color: CupertinoColors.white, size: widget.buttonSize),
                  onPressed: () {
                    globalAudioHandler.pause();
                  },
                ));
          } else {
            return Hero(
                tag: "PlayOrPauseButton",
                child: CupertinoButton(
                  padding: const EdgeInsets.all(0),
                  child: Icon(CupertinoIcons.play_arrow_solid,
                      color: CupertinoColors.white, size: widget.buttonSize),
                  onPressed: () {
                    globalAudioHandler.play();
                  },
                ));
          }
        }),
        Hero(
            tag: "SkipToNextButton",
            child: CupertinoButton(
              padding: EdgeInsets.only(left: widget.buttonSpacing),
              child: Icon(CupertinoIcons.forward_fill,
                  color: CupertinoColors.white, size: widget.buttonSize),
              onPressed: () {
                globalAudioHandler.seekToNext();
              },
            )),
      ],
    );
  }
}

import 'dart:async';

import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:interactive_slider/interactive_slider.dart';

class VolumeSlider extends StatefulWidget {
  final EdgeInsetsGeometry? padding;
  final bool isDarkMode;
  const VolumeSlider({super.key, this.padding, required this.isDarkMode});

  @override
  State<StatefulWidget> createState() => VolumeSliderState();
}

class VolumeSliderState extends State<VolumeSlider> {
  InteractiveSliderController volumeController = InteractiveSliderController(0);
  late StreamSubscription<double> volumeListenser;
  @override
  void initState() {
    super.initState();
    volumeListenser = globalAudioHandler.player.volumeStream.listen((volume) {
      try {
        volumeController.value = volume;
      } catch (e) {
        if (e.toString().contains("disposed")) {
          volumeListenser.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: InteractiveSlider(
        brightness: widget.isDarkMode ? Brightness.light : Brightness.dark,
        iconColor:
            widget.isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        controller: volumeController,
        padding: const EdgeInsets.all(0),
        onProgressUpdated: (value) {
          globalAudioHandler.player.setVolume(value);
        },
        startIcon: const Icon(CupertinoIcons.volume_down),
        endIcon: const Icon(CupertinoIcons.volume_up),
        isDragging: ValueNotifier<bool>(true),
      ),
    );
  }
}

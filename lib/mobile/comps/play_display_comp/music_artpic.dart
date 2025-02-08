import 'dart:io';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class MusicArtPic extends StatefulWidget {
  final EdgeInsets padding;
  const MusicArtPic({
    super.key,
    required this.padding,
  });

  @override
  State<StatefulWidget> createState() => MusicArtPicState();
}

class MusicArtPicState extends State<MusicArtPic> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
        padding: widget.padding,
        child: GlassContainer(
          shadowColor: Platform.isIOS
              ? CupertinoColors.black.withAlpha((255.0 * 0.2).round())
              : CupertinoColors.black.withAlpha((255.0 * 0.4).round()),
          shadowStrength: Platform.isIOS ? 3 : 8,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(18.0),
          child: imageWithCache(
              globalAudioHandler.playingMusic.value?.currentMusic
                  .getCover(size: 250),
              cacheHeight: 250,
              cacheWidth: 250),
        )));
  }
}

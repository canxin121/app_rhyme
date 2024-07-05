import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

// 这个组件在 待播放列表和歌词的上方显示
class PlayingMusicCard extends StatefulWidget {
  final double height;
  final EdgeInsets picPadding;
  final VoidCallback? onClick;
  final VoidCallback? onPress;
  const PlayingMusicCard({
    super.key,
    this.onClick,
    this.onPress,
    required this.height,
    required this.picPadding,
  });

  @override
  PlayingMusicCardState createState() => PlayingMusicCardState();
}

class PlayingMusicCardState extends State<PlayingMusicCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
      onTap: widget.onClick,
      onLongPress: widget.onPress,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            children: <Widget>[
              Padding(padding: widget.picPadding),
              Obx(
                () => GlassContainer(
                    shadowColor: Platform.isIOS
                        ? CupertinoColors.black.withOpacity(0.2)
                        : CupertinoColors.black.withOpacity(0.4),
                    shadowStrength: Platform.isIOS ? 4 : 8,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(4.0),
                    child: imageCacheHelper(
                        globalAudioHandler.playingMusic.value?.info.artPic,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(4.0))),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Obx(
                        () => Text(
                          globalAudioHandler.playingMusic.value?.info.name ??
                              "Music",
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey6,
                            fontSize: 14.0,
                          ).useSystemChineseFont(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Obx(() => Text(
                            globalAudioHandler.playingMusic.value?.info.artist
                                    .join(", ") ??
                                "Artist",
                            style: const TextStyle(
                                    fontSize: 12.0,
                                    color: CupertinoColors.systemGrey5,
                                    fontWeight: FontWeight.w500)
                                .useSystemChineseFont(),
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(right: 20)),
            ],
          ),
        ),
      ),
    ));
  }
}

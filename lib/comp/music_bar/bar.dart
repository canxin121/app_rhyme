import 'dart:io';

import 'package:app_rhyme/page/playing_music_page.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class MusicPlayBar extends StatelessWidget {
  final double maxHeight;
  const MusicPlayBar({super.key, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          // 当用户上滑时，details.delta.dy 会是一个负值
          if (details.delta.dy < 0) {
            navigateToSongDisplayPage(context);
          }
        },
        onTap: () {
          navigateToSongDisplayPage(context);
        },
        child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(color: barBackgoundColor),
          child: Row(
            children: <Widget>[
              // 音乐图标
              Padding(
                padding: const EdgeInsets.all(8.0),
                // 使用AspectRatio来保持图片的宽高比
                child: Obx(() => FutureBuilder<Hero>(
                      future: playingMusicImage(), // 这是异步函数
                      builder:
                          (BuildContext context, AsyncSnapshot<Hero> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return GlassContainer(
                              shadowColor: Platform.isIOS
                                  ? CupertinoColors.black.withOpacity(0.2)
                                  : CupertinoColors.black.withOpacity(0.4),
                              shadowStrength: Platform.isIOS ? 3 : 8,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Hero(
                                  tag: "PlayingMusicPic",
                                  child: defaultArtPic,
                                ),
                              ));
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return GlassContainer(
                              shadowColor: Platform.isIOS
                                  ? CupertinoColors.black.withOpacity(0.2)
                                  : CupertinoColors.black.withOpacity(0.4),
                              shadowStrength: Platform.isIOS ? 3 : 8,
                              shape: BoxShape.rectangle,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: snapshot.data ?? defaultArtPic,
                              ));
                        }
                      },
                    )),
              ),
              // 音乐名称
              Expanded(
                child: Obx(
                  () => Text(
                    playingMusicName,
                    style: const TextStyle(fontSize: 15.0),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              // 音乐控制按钮
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Hero(
                      tag: "SkipToPreviousButton",
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          globalAudioHandler.seekToPrevious();
                        },
                        child: const Icon(
                          CupertinoIcons.backward_fill,
                          color: CupertinoColors.black,
                        ),
                      )),
                  Obx(() {
                    if (globalAudioUiController.playerState.value.playing) {
                      return Hero(
                          tag: "PlayOrPauseButton",
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.pause_solid,
                              color: CupertinoColors.black,
                            ),
                            onPressed: () {
                              globalAudioHandler.pause();
                            },
                          ));
                    } else {
                      return Hero(
                          tag: "PlayOrPauseButton",
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: const Icon(
                              CupertinoIcons.play_arrow_solid,
                              color: CupertinoColors.black,
                            ),
                            onPressed: () {
                              globalAudioHandler.play();
                            },
                          ));
                    }
                  }),
                  Hero(
                      tag: "SkipToNextButton",
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          globalAudioHandler.seekToNext();
                        },
                        child: const Icon(
                          CupertinoIcons.forward_fill,
                          color: CupertinoColors.black,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

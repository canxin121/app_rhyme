import 'package:app_rhyme/page/playing_music_page.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pro_animated_blur/pro_animated_blur.dart';

class MusicPlayBar extends StatelessWidget {
  const MusicPlayBar({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取屏幕总高度
    double screenHeight = MediaQuery.of(context).size.height;
    // 计算组件的最大高度
    double barHeight = screenHeight * 0.08;

    return SafeArea(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: barHeight,
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
                  child: ProAnimatedBlur(
                    blur: 500,
                    duration: const Duration(milliseconds: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          // 使用AspectRatio来保持图片的宽高比
                          child: Obx(() => FutureBuilder<Hero>(
                                future: playingMusicImage(), // 这是异步函数
                                builder: (BuildContext context,
                                    AsyncSnapshot<Hero> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return AspectRatio(
                                      aspectRatio: 1,
                                      child: Hero(
                                        tag: "PlayingMusicPic",
                                        child: defaultArtPic,
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return AspectRatio(
                                      aspectRatio: 1,
                                      child: snapshot.data ?? defaultArtPic,
                                    );
                                  }
                                },
                              )),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Obx(
                                () => Text(
                                  playingMusicName,
                                  style: const TextStyle(fontSize: 15.0),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Hero(
                                tag: "SkipToPreviousButton",
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    globalAudioServiceHandler.skipToNext();
                                  },
                                  child: const Icon(
                                    CupertinoIcons.backward_fill,
                                    color: CupertinoColors.black,
                                  ),
                                )),
                            Obx(() {
                              if (globalAudioUiController
                                  .playerState.value.playing) {
                                return Hero(
                                    tag: "PlayOrPauseButton",
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      child: const Icon(
                                        CupertinoIcons.pause_solid,
                                        color: CupertinoColors.black,
                                      ),
                                      onPressed: () {
                                        globalAudioServiceHandler.pause();
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
                                        globalAudioServiceHandler.play();
                                      },
                                    ));
                              }
                            }),
                            Hero(
                                tag: "SkipToNextButton",
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    globalAudioServiceHandler.skipToNext();
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
                ))));
  }
}

import 'package:app_rhyme/pages/play_display_page.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class MusicControlBar extends StatelessWidget {
  final double maxHeight;
  const MusicControlBar({super.key, required this.maxHeight});

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
          decoration: BoxDecoration(
            color: barBackgoundWhite,
            border: const Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey3,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              // 音乐图标
              Padding(
                padding: const EdgeInsets.all(8.0),
                // 使用AspectRatio来保持图片的宽高比
                child: Obx(() => imageCacheHelper(
                    globalAudioHandler.playingMusic.value?.info.artPic)),
              ),
              // 音乐名称
              Expanded(
                child: Obx(
                  () => Text(
                    globalAudioHandler.playingMusic.value?.info.name ?? "Music",
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
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      globalAudioHandler.seekToPrevious();
                    },
                    child: const Icon(
                      CupertinoIcons.backward_fill,
                      color: CupertinoColors.black,
                    ),
                  ),
                  Obx(() {
                    if (globalAudioUiController.playerState.value.playing) {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.pause_solid,
                          color: CupertinoColors.black,
                        ),
                        onPressed: () {
                          globalAudioHandler.pause();
                        },
                      );
                    } else {
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.play_arrow_solid,
                          color: CupertinoColors.black,
                        ),
                        onPressed: () {
                          globalAudioHandler.play();
                        },
                      );
                    }
                  }),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      globalAudioHandler.seekToNext();
                    },
                    child: const Icon(
                      CupertinoIcons.forward_fill,
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

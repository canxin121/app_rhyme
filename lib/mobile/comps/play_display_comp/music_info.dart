import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class MusicInfo extends StatefulWidget {
  final double titleHeight;
  final double artistHeight;
  final EdgeInsets padding;
  const MusicInfo(
      {super.key,
      required this.titleHeight,
      required this.artistHeight,
      required this.padding});

  @override
  State<StatefulWidget> createState() => MusicInfoState();
}

class MusicInfoState extends State<MusicInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 音乐名称
          Obx(() {
            return Container(
              alignment: Alignment.topLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "${globalAudioHandler.playingMusic.value?.currentMusic.name ?? "Music"}\n",
                      style: TextStyle(
                              fontSize: widget.titleHeight,
                              color: CupertinoColors.systemGrey6)
                          .useSystemChineseFont(),
                    ),
                    TextSpan(
                      text: globalAudioHandler
                              .playingMusic.value?.currentMusic.artists
                              .map((e) => e.name)
                              .toList()
                              .join(", ") ??
                          "Artist",
                      style: TextStyle(
                              fontSize: widget.artistHeight,
                              color: CupertinoColors.systemGrey5)
                          .useSystemChineseFont(),
                    ),
                  ],
                ),
                overflow: TextOverflow.clip,
              ),
            );
          }),
        ],
      ),
    );
  }
}

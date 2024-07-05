import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/comps/chores/badge.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:pull_down_button/pull_down_button.dart';

class QualityTime extends StatefulWidget {
  final double padding;
  final double fontHeight;
  const QualityTime({super.key, this.padding = 20.0, required this.fontHeight});

  @override
  State<StatefulWidget> createState() => QualityTimeState();
}

class QualityTimeState extends State<QualityTime> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: widget.padding, right: widget.padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Text(
                formatDuration(
                    globalAudioUiController.position.value.inSeconds),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: CupertinoColors.systemGrey6,
                  fontWeight: FontWeight.w300,
                  fontSize: widget.fontHeight,
                ).useSystemChineseFont(),
              )),
          // 音质信息按钮
          GestureDetector(
            onTapDown: (details) {
              List<Quality>? qualityOptions =
                  globalAudioHandler.playingMusic.value?.info.qualities;
              if (qualityOptions != null && qualityOptions.isNotEmpty) {
                showPullDownMenu(
                    context: context,
                    items: qualitySelectPullDown(context, qualityOptions,
                        (selectQuality) async {
                      await globalAudioHandler
                          .replacePlayingMusic(selectQuality);
                    }),
                    position: details.globalPosition & Size.zero);
              }
            },
            child: Obx(() {
              return Badge(
                label: globalAudioHandler
                        .playingMusic.value?.currentQuality.value?.short ??
                    "Quality",
                isDark: false,
              );
              //  GlassContainer(
              //     shadowColor: Platform.isIOS
              //         ? CupertinoColors.black.withOpacity(0.1)
              //         : CupertinoColors.black.withOpacity(0.2),
              //     shadowStrength: Platform.isIOS ? 3 : 8,
              //     child: Container(
              //       margin: const EdgeInsets.only(
              //           left: 10, right: 10, top: 2, bottom: 2),
              //       child: Text(
              //         globalAudioHandler.playingMusic.value?.currentQuality
              //                 .value?.short ??
              //             "Quality",
              //         style: TextStyle(
              //           color: CupertinoColors.white,
              //           fontSize: widget.fontHeight,
              //           fontWeight: FontWeight.normal,
              //         ).useSystemChineseFont(),
              //       ),
              //     ));
            }),
          ),
          Obx(() => Text(
                formatDuration(
                    globalAudioUiController.duration.value.inSeconds),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: CupertinoColors.systemGrey6,
                  fontWeight: FontWeight.w300,
                  fontSize: widget.fontHeight,
                ).useSystemChineseFont(),
              )),
        ],
      ),
    );
  }
}

// 选择变更后的quality的触发操作
List<PullDownMenuEntry> qualitySelectPullDown(
        BuildContext context,
        List<Quality> qualitys,
        Future<void> Function(Quality selectQuality) onSelect) =>
    [
      PullDownMenuTitle(
          title: Text(
        "切换音质",
        style: const TextStyle().useSystemChineseFont(),
      )),
      ...qualitys.map(
        (quality) => PullDownMenuItem(
            title: quality.short,
            onTap: () async {
              await onSelect(quality);
            }),
      )
    ];

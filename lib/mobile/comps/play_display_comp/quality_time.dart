import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/mobile/comps/chores/badge.dart';
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
          Obx(() => SizedBox(
                width: 60,
                child: Text(
                  formatDuration(
                      globalAudioUiController.position.value.inSeconds),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey6,
                    fontWeight: FontWeight.w300,
                    fontSize: widget.fontHeight,
                  ).useSystemChineseFont(),
                ),
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
                isDarkMode: true,
                label: globalAudioHandler
                        .playingMusic.value?.currentQuality.value?.short ??
                    "Quality",
              );
            }),
          ),
          Obx(() => SizedBox(
                width: 60,
                child: Text(
                  formatDuration(
                      globalAudioUiController.duration.value.inSeconds),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey6,
                    fontWeight: FontWeight.w300,
                    fontSize: widget.fontHeight,
                  ).useSystemChineseFont(),
                ),
              )),
        ],
      ),
    );
  }
}

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
            itemTheme: PullDownMenuItemTheme(
                textStyle: const TextStyle().useSystemChineseFont()),
            title: quality.short,
            onTap: () async {
              await onSelect(quality);
            }),
      )
    ];

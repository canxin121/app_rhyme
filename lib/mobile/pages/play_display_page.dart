import 'dart:io';
import 'dart:math';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/bottom_button.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/control_button.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/lyric.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/music_artpic.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/music_info.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/music_list.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/playing_music_card.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/progress_slider.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/quality_time.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/volume_slider.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';

import 'package:dismissible_page/dismissible_page.dart';

enum PageState { main, list, lyric }

class SongDisplayPage extends StatefulWidget {
  const SongDisplayPage({super.key});

  @override
  SongDisplayPageState createState() => SongDisplayPageState();
}

class SongDisplayPageState extends State<SongDisplayPage> {
  PageState pageState = PageState.main;

  void onListBotton() {
    setState(() {
      if (pageState == PageState.list) {
        pageState = PageState.main;
      } else {
        pageState = PageState.list;
      }
    });
  }

  void onLyricBotton() {
    setState(() {
      if (pageState == PageState.lyric) {
        pageState = PageState.main;
      } else {
        pageState = PageState.lyric;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.black
        : CupertinoColors.white;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> topWidgets;
    switch (pageState) {
      case PageState.main:
        topWidgets = <Widget>[
          Container(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.87 - 240),
            alignment: Alignment.center,
            child: MusicArtPic(
              padding: EdgeInsets.only(
                  left: min(screenWidth * 0.2, 50),
                  right: min(screenWidth * 0.2, 50)),
            ),
          )
        ];
        break;
      case PageState.list:
        topWidgets = <Widget>[
          // 占据70高度
          const PlayingMusicCard(
            height: 70,
            picPadding: EdgeInsets.only(left: 20),
          ),
          // 占据20高度
          Container(
            padding:
                const EdgeInsets.only(left: 20, top: 20, bottom: 10, right: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '待播清单',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                  ).useSystemChineseFont(),
                ),
                GestureDetector(
                  child: Text(
                    '删除所有',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.0,
                    ).useSystemChineseFont(),
                  ),
                  onTap: () {
                    globalAudioHandler.clear();
                  },
                )
              ],
            ),
          ),
          // 应当占据剩下的所有高度
          MusicListComp(
            maxHeight: Platform.isIOS
                ? screenHeight * 0.87 - 350
                : screenHeight * 0.87 - 300,
          ),
        ];
        break;
      case PageState.lyric:
        topWidgets = [
          const PlayingMusicCard(
            height: 70,
            picPadding: EdgeInsets.only(left: 20),
          ),
          // 应当占据剩下的空间
          LyricDisplay(
            maxHeight: (Platform.isIOS)
                ? screenHeight * 0.87 - 290
                : screenHeight * 0.87 - 240,
            isDarkMode: isDarkMode,
          )
        ];
        break;
    }

    return DismissiblePage(
      isFullScreen: true,
      direction: DismissiblePageDismissDirection.down,
      backgroundColor: backgroundColor,
      onDismissed: () => Navigator.of(context).pop(),
      child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                brightness == Brightness.dark
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.systemGrey2,
                brightness == Brightness.dark
                    ? CupertinoColors.black
                    : CupertinoColors.systemGrey,
              ],
            ),
          ),
          child: Stack(children: [
            // 上方组件
            Column(
              children: [
                if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
                  const Padding(padding: EdgeInsets.only(top: 40)),
                if (Platform.isAndroid || Platform.isIOS)
                  const Padding(padding: EdgeInsets.only(top: 20)),
                ...topWidgets
              ],
            ),
            // 固定在页面底部的内容,共占据约 140 + screenHeight * 0.2 的高度
            Positioned(
              bottom: 0, // 确保它固定在底部
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // main界面时占据36的高度
                  if (pageState == PageState.main)
                    const MusicInfo(
                      titleHeight: 20,
                      artistHeight: 16,
                      padding: EdgeInsets.only(left: 40, right: 40),
                    ),
                  // 占据约35的高度
                  const ProgressSlider(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                  ),
                  // 占据 12 高度
                  const QualityTime(
                    fontHeight: 12,
                    padding: 35,
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.04,
                          bottom: screenHeight * 0.04),
                      child: ControlButton(
                        buttonSize: screenWidth * 0.11,
                        buttonSpacing: screenWidth * 0.12,
                      )),
                  const VolumeSlider(
                    padding: EdgeInsets.only(left: 20, right: 20),
                  ),
                  // if (!Platform.isIOS) const VolumeSlider(),
                  // 占据 55 的高度
                  BottomButton(
                    onList: onListBotton,
                    onLyric: onLyricBotton,
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    size: 25,
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}

void navigateToSongDisplayPage(BuildContext context) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const SongDisplayPage(),
      fullscreenDialog: true,
    ),
  );
}

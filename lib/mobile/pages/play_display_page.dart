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
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    const backgroundColor1 = Color.fromARGB(255, 56, 56, 56);
    const backgroundColor2 = Color.fromARGB(255, 31, 31, 31);
    const textColor = CupertinoColors.white;

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
          const PlayingMusicCard(
            height: 70,
            picPadding: EdgeInsets.only(left: 20),
          ),
          Container(
            padding:
                const EdgeInsets.only(left: 20, top: 20, bottom: 10, right: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '待播清单',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                  ).useSystemChineseFont(),
                ),
                GestureDetector(
                  child: Text(
                    '删除所有',
                    style: const TextStyle(
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
          MusicListComp(
            maxHeight: screenHeight * 0.87 - 300,
          ),
        ];
        break;
      case PageState.lyric:
        topWidgets = [
          const PlayingMusicCard(
            height: 70,
            picPadding: EdgeInsets.only(left: 20),
          ),
          LyricDisplay(
            maxHeight: screenHeight * 0.87 - 240,
            isDarkMode: true,
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [backgroundColor2, backgroundColor1],
            ),
          ),
          child: Stack(children: [
            // 上方组件
            Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 40)),
                ...topWidgets
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (pageState == PageState.main)
                    const MusicInfo(
                      titleHeight: 20,
                      artistHeight: 16,
                      padding: EdgeInsets.only(left: 40, right: 40),
                    ),
                  const ProgressSlider(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    isDarkMode: true,
                  ),
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
                    isDarkMode: true,
                  ),
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

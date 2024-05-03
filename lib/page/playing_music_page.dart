import 'package:app_rhyme/comp/card/playing_music_card.dart';
import 'package:app_rhyme/comp/play_page_comp/botton_button.dart';
import 'package:app_rhyme/comp/play_page_comp/control_button.dart';
import 'package:app_rhyme/comp/play_page_comp/lyric.dart';
import 'package:app_rhyme/comp/play_page_comp/music_artpic.dart';
import 'package:app_rhyme/comp/play_page_comp/music_info.dart';
import 'package:app_rhyme/comp/play_page_comp/music_list.dart';
import 'package:app_rhyme/comp/play_page_comp/progress_slider.dart';
import 'package:app_rhyme/comp/play_page_comp/quality_time.dart';
import 'package:app_rhyme/comp/play_page_comp/volume_slider.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<Widget> topWidgets;
    switch (pageState) {
      case PageState.main:
        topWidgets = <Widget>[
          const MusicArtPic(),
        ];
        break;
      case PageState.list:
        topWidgets = <Widget>[
          const PlayingMusicCard(),
          Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              '待播清单',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(
            child: PlayMusicList(),
          ),
        ];
        break;
      case PageState.lyric:
        topWidgets = [
          const PlayingMusicCard(),
          LyricDisplay(maxHeight: screenHeight * 0.7),
        ];
        break;
    }

    return DismissiblePage(
      isFullScreen: true,
      direction: DismissiblePageDismissDirection.down,
      backgroundColor: CupertinoColors.white,
      onDismissed: () => Navigator.of(context).pop(),
      child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                CupertinoColors.systemGrey2,
                CupertinoColors.systemGrey,
              ],
            ),
          ),
          child: Stack(children: [
            // 上方组件
            Column(
              children: topWidgets,
            ),
            // 固定在页面底部的内容
            Positioned(
              bottom: 0, // 确保它固定在底部
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // if (pageState == PageState.main) const MusicInfo(),
                  const ProgressSlider(),
                  // const QualityTime(),
                  ControlButton(
                    buttonSize: screenWidth * 0.1,
                    buttonSpacing: screenWidth * 0.2,
                  ),
                  // const VolumeSlider(),
                  BottomButton(
                    onList: onListBotton,
                    onLyric: onLyricBotton,
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
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

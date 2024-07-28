import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';

class AppleMusicLyricUi extends LyricUI {
  AppleMusicLyricUi();

  @override
  TextStyle getPlayingMainTextStyle() {
    return const TextStyle(
      color: Color.fromARGB(255, 120, 119, 118),
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ).useSystemChineseFont();
  }

  // 不起作用
  @override
  TextStyle getPlayingExtTextStyle() {
    return const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
        .useSystemChineseFont();
  }

  @override
  TextStyle getOtherMainTextStyle() {
    return const TextStyle(
      color: Color.fromARGB(200, 120, 119, 118),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ).useSystemChineseFont();
  }

  // 不起作用
  @override
  TextStyle getOtherExtTextStyle() {
    return const TextStyle(
      color: CupertinoColors.systemGrey3,
      fontSize: 14,
    ).useSystemChineseFont();
  }

  @override
  double getBlankLineHeight() => 16;

  @override
  double getLineSpace() => 26;

  @override
  double getInlineSpace() => 8;

  @override
  double getPlayingLineBias() => 0.4;

  @override
  LyricAlign getLyricHorizontalAlign() => LyricAlign.LEFT;

  @override
  bool enableLineAnimation() => true;

  @override
  bool enableHighlight() => true;

  @override
  Color getLyricHightlightColor() {
    return const Color.fromARGB(255, 255, 255, 255);
  }

  @override
  bool initAnimation() => true;
}

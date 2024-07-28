import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

Future<void> initDesktopWindowSetting() async {
  // 初始化桌面窗口设置，仅在桌面平台运行
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    doWhenWindowReady(() {
      appWindow
        ..size = const Size(1280, 860)
        ..minSize = const Size(1100, 600)
        ..alignment = Alignment.center
        ..show();
    });
  }
}

import 'dart:io';

import 'package:app_rhyme/utils/chore.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';

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

Future<void> initMobileDevice(BuildContext context) async {
  if (isDesktop()) {
    return;
  }
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  if (!isTablet(context)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

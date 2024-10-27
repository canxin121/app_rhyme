import 'package:app_rhyme/src/rust/api/types/config.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';

Future<void> initDesktopWindowSetting() async {
  // 初始化桌面窗口设置，仅在桌面平台运行
  if (isDesktop()) {
    doWhenWindowReady(() {
      if (globalConfig.windowConfig == null) {
        globalConfig.windowConfig == WindowConfig.default_();
        globalConfig.save(documentFolder: globalDocumentPath);
      }

      var windowSetting = appWindow
        ..size = Size(globalConfig.windowConfig?.width.toDouble() ?? 1280,
            globalConfig.windowConfig?.height.toDouble() ?? 860)
        ..minSize = Size(globalConfig.windowConfig?.minWidth.toDouble() ?? 1100,
            globalConfig.windowConfig?.minHeight.toDouble() ?? 600)
        ..alignment = Alignment.center;
      if (globalConfig.windowConfig != null &&
          globalConfig.windowConfig!.fullscreen) {
        windowSetting.maximize();
      }

      windowSetting.show();
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
  if (!isTouchScreenDesktop(context)) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initWindow() async {
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(450, 900),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    windowManager.setResizable(false);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

import 'package:app_rhyme/utils/chore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

import 'dart:ui';

import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';

void initFlutterLogger() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    globalTalker.error("[Flutter Error] $details");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    globalTalker.error("[PlatForm Error] Error: $error\nStackTrace: $stack");
    return true;
  };
}

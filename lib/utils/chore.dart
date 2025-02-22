import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'dart:math';
import 'dart:ui';

import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:url_launcher/url_launcher.dart';

List<T> shuffleList<T>(List<T> items) {
  var random = Random();
  // 创建列表的副本以避免修改原始列表
  List<T> shuffledItems = List<T>.from(items);

  for (int i = shuffledItems.length - 1; i > 0; i--) {
    int n = random.nextInt(i + 1);
    T temp = shuffledItems[i];
    shuffledItems[i] = shuffledItems[n];
    shuffledItems[n] = temp;
  }

  return shuffledItems;
}

void openProjectRepoLink() async {
  Uri uri = Uri.parse("https://github.com/canxin121/app_rhyme");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    await Clipboard.setData(
        const ClipboardData(text: "https://github.com/canxin121/app_rhyme"));
    LogToast.error("打开项目页面失败", "已复制链接到剪切板，请在浏览器中打开",
        "[openProjectLink] Failed to launch github url, copied to clipboard");
  }
}

Future<void> exitApp() async {
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterExitApp.exitApp(iosForceExit: true);
  } else {
    exit(0);
  }
}

bool? globalIsTouchScreenTablet;
bool isTouchScreenDesktop(BuildContext context) {
  if (isDesktopDevice()) {
    return false;
  }

  if (globalIsTouchScreenTablet != null) {
    return globalIsTouchScreenTablet!;
  }
  final mediaQuery = MediaQuery.of(context);
  final size = mediaQuery.size;
  final diagonal = sqrt(size.width * size.width + size.height * size.height);
  globalIsTouchScreenTablet = diagonal > 600;
  return globalIsTouchScreenTablet!;
}

bool isDesktopDevice() {
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

bool isWidthGreaterThanHeight(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.width > size.height;
}

/// 防止tls问题导致图片无法加载
Future<void> initBypassNetImgError() async {
  HttpClient client = ExtendedNetworkImageProvider.httpClient;
  client.userAgent = null;
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
}

void initFlutterLogger() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    globalLogger.error("[Flutter Error] $details");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    globalLogger.error("[PlatForm Error] Error: $error");
    return true;
  };
}

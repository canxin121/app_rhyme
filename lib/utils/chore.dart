import 'dart:math';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
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

void openProjectLink() async {
  Uri uri = Uri.parse("https://github.com/canxin121/app_rhyme");
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    await Clipboard.setData(
        const ClipboardData(text: "https://github.com/canxin121/app_rhyme"));
    toastification.show(
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
        title:
            Text("打开项目页面失败", style: const TextStyle().useSystemChineseFont()),
        description: Text("已复制链接到剪切板，请在浏览器中打开",
            style: const TextStyle().useSystemChineseFont()));
  }
}

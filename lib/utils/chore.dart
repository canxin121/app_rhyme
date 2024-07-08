import 'dart:math';

import 'package:app_rhyme/utils/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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
    LogToast.error("打开项目页面失败", "已复制链接到剪切板，请在浏览器中打开",
        "[openProjectLink] Failed to launch github url, copied to clipboard");
  }
}

Future<String?> pickDirectory() async {
  // 请求存储权限
  if (await Permission.storage.request().isGranted) {
    // 使用file_picker选择目录
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  } else {
    // 权限被拒绝
    LogToast.error("未授予存储权限", "请在设置中授予AppRhyme存储权限",
        "[pickDirectory] Storage permission not granted");
    return null;
  }
}

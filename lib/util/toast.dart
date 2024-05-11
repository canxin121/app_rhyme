import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

void toast(BuildContext context, String title, String content,
    ToastificationType type) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.minimal,
    title: Text(
      title,
      style:
          const TextStyle(fontWeight: FontWeight.bold).useSystemChineseFont(),
    ),
    description: Text(
      content,
      style: const TextStyle().useSystemChineseFont(),
    ),
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 2),
    boxShadow: highModeShadow,
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}

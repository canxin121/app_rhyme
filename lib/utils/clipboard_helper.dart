import 'package:app_rhyme/types/log_toast.dart';
import 'package:flutter/services.dart';

Future<void> setClipboard(String text) async {
  try {
    await Clipboard.setData(ClipboardData(text: text));
    LogToast.success(
      "设置剪切板",
      "成功复制到剪切板",
      "[setClipboard] success: $text",
    );
  } catch (e) {
    LogToast.error(
      "设置剪切板",
      "失败: $e",
      "[setClipboard] failed: $e",
    );
  }
}

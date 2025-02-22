
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:toastification/toastification.dart';

class LogToast {
  static void info(String toastTitle, String toastDesc, String log,
      {bool isLong = false}) {
    toastDesc = _filterStackTrace(toastDesc);
    toastification.show(
      autoCloseDuration: Duration(seconds: isLong ? 4 : 2),
      type: ToastificationType.info,
      title: Text(
        toastTitle,
        style: const TextStyle().useSystemChineseFont(),
      ),
      description: Text(
        toastDesc,
        style: const TextStyle().useSystemChineseFont(),
      ),
    );
    globalLogger.info(log);
  }

  static void success(String toastTitle, String toastDesc, String log,
      {bool isLong = false}) {
    toastDesc = _filterStackTrace(toastDesc);
    toastification.show(
      autoCloseDuration: Duration(seconds: isLong ? 4 : 2),
      type: ToastificationType.success,
      title: Text(
        toastTitle,
        style: const TextStyle().useSystemChineseFont(),
      ),
      description: Text(
        toastDesc,
        style: const TextStyle().useSystemChineseFont(),
      ),
    );
    globalLogger.info(log);
  }

  static void warning(String toastTitle, String toastDesc, String log,
      {bool isLong = false}) {
    toastDesc = _filterStackTrace(toastDesc);
    toastification.show(
      autoCloseDuration: Duration(seconds: isLong ? 5 : 3),
      type: ToastificationType.warning,
      title: Text(
        toastTitle,
        style: const TextStyle().useSystemChineseFont(),
      ),
      description: Text(
        toastDesc,
        style: const TextStyle().useSystemChineseFont(),
      ),
    );
    globalLogger.warn(log);
  }

  static void error(String toastTitle, String toastDesc, String log,
      {bool isLong = false}) {
    toastDesc = _filterStackTrace(toastDesc);
    toastification.show(
      autoCloseDuration: Duration(seconds: isLong ? 5 : 3),
      type: ToastificationType.error,
      title: Text(
        toastTitle,
        style: const TextStyle().useSystemChineseFont(),
      ),
      description: Text(
        toastDesc,
        style: const TextStyle().useSystemChineseFont(),
      ),
    );
    globalLogger.error(log);
  }

  static String _filterStackTrace(String desc) {
    const stackTraceKeyword = 'Stack backtrace';
    final index = desc.indexOf(stackTraceKeyword);
    if (index != -1) {
      return desc.substring(0, index);
    }
    return desc;
  }
}

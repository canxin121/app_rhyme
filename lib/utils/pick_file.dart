import 'dart:io';

import 'package:app_rhyme/utils/log_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> pickDirectory() async {
  var permission = true;
  if (Platform.isAndroid) {
    permission = await Permission.manageExternalStorage.request().isGranted;
  }
  if (permission) {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  } else {
    LogToast.error("未授予存储权限", "请在设置中授予AppRhyme存储权限",
        "[pickDirectory] Storage permission not granted");
    return null;
  }
}

Future<String?> pickFile() async {
  var permission = true;
  if (Platform.isAndroid) {
    permission = await Permission.manageExternalStorage.request().isGranted;
  }
  if (permission) {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      if (result.files.length > 1) {
        LogToast.warning("选择文件", "选择的文件多余一个, 只有第一个文件将被使用",
            "[pickFile] Picked too many files, only the first will be used.");
      }
      return result.files.single.path;
    }
  } else {
    LogToast.error("未授予存储权限", "请在设置中授予AppRhyme存储权限",
        "[pickFile] Storage permission not granted");
  }
  return null;
}

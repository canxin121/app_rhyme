import 'dart:io';

import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String?> pickDirectory() async {
  if (Platform.isIOS) {
    LogToast.info("保存路径", "在IOS上,将自动保存到文件中的AppRhyme目录的Export目录中。",
        "[pickDictory]The save path will be automatically set to the Export directory in the AppRhyme directory in Files on iOS.");
    return "$globalDocumentPath/app_rhyme/Export";
  }
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

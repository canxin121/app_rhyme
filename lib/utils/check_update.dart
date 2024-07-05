import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/dialogs/extern_api_update_dialog.dart';
import 'package:app_rhyme/dialogs/version_update_dialog.dart';
import 'package:app_rhyme/src/rust/api/check_update.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';

Future<void> checkVersionUpdate(BuildContext context) async {
  try {
    toastification.show(
        type: ToastificationType.info,
        autoCloseDuration: const Duration(seconds: 2),
        title: Text(
          "检查应用版本更新",
          style: const TextStyle().useSystemChineseFont(),
        ),
        description: Text(
          "正在加载数据,请稍等",
          style: const TextStyle().useSystemChineseFont(),
        ));
    var release = await checkUpdate(currentVersion: globalPackageInfo.version);
    if (context.mounted && release != null) {
      showVersionUpdateDialog(context, release);
    } else if (release == null) {
      toastification.show(
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.info,
          title: Text("版本更新", style: const TextStyle().useSystemChineseFont()),
          description: Text("当前版本无需更新",
              style: const TextStyle().useSystemChineseFont()));
    }
  } catch (e) {
    globalTalker.log("[VersionUpdate] $e");
  }
}

Future<void> checkExternApiUpdate(BuildContext context) async {
  try {
    if (globalConfig.externApi != null &&
        globalConfig.externApi!.url != null &&
        globalConfig.externApi!.url!.isNotEmpty) {
      toastification.show(
          type: ToastificationType.info,
          autoCloseDuration: const Duration(seconds: 2),
          title: Text(
            "检查自定义源更新",
            style: const TextStyle().useSystemChineseFont(),
          ),
          description: Text(
            "正在加载数据,请稍等",
            style: const TextStyle().useSystemChineseFont(),
          ));
      var externApi = await globalConfig.externApi!.fetchUpdate();
      if (externApi != null) {
        if (context.mounted) {
          if (await showExternApiUpdateDialog(context)) {
            globalConfig.externApi = externApi;
            await globalConfig.save();
            toastification.show(
                type: ToastificationType.success,
                autoCloseDuration: const Duration(seconds: 3),
                title: Text("自定义音源更新",
                    style: const TextStyle().useSystemChineseFont()),
                description: Text("更新自定义音源成功",
                    style: const TextStyle().useSystemChineseFont()));
          }
        }
      } else {
        toastification.show(
            type: ToastificationType.info,
            autoCloseDuration: const Duration(seconds: 2),
            title: Text("自定义音源更新",
                style: const TextStyle().useSystemChineseFont()),
            description: Text("当前自定义源无需更新",
                style: const TextStyle().useSystemChineseFont()));
      }
    }
  } catch (e) {
    toastification.show(
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 2),
        title: Text("自定义音源更新", style: const TextStyle().useSystemChineseFont()),
        description: Text("更新自定义音源失败: $e",
            style: const TextStyle().useSystemChineseFont()));
  }
}

Future<void> autoCheckUpdate(BuildContext context) async {
  if (globalConfig.versionAutoUpdate) {
    await checkVersionUpdate(context);
  }
  if (globalConfig.externApiAutoUpdate) {
    if (context.mounted) {
      await checkExternApiUpdate(context);
    }
  }
}

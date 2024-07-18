import 'package:app_rhyme/src/rust/api/types/version.dart';
import 'package:app_rhyme/types/extern_api.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/extern_api_update_dialog.dart';
import 'package:app_rhyme/dialogs/version_update_dialog.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/widgets.dart';

Future<void> checkVersionUpdate(BuildContext context, bool toast) async {
  try {
    if (toast) {
      LogToast.info("检查应用版本更新", "正在加载数据,请稍等",
          "[checkVersionUpdate] Checking app version update");
    }

    var release = await checkUpdate(currentVersion: globalPackageInfo.version);
    if (context.mounted && release != null) {
      showVersionUpdateDialog(context, release);
    } else if (release == null) {
      if (toast) {
        LogToast.info("版本更新", "当前版本无需更新",
            "[checkVersionUpdate] Current version does not need to be updated");
      }
    }
  } catch (e) {
    globalTalker.log("[VersionUpdate] $e");
  }
}

Future<void> checkExternApiUpdate(BuildContext context, bool toast) async {
  try {
    if (globalConfig.externApi != null &&
        globalConfig.externApi!.url != null &&
        globalConfig.externApi!.url!.isNotEmpty) {
      if (toast) {
        LogToast.info("检查自定义源更新", "正在加载数据,请稍等",
            "[checkExternApiUpdate] Checking custom source update");
      }
      var externApi = await globalConfig.externApi!.fetchUpdate();
      if (externApi != null) {
        if (context.mounted) {
          if (await showExternApiUpdateDialog(context)) {
            globalConfig.externApi = externApi;
            await globalConfig.save();
            globalExternApiEvaler =
                ExternApiEvaler(globalConfig.externApi!.localPath);
            LogToast.success("自定义源更新", "更新自定义源成功",
                "[checkExternApiUpdate] Successfully updated custom source");
          }
        }
      } else {
        if (toast) {
          LogToast.info("自定义源更新", "当前自定义源无需更新",
              "[checkExternApiUpdate] The current custom source does not need to be updated");
        }
      }
    }
  } catch (e) {
    LogToast.error("自定义源更新", "更新自定义源失败: $e",
        "[checkExternApiUpdate] Failed to update custom source: $e");
  }
}

Future<void> autoCheckUpdate(BuildContext context) async {
  if (globalConfig.versionAutoUpdate) {
    await checkVersionUpdate(context, false);
  }
  if (globalConfig.externApiAutoUpdate) {
    if (context.mounted) {
      await checkExternApiUpdate(context, false);
    }
  }
}

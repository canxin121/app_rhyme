import 'package:app_rhyme/src/rust/api/types/version.dart';
import 'package:app_rhyme/types/plugin.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/common_comps/dialogs/extern_api_update_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/version_update_dialog.dart';
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
    globalLogger.info("[VersionUpdate] $e");
  }
}

Future<void> checkExternalApiUpdate(BuildContext context, bool toast) async {
  try {
    if (globalConfig.externalApi != null &&
        globalConfig.externalApi!.url != null &&
        globalConfig.externalApi!.url!.isNotEmpty) {
      if (toast) {
        LogToast.info("检查自定义源更新", "正在加载数据,请稍等",
            "[checkExternalApiUpdate] Checking custom source update");
      }
      var externalApi = await globalConfig.externalApi!.fetchUpdate();
      if (externalApi != null) {
        if (context.mounted) {
          if (await showExternalApiUpdateDialog(context)) {
            globalConfig.externalApi = externalApi;
            await globalConfig.save(documentFolder: globalDocumentPath);
            globalExternalApiEvaler =
                PluginEvaler(globalConfig.externalApi!.filePath);
            LogToast.success("自定义源更新", "更新自定义源成功",
                "[checkExternalApiUpdate] Successfully updated custom source");
          }
        }
      } else {
        if (toast) {
          LogToast.info("自定义源更新", "当前自定义源无需更新",
              "[checkExternalApiUpdate] The current custom source does not need to be updated");
        }
      }
    }
  } catch (e) {
    LogToast.error("自定义源更新", "更新自定义源失败: $e",
        "[checkExternalApiUpdate] Failed to update custom source: $e");
  }
}

Future<void> autoCheckUpdate(BuildContext context) async {
  if (globalConfig.updateConfig.versionAutoUpdate) {
    await checkVersionUpdate(context, false);
  }
  if (globalConfig.updateConfig.externalApiAutoUpdate) {
    if (context.mounted) {
      await checkExternalApiUpdate(context, false);
    }
  }
}

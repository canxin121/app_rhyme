import 'dart:async';
import 'dart:io';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/dialogs/database_url_dialog.dart';
import 'package:app_rhyme/dialogs/file_name_dialog.dart';
import 'package:app_rhyme/dialogs/input_extern_api_link_dialog.dart';
import 'package:app_rhyme/dialogs/quality_select_dialog.dart';
import 'package:app_rhyme/dialogs/wait_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache/cache_op.dart';
import 'package:app_rhyme/src/rust/api/cache/database_op.dart';
import 'package:app_rhyme/src/rust/api/music_api/fns.dart';
import 'package:app_rhyme/src/rust/api/music_api/wrapper.dart';
import 'package:app_rhyme/src/rust/api/types/config.dart';
import 'package:app_rhyme/src/rust/api/types/external_api.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/clipboard_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/types/extern_api.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/pick_file.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final iconColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemGrey6
        : CupertinoColors.systemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '设置',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: textColor,
              ).useSystemChineseFont(),
            ),
          ),
        ),
      ),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text('应用信息',
                style: TextStyle(color: textColor).useSystemChineseFont()),
            children: [
              CupertinoFormRow(
                  prefix: SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: imageWithCache("", width: 50, height: 50),
                      )),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          'AppRhyme',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20.0,
                          ).useSystemChineseFont(),
                        ),
                      ))),
              CupertinoFormRow(
                  prefix: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        '版本号',
                        style:
                            TextStyle(color: textColor).useSystemChineseFont(),
                      )),
                  child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.centerRight,
                      height: 40,
                      child: Text(
                        globalPackageInfo.version,
                        style:
                            TextStyle(color: textColor).useSystemChineseFont(),
                      ))),
              CupertinoFormRow(
                prefix: Text(
                  '检查更新',
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
                child: CupertinoButton(
                  onPressed: () async {
                    await checkVersionUpdate(context, true);
                  },
                  child: Icon(CupertinoIcons.cloud, color: iconColor),
                ),
              ),
              CupertinoFormRow(
                prefix: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      '自动检查更新',
                      style: TextStyle(color: textColor).useSystemChineseFont(),
                    )),
                child: CupertinoSwitch(
                    value: globalConfig.updateConfig.versionAutoUpdate,
                    onChanged: (value) {
                      if (value !=
                          globalConfig.updateConfig.versionAutoUpdate) {
                        globalConfig.updateConfig.versionAutoUpdate = value;
                        globalConfig.save(documentFolder: globalDocumentPath);
                        setState(() {});
                      }
                    }),
              ),
              CupertinoFormRow(
                prefix: Text(
                  '项目链接',
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
                child: CupertinoButton(
                  onPressed: openProjectLink,
                  child: Text(
                    'github.com/canxin121/app_rhyme',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(children: [
            CupertinoFormRow(
              prefix: Text('音质设置',
                  style: TextStyle(color: textColor).useSystemChineseFont()),
              child: CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const QualityConfigPage()),
                  );
                },
                child: const Icon(CupertinoIcons.right_chevron),
              ),
            ),
            CupertinoFormRow(
              prefix: Text('更新设置',
                  style: TextStyle(color: textColor).useSystemChineseFont()),
              child: CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const UpdateConfigPage()),
                  );
                },
                child: const Icon(CupertinoIcons.right_chevron),
              ),
            ),
            CupertinoFormRow(
              prefix: Text('储存设置',
                  style: TextStyle(color: textColor).useSystemChineseFont()),
              child: CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const StorageConfigPage()),
                  );
                },
                child: const Icon(CupertinoIcons.right_chevron),
              ),
            ),
            CupertinoFormRow(
              prefix: Text('音源设置',
                  style: TextStyle(color: textColor).useSystemChineseFont()),
              child: CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => const ExternalApiConfigPage()),
                  );
                },
                child: const Icon(CupertinoIcons.right_chevron),
              ),
            ),
            if (isDesktop())
              CupertinoFormRow(
                prefix: Text('窗口设置',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const WindowConfigPage()),
                    );
                  },
                  child: const Icon(CupertinoIcons.right_chevron),
                ),
              ),
            CupertinoFormRow(
              prefix: Text('查看日志',
                  style: TextStyle(color: textColor).useSystemChineseFont()),
              child: CupertinoButton(
                onPressed: () {
                  if (isDesktop()) {
                    globalNavigatorToPage(TalkerScreen(
                      talker: globalTalker,
                    ));
                  } else {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                          builder: (context) => TalkerScreen(
                                talker: globalTalker,
                              )),
                    );
                  }
                },
                child: const Icon(CupertinoIcons.right_chevron),
              ),
            ),
          ])
        ],
      ),
    );
  }
}

class QualityConfigPage extends StatefulWidget {
  const QualityConfigPage({super.key});

  @override
  QualityConfigPageState createState() => QualityConfigPageState();
}

class QualityConfigPageState extends State<QualityConfigPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;

    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemGrey6
        : CupertinoColors.systemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        middle: Text('音质设置', style: TextStyle(color: textColor)),
      ),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text('音质自动选择设置',
                style: TextStyle(color: textColor).useSystemChineseFont()),
            children: [
              CupertinoFormRow(
                prefix: Text(
                    (Platform.isAndroid || Platform.isIOS)
                        ? 'WiFi 自动选择音质'
                        : '自动选择音质',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoButton(
                  child: Text(
                      qualityOptionToString(
                          globalConfig.qualityConfig.wifiAutoQuality),
                      style:
                          const TextStyle(color: CupertinoColors.activeBlue)),
                  onPressed: () async {
                    var quality = await showQualityOptionDialog(context);
                    if (quality != null) {
                      setState(() {
                        globalConfig.qualityConfig.wifiAutoQuality = quality;
                        globalConfig.save(documentFolder: globalDocumentPath);
                      });
                    }
                  },
                ),
              ),
              if (Platform.isAndroid || Platform.isIOS)
                CupertinoFormRow(
                  prefix: Text('移动网络自动选择音质',
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: CupertinoButton(
                    child: Text(
                        qualityOptionToString(
                            globalConfig.qualityConfig.mobileAutoQuality),
                        style:
                            const TextStyle(color: CupertinoColors.activeBlue)),
                    onPressed: () async {
                      var quality = await showQualityOptionDialog(context);
                      if (quality != null) {
                        globalConfig.qualityConfig.mobileAutoQuality = quality;
                        globalConfig.save(documentFolder: globalDocumentPath);
                        setState(() {});
                      }
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class UpdateConfigPage extends StatefulWidget {
  const UpdateConfigPage({super.key});

  @override
  UpdateConfigPageState createState() => UpdateConfigPageState();
}

class UpdateConfigPageState extends State<UpdateConfigPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemGrey6
        : CupertinoColors.systemGroupedBackground;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        middle: Text('更新设置', style: TextStyle(color: textColor)),
      ),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text('自动检查更新设置', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                prefix: Text('自动检查版本更新',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoSwitch(
                  value: globalConfig.updateConfig.versionAutoUpdate,
                  onChanged: (value) {
                    globalConfig.updateConfig.versionAutoUpdate = value;
                    globalConfig.save(documentFolder: globalDocumentPath);
                    setState(() {});
                  },
                ),
              ),
              CupertinoFormRow(
                prefix: Text('自动检查音源更新',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoSwitch(
                  value: globalConfig.updateConfig.externalApiAutoUpdate,
                  onChanged: (value) {
                    globalConfig.updateConfig.externalApiAutoUpdate = value;
                    globalConfig.save(documentFolder: globalDocumentPath);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StorageConfigPage extends StatefulWidget {
  const StorageConfigPage({super.key});

  @override
  StorageConfigPageState createState() => StorageConfigPageState();
}

class StorageConfigPageState extends State<StorageConfigPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  Future<void> useNewCacheRoot(bool needMove) async {
    var newCustomCacheRoot = await pickDirectory();
    if (newCustomCacheRoot == null) return;
    if (globalConfig.storageConfig.customCacheRoot != null &&
        globalConfig.storageConfig.customCacheRoot == newCustomCacheRoot) {
      LogToast.info("缓存设置", "目标文件夹与原缓存文件夹相同, 无需操作",
          "[storageConfig.useNewCacheRoot] Same as original folder, no need to operate");
      return;
    }

    try {
      globalAudioHandler.clear();
      await globalAudioHandler.clear();
      await closeDb();
      if (needMove) {
        if (mounted) {
          await showWaitDialog(context, "正在移动数据中,稍后将自动退出应用以应用更改");
        }

        await moveCacheData(
            documentPath: globalDocumentPath,
            newCustomCacheRoot: newCustomCacheRoot);
      } else {
        if (mounted) {
          await showWaitDialog(context, "正在清理旧数据中,稍后将自动退出应用以应用更改");
        }
        await delOldCacheData(documentPath: globalDocumentPath);
      }

      globalConfig.storageConfig.customCacheRoot = newCustomCacheRoot;
      await globalConfig.save(documentFolder: globalDocumentPath);

      if (mounted) {
        context.findAncestorStateOfType<SettingPageState>()?.refresh();
      }
    } finally {
      if (mounted) {
        Navigator.pop(context);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemGrey6
        : CupertinoColors.systemGroupedBackground;
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('储存设置', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text('自动缓存设置', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                prefix: Text('缓存封面',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoSwitch(
                  value: globalConfig.storageConfig.savePic,
                  onChanged: (value) {
                    setState(() {
                      globalConfig.storageConfig.savePic = value;
                      globalConfig.save(documentFolder: globalDocumentPath);
                    });
                  },
                ),
              ),
            ],
          ),
          if (!Platform.isIOS)
            CupertinoFormSection.insetGrouped(
              header: Text('缓存目录设置', style: TextStyle(color: textColor)),
              children: [
                CupertinoFormRow(
                  prefix: Text('当前缓存目录',
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: GestureDetector(
                      onTap: () {
                        setClipboard(globalConfig.getStorageFolder(
                            documentFolder: globalDocumentPath));
                      },
                      child: Container(
                          padding: const EdgeInsets.only(right: 10),
                          alignment: Alignment.centerRight,
                          height: 50,
                          child: Text(
                            globalConfig.getStorageFolder(
                                documentFolder: globalDocumentPath),
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ))),
                ),
                CupertinoFormRow(
                  prefix: Text(
                    '移动缓存文件夹',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var confirm = await showConfirmationDialog(
                          context,
                          "注意!\n"
                          "'移动数据文件夹'将会将当前使用的缓存文件夹下的缓存数据迁移到新的文件夹下\n"
                          "请确保新的文件夹下没有AppRhyme的数据, 否则会导致该目标文件夹中数据完全丢失!!!\n"
                          "如果你想直接使用指定文件夹下的数据, 请使用'使用缓存文件夹'功能\n"
                          "是否继续?");
                      if (confirm != null && confirm) {
                        await useNewCacheRoot(true);
                      }
                    },
                    child: const Icon(CupertinoIcons.folder),
                  ),
                ),
                CupertinoFormRow(
                  prefix: Text(
                    '使用缓存文件夹',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var confirm = await showConfirmationDialog(
                          context,
                          "注意!\n"
                          "‘使用缓存文件夹’将会直接使用指定文件夹下的缓存数据, 请确保目标文件夹下有正确的缓存数据\n"
                          "这将会导致当前使用的缓存文件夹下的缓存数据完全丢失!!!\n"
                          "如果你想移动缓存数据到目标文件夹, 请使用'移动缓存文件夹'功能\n"
                          "是否继续?");

                      if (confirm != null && confirm) {
                        await useNewCacheRoot(false);
                      }
                    },
                    child: const Icon(
                      CupertinoIcons.folder,
                    ),
                  ),
                ),
              ],
            ),
          CupertinoFormSection.insetGrouped(
            header: Text('歌单Sql设置', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                prefix: Text('当前数据库',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: GestureDetector(
                    onTap: () {
                      setClipboard(globalConfig.getSqlUrl(
                          documentFolder: globalDocumentPath));
                    },
                    child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        alignment: Alignment.centerRight,
                        height: 50,
                        child: Text(
                          globalConfig.getSqlUrl(
                              documentFolder: globalDocumentPath),
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont(),
                        ))),
              ),
              CupertinoFormRow(
                prefix: Text(
                  '迁移歌单数据库',
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
                child: CupertinoButton(
                  onPressed: () async {
                    var confirm = await showConfirmationDialog(
                        context,
                        "注意!\n"
                        "该功能将会将当前使用的歌曲数据库迁移到新的数据库中\n"
                        "请确保目标数据库中没有AppRhyme的数据, 否则会导致该目标数据库中数据完全丢失!!!\n"
                        "如果你想直接使用目标数据库下的数据, 请使用'使用歌单数据库'功能\n"
                        "是否继续?");
                    if (confirm == null || !confirm) return;
                    if (!context.mounted) return;
                    var newDbUrl = await showDatabaseUrlDialog(context);
                    if (newDbUrl == null) return;
                    if (!context.mounted) return;
                    await showWaitDialog(context, "正在移动数据中");
                    try {
                      await moveDatabase(
                          documentFolder: globalDocumentPath,
                          newDbUrl: newDbUrl);
                      LogToast.success("数据库设置", "数据库移动成功",
                          "[storageConfig.moveDatabase] success");
                    } catch (e) {
                      LogToast.error("数据库设置", "数据库移动失败: $e",
                          "[storageConfig.moveDatabase] failed: $e");
                    } finally {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      setState(() {});
                    }
                  },
                  child: const Icon(CupertinoIcons.tray_2_fill),
                ),
              ),
              CupertinoFormRow(
                prefix: Text(
                  '切换歌单数据库',
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
                child: CupertinoButton(
                  onPressed: () async {
                    var confirm = await showConfirmationDialog(
                        context,
                        "注意!\n"
                        "该功能将会直接使用指定数据库下的歌单数据, 请确保目标数据库下有正确的歌单数据\n"
                        "这将会导致当前使用的歌单数据库下的歌单数据完全丢失!!!\n"
                        "如果你想移动歌单数据到目标数据库, 请使用'移动歌单数据库'功能\n"
                        "是否继续?");
                    if (confirm == null || !confirm) return;
                    if (!context.mounted) return;
                    var newDbUrl = await showDatabaseUrlDialog(context);
                    if (newDbUrl == null) return;
                    if (!context.mounted) return;
                    await showWaitDialog(context, "正在清除数据中");
                    try {
                      await clearDb();
                      await setDb(databaseUrl: newDbUrl);
                      LogToast.success("数据库设置", "数据库设置成功",
                          "[storageConfig.moveDatabase] success");
                    } catch (e) {
                      LogToast.error("数据库设置", "数据库设置失败: $e",
                          "[storageConfig.moveDatabase] failed: $e");
                    } finally {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      setState(() {});
                    }
                  },
                  child: const Icon(CupertinoIcons.tray_2_fill),
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
              header: Text('歌单Json设置', style: TextStyle(color: textColor)),
              children: [
                CupertinoFormRow(
                  prefix: Text(
                    '导出json文件',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var confirm = await showConfirmationDialog(
                          context,
                          "注意!\n"
                          "该功能可以将歌单数据库完整导出为json文件, 包含所有歌单和其中的歌曲\n"
                          "请选择要保存到的目标文件夹\n"
                          "是否继续?");
                      if (confirm == null || !confirm) return;
                      String? directory = await pickDirectory();
                      if (directory == null) return;
                      if (!context.mounted) return;
                      String? filename = await showFileNameDialog(
                          context, "json",
                          defaultFileName: "app_rhyme_database");
                      if (filename == null) return;
                      String filePath = "$directory/$filename";
                      try {
                        var databaseJson =
                            await DatabaseJsonWrapper.getFromDb();
                        await databaseJson.saveTo(path: filePath);
                        LogToast.success("数据库导出", "数据库导出为json成功: $filePath",
                            "[storageConfig.exportDatabase] success: $filePath");
                      } catch (e) {
                        LogToast.error("数据库导出", "数据库导出为json失败: $e",
                            "[storageConfig.exportDatabase] failed: $e");
                      } finally {
                        setState(() {});
                      }
                    },
                    child: const Icon(CupertinoIcons.share_solid),
                  ),
                ),
                CupertinoFormRow(
                  prefix: Text(
                    '导入Json文件',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var confirm = await showConfirmationDialog(
                          context,
                          "注意!\n"
                          "该功能可以将数据库Json文件导入数据库, 包含所有歌单和其中的歌曲\n"
                          "这将会导致当前使用的数据库下的歌单数据完全丢失!!!\n"
                          "请选择要导入的数据库Json文件, 请确保Json文件是从相同版本的AppRhyme中导出的\n"
                          "是否继续?");
                      if (confirm == null || !confirm) return;
                      String? filePath = await pickFile();
                      if (filePath == null) return;
                      if (!context.mounted) return;
                      await showWaitDialog(context, "正在应用数据库Json文件, 请稍等");
                      try {
                        var databaseJson =
                            await DatabaseJsonWrapper.loadFrom(path: filePath);
                        await databaseJson.applyToDb();
                        LogToast.success("导入数据库", "从Json文件导入数据库成功",
                            "[storageConfig.importDatabase] succeed to imprt json file to database");
                      } catch (e) {
                        LogToast.error("导入数据库", "从Json文件导入数据库失败: $e",
                            "[storageConfig.importDatabase] failed: $e");
                      } finally {
                        if (context.mounted) Navigator.of(context).pop();
                        setState(() {});
                      }
                    },
                    child: const Icon(CupertinoIcons.arrow_down_doc_fill),
                  ),
                ),
              ])
        ],
      ),
    );
  }
}

class ExternalApiConfigPage extends StatefulWidget {
  const ExternalApiConfigPage({super.key});

  @override
  ExternalApiConfigPageState createState() => ExternalApiConfigPageState();
}

class ExternalApiConfigPageState extends State<ExternalApiConfigPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemGrey6
        : CupertinoColors.systemGroupedBackground;
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('第三方音源设置', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
            header: Text('音源状态', style: TextStyle(color: textColor)),
            children: [
              if (globalConfig.externalApi != null &&
                  globalConfig.externalApi!.url != null)
                CupertinoFormRow(
                  prefix: Text('音源链接',
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: CupertinoButton(
                    onPressed: () {
                      setClipboard(globalConfig.externalApi!.url!);
                    },
                    child: Text(globalConfig.externalApi!.url!,
                        style: TextStyle(color: textColor)),
                  ),
                ),
              if (globalConfig.externalApi != null)
                CupertinoFormRow(
                  prefix: Text('音源文件',
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: CupertinoButton(
                    onPressed: () {
                      setClipboard(globalConfig.externalApi!.filePath);
                    },
                    child: Text(globalConfig.externalApi!.filePath,
                        style: TextStyle(color: textColor)),
                  ),
                ),
              if (globalConfig.externalApi == null)
                CupertinoFormRow(
                  prefix: Text('音源状态',
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: CupertinoButton(
                    onPressed: () {
                      showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return CupertinoAlertDialog(
                              title: const Text('未找到第三方音源'),
                              content: const Text('请导入第三方音源'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('确定'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    child: Text('未找到第三方音源',
                        style: TextStyle(color: activeIconRed)),
                  ),
                ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text('设置音源', style: TextStyle(color: textColor)),
            children: [
              if (globalConfig.externalApi != null)
                CupertinoFormRow(
                  prefix: Text(
                    '删除音源',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var confirm = await showConfirmationDialog(
                          context,
                          "注意!\n"
                          "该功能将会删除当前使用的第三方音源, 请确保你不再需要该音源\n"
                          "是否继续?");
                      if (confirm == null || !confirm) return;
                      try {
                        globalConfig.externalApi = null;
                        await globalConfig.save(
                            documentFolder: globalDocumentPath);
                        globalExternalApiEvaler = null;
                        LogToast.success(
                            "第三方音源", "删除第三方音源成功", "[externalApi] success");
                      } catch (e) {
                        LogToast.error(
                            "第三方音源", "删除第三方音源失败: $e", "[externalApi] $e");
                      } finally {
                        setState(() {});
                      }
                    },
                    child: Icon(
                      CupertinoIcons.delete_solid,
                      color: activeIconRed,
                    ),
                  ),
                ),
              if (globalConfig.externalApi == null)
                CupertinoFormRow(
                  prefix: Text(
                    '从文件导入',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var filePath = await pickFile();
                      if (filePath == null) return;
                      try {
                        var externalApi = await ExternalApiConfig.fromPath(
                            path: filePath, documentFolder: globalDocumentPath);

                        globalConfig.externalApi = externalApi;
                        await globalConfig.save(
                            documentFolder: globalDocumentPath);
                        globalExternalApiEvaler = ExternalApiEvaler(
                            globalConfig.externalApi!.filePath);

                        if (context.mounted) {
                          context
                              .findAncestorStateOfType<SettingPageState>()
                              ?.refresh();
                        }
                        LogToast.success(
                            "第三方音源", "导入第三方音源成功", "[externalApi] success");
                      } catch (e) {
                        LogToast.error(
                            "第三方音源", "导入第三方音源失败: $e", "[externalApi] $e");
                      } finally {
                        setState(() {});
                      }
                    },
                    child: const Icon(
                      CupertinoIcons.folder_fill,
                    ),
                  ),
                ),
              if (globalConfig.externalApi == null)
                CupertinoFormRow(
                  prefix: Text(
                    '从链接导入',
                    style: TextStyle(color: textColor).useSystemChineseFont(),
                  ),
                  child: CupertinoButton(
                    onPressed: () async {
                      var link = await showInputExternalApiLinkDialog(context);
                      if (link == null) return;
                      try {
                        var externalApi = await ExternalApiConfig.fromUrl(
                            url: link, documentFolder: globalDocumentPath);
                        globalConfig.externalApi = externalApi;
                        await globalConfig.save(
                            documentFolder: globalDocumentPath);
                        globalExternalApiEvaler = ExternalApiEvaler(
                            globalConfig.externalApi!.filePath);
                        LogToast.success(
                            "第三方音源", "导入第三方音源成功", "[externalApi] success");
                      } catch (e) {
                        LogToast.error(
                            "第三方音源", "导入第三方音源失败: $e", "[externalApi] $e");
                      } finally {
                        setState(() {});
                      }
                    },
                    child: const Icon(
                      CupertinoIcons.cloud_download_fill,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WindowConfigPage extends StatefulWidget {
  const WindowConfigPage({super.key});

  @override
  WindowConfigPageState createState() => WindowConfigPageState();
}

class WindowConfigPageState extends State<WindowConfigPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final backgroundColor = brightness == Brightness.dark
        ? CupertinoColors.systemGrey6
        : CupertinoColors.systemGroupedBackground;
    globalConfig.windowConfig ??= WindowConfig.default_();

    if (globalConfig.windowConfig == null) {
      return const Center(
        child: Text('未找到窗口设置'),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text('窗口设置(重启后生效)', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
      child: ListView(
        children: [
          CupertinoFormSection.insetGrouped(
              header: Text('当前窗口大小', style: TextStyle(color: textColor)),
              children: [
                if (Platform.isLinux)
                  CupertinoFormRow(
                    prefix: Text(
                      '窗口大小',
                      style: TextStyle(color: textColor).useSystemChineseFont(),
                    ),
                    child: CupertinoButton(
                      onPressed: openProjectLink,
                      child: Text(
                        "${appWindow.size.width} - ${appWindow.size.height}",
                        style:
                            TextStyle(color: textColor).useSystemChineseFont(),
                      ),
                    ),
                  ),
              ]),
          CupertinoFormSection.insetGrouped(
            header: Text('窗口大小设置', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                  prefix: Text('初始窗口宽度',
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: SizedBox(
                      height: 40,
                      width: 100,
                      child: CupertinoTextField(
                        controller: TextEditingController(
                          text: globalConfig.windowConfig!.width.toString(),
                        ),
                        style: TextStyle(color: textColor),
                        onSubmitted: (value) {
                          globalConfig.windowConfig!.width = int.parse(value);
                          globalConfig.save(documentFolder: globalDocumentPath);
                          setState(() {});
                        },
                      ),
                    ),
                  )),
              CupertinoFormRow(
                prefix: Text('初始窗口高度',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    height: 40,
                    width: 100,
                    child: CupertinoTextField(
                      controller: TextEditingController(
                          text: globalConfig.windowConfig!.height.toString()),
                      style: TextStyle(color: textColor),
                      onSubmitted: (value) {
                        globalConfig.windowConfig!.height = int.parse(value);
                        globalConfig.save(documentFolder: globalDocumentPath);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              CupertinoFormRow(
                prefix: Text('窗口最小宽度',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    height: 40,
                    width: 100,
                    child: CupertinoTextField(
                      controller: TextEditingController(
                          text: globalConfig.windowConfig!.minWidth.toString()),
                      style: TextStyle(color: textColor),
                      onSubmitted: (value) {
                        globalConfig.windowConfig!.minWidth = int.parse(value);
                        globalConfig.save(documentFolder: globalDocumentPath);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              CupertinoFormRow(
                prefix: Text('窗口最小高度',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SizedBox(
                    height: 40,
                    width: 100,
                    child: CupertinoTextField(
                      controller: TextEditingController(
                          text:
                              globalConfig.windowConfig!.minHeight.toString()),
                      style: TextStyle(color: textColor),
                      onSubmitted: (value) {
                        globalConfig.windowConfig!.minHeight = int.parse(value);
                        globalConfig.save(documentFolder: globalDocumentPath);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              CupertinoFormRow(
                prefix: Text('启动时全屏',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoSwitch(
                  value: globalConfig.windowConfig!.fullscreen,
                  onChanged: (value) {
                    globalConfig.windowConfig!.fullscreen = value;
                    globalConfig.save(documentFolder: globalDocumentPath);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text('窗口快捷设置', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                prefix: Text('将当前设为初始窗口大小',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoButton(
                  onPressed: () {
                    globalConfig.windowConfig!.width =
                        appWindow.size.width.toInt();
                    globalConfig.windowConfig!.height =
                        appWindow.size.height.toInt();
                    globalConfig.save(documentFolder: globalDocumentPath);
                    setState(() {});
                  },
                  child: const Icon(CupertinoIcons.rectangle),
                ),
              ),
              CupertinoFormRow(
                prefix: Text('将当前设为最小窗口大小',
                    style: TextStyle(color: textColor).useSystemChineseFont()),
                child: CupertinoButton(
                  onPressed: () {
                    globalConfig.windowConfig!.minWidth =
                        appWindow.size.width.toInt();
                    globalConfig.windowConfig!.minHeight =
                        appWindow.size.height.toInt();
                    globalConfig.save(documentFolder: globalDocumentPath);
                    setState(() {});
                  },
                  child: const Icon(CupertinoIcons.rectangle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
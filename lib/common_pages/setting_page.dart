import 'dart:async';
import 'dart:io';
import 'package:app_rhyme/common_comps/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/database_url_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/file_name_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/input_extern_api_link_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/quality_select_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/wait_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache/cache_util.dart';
import 'package:app_rhyme/src/rust/api/music_api/fns.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_api/wrapper.dart';
import 'package:app_rhyme/src/rust/api/types/config.dart';
import 'package:app_rhyme/src/rust/api/types/external_api.dart';
import 'package:app_rhyme/src/rust/api/utils/database.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/clipboard_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/types/plugin.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:app_rhyme/utils/pick_file.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.isDesktop});
  final bool isDesktop;
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
    final isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
        backgroundColor: getSettingPageBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              backgroundColor: getNavigatorBarColor(isDarkMode),
              middle: Text(
                '设置',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: textColor,
                ).useSystemChineseFont(),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: Text('应用信息',
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                    children: [
                      CupertinoFormRow(
                        prefix: Text(
                          '版本号',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont(),
                        ),
                        child: CupertinoButton(
                          onPressed: () async {
                            await checkVersionUpdate(context, true);
                          },
                          child: Text(
                            globalPackageInfo.version,
                            style: TextStyle(color: CupertinoColors.activeBlue)
                                .useSystemChineseFont(),
                          ),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text(
                          '项目仓库',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont(),
                        ),
                        child: CupertinoButton(
                          onPressed: openProjectRepoLink,
                          child: Text(
                            'github.com/canxin121/app_rhyme',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  CupertinoFormSection.insetGrouped(children: [
                    CupertinoFormRow(
                      prefix: Text('音质设置',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont()),
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    const QualityConfigPage()),
                          );
                        },
                        child: const Icon(CupertinoIcons.right_chevron),
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: Text('更新设置',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont()),
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
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont()),
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => StorageConfigPage(
                                      isDesktop: widget.isDesktop,
                                    )),
                          );
                        },
                        child: const Icon(CupertinoIcons.right_chevron),
                      ),
                    ),
                    CupertinoFormRow(
                      prefix: Text('音源设置',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont()),
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    const ExternalApiConfigPage()),
                          );
                        },
                        child: const Icon(CupertinoIcons.right_chevron),
                      ),
                    ),
                    if (widget.isDesktop)
                      CupertinoFormRow(
                        prefix: Text('窗口设置',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      const WindowConfigPage()),
                            );
                          },
                          child: const Icon(CupertinoIcons.right_chevron),
                        ),
                      ),
                    CupertinoFormRow(
                      prefix: Text('导出日志',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont()),
                      child: CupertinoButton(
                        onPressed: () {
                          exportLogCompressed(context);
                        },
                        child: const Icon(CupertinoIcons.right_chevron),
                      ),
                    ),
                  ])
                ],
              ),
            )
          ],
        ));
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
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
        backgroundColor: getSettingPageBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              backgroundColor: getNavigatorBarColor(isDarkMode),
              middle: Text('音质设置', style: TextStyle(color: textColor)),
            ),
            Expanded(
              child: ListView(
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: Text('音质自动选择设置',
                        style:
                            TextStyle(color: textColor).useSystemChineseFont()),
                    children: [
                      CupertinoFormRow(
                        prefix: Text(
                            (Platform.isAndroid || Platform.isIOS)
                                ? 'WiFi 自动选择音质'
                                : '自动选择音质',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoButton(
                          child: Text(
                              qualityOptionToString(
                                  globalConfig.qualityConfig.wifiAutoQuality),
                              style: const TextStyle(
                                  color: CupertinoColors.activeBlue)),
                          onPressed: () async {
                            var quality =
                                await showQualityOptionDialog(context);
                            if (quality != null) {
                              setState(() {
                                globalConfig.qualityConfig.wifiAutoQuality =
                                    quality;
                                globalConfig.save(
                                    documentFolder: globalDocumentPath);
                              });
                            }
                          },
                        ),
                      ),
                      if (Platform.isAndroid || Platform.isIOS)
                        CupertinoFormRow(
                          prefix: Text('移动网络自动选择音质',
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont()),
                          child: CupertinoButton(
                            child: Text(
                                qualityOptionToString(globalConfig
                                    .qualityConfig.mobileAutoQuality),
                                style: const TextStyle(
                                    color: CupertinoColors.activeBlue)),
                            onPressed: () async {
                              var quality =
                                  await showQualityOptionDialog(context);
                              if (quality != null) {
                                globalConfig.qualityConfig.mobileAutoQuality =
                                    quality;
                                globalConfig.save(
                                    documentFolder: globalDocumentPath);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
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
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
        backgroundColor: getSettingPageBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              backgroundColor: getNavigatorBarColor(isDarkMode),
              middle: Text('更新设置', style: TextStyle(color: textColor)),
            ),
            Expanded(
              child: ListView(
                children: [
                  CupertinoFormSection.insetGrouped(
                    header:
                        Text('自动检查更新设置', style: TextStyle(color: textColor)),
                    children: [
                      CupertinoFormRow(
                        prefix: Text('自动检查版本更新',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoSwitch(
                          value: globalConfig.updateConfig.versionAutoUpdate,
                          onChanged: (value) {
                            globalConfig.updateConfig.versionAutoUpdate = value;
                            globalConfig.save(
                                documentFolder: globalDocumentPath);
                            setState(() {});
                          },
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text('自动检查音源更新',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoSwitch(
                          value:
                              globalConfig.updateConfig.externalApiAutoUpdate,
                          onChanged: (value) {
                            globalConfig.updateConfig.externalApiAutoUpdate =
                                value;
                            globalConfig.save(
                                documentFolder: globalDocumentPath);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

class StorageConfigPage extends StatefulWidget {
  const StorageConfigPage({super.key, required this.isDesktop});
  final bool isDesktop;

  @override
  StorageConfigPageState createState() => StorageConfigPageState();
}

class StorageConfigPageState extends State<StorageConfigPage>
    with WidgetsBindingObserver {
  String storagePath = "";

  @override
  void initState() {
    super.initState();
    storagePath =
        globalConfig.storageConfig.customCacheRoot ?? globalDocumentPath;
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

  Future<void> useNewCacheRoot(bool needMove, bool isDesktop) async {
    var newCustomCacheRoot = await pickDirectory();
    if (newCustomCacheRoot == null) return;
    if (globalConfig.storageConfig.customCacheRoot != null &&
        globalConfig.storageConfig.customCacheRoot == newCustomCacheRoot) {
      LogToast.info("缓存设置", "目标文件夹与原缓存文件夹相同, 无需操作",
          "[storageConfig.useNewCacheRoot] Same as original folder, no need to operate");
      return;
    }

    try {
      // 解除所有资源的占用
      await globalAudioHandler.clear();
      await closeDb();

      if (needMove) {
        if (mounted) {
          await showWaitDialog(context, isDesktop, "正在移动数据中,稍后将自动退出应用以应用更改");
        }

        await moveCacheData(
            documentPath: globalDocumentPath,
            newCustomCacheRoot: newCustomCacheRoot,
            oldCustomCacheRoot: globalConfig.storageConfig.customCacheRoot);
      } else {
        if (mounted) {
          await showWaitDialog(context, isDesktop, "正在清理旧数据中,稍后将自动退出应用以应用更改");
        }

        await deleteCacheData(
            documentPath: globalDocumentPath,
            customCacheRoot: globalConfig.storageConfig.customCacheRoot);
      }

      globalConfig.storageConfig.customCacheRoot = newCustomCacheRoot;
      await globalConfig.save(documentFolder: globalDocumentPath);
    } catch (e) {
      LogToast.error("缓存设置", "移动缓存文件夹失败: $e",
          "[storageConfig.useNewCacheRoot] failed: $e");
    } finally {
      await exitApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    return CupertinoPageScaffold(
        backgroundColor: getSettingPageBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              middle: Text('储存设置', style: TextStyle(color: textColor)),
              backgroundColor: getNavigatorBarColor(isDarkMode),
            ),
            Expanded(
              child: ListView(
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: Text('自动缓存设置', style: TextStyle(color: textColor)),
                    children: [
                      CupertinoFormRow(
                        prefix: Text('缓存封面',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoSwitch(
                          value: globalConfig.storageConfig.saveCover,
                          onChanged: (value) async {
                            globalConfig.storageConfig.saveCover = value;
                            globalConfig.save(
                                documentFolder: globalDocumentPath);
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  if (!Platform.isIOS)
                    CupertinoFormSection.insetGrouped(
                      header:
                          Text('缓存目录设置', style: TextStyle(color: textColor)),
                      children: [
                        CupertinoFormRow(
                          prefix: Text('当前缓存目录',
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont()),
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
                                    storagePath,
                                    style: TextStyle(color: textColor)
                                        .useSystemChineseFont(),
                                  ))),
                        ),
                        CupertinoFormRow(
                          prefix: Text(
                            '移动缓存文件夹',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              var confirm = await showConfirmationDialog(
                                  context,
                                  "注意!\n"
                                  "该功能将会将当前使用的缓存文件夹下的缓存数据迁移到新的文件夹下\n"
                                  "请确保新的文件夹下没有AppRhyme的数据, 否则会导致该目标文件夹中数据完全丢失!!!\n"
                                  "如果你想直接使用指定文件夹下的数据, 请使用'使用缓存文件夹'功能\n"
                                  "是否继续?");
                              if (confirm != null && confirm) {
                                await useNewCacheRoot(true, widget.isDesktop);
                              }
                            },
                            child: const Icon(CupertinoIcons.folder),
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: Text(
                            '使用缓存文件夹',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              var confirm = await showConfirmationDialog(
                                  context,
                                  "注意!\n"
                                  "该功能将会直接使用指定文件夹下的缓存数据, 请确保目标文件夹下有正确的缓存数据\n"
                                  "这将会导致当前使用的缓存文件夹下的缓存数据完全丢失!!!\n"
                                  "如果你想移动缓存数据到目标文件夹, 请使用'移动缓存文件夹'功能\n"
                                  "是否继续?");

                              if (confirm != null && confirm) {
                                await useNewCacheRoot(false, widget.isDesktop);
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
                    header:
                        Text('数据库Sql设置', style: TextStyle(color: textColor)),
                    children: [
                      CupertinoFormRow(
                        prefix: Text('当前数据库',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
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
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont(),
                        ),
                        child: CupertinoButton(
                          onPressed: () async {
                            var confirm = await showConfirmationDialog(
                                context,
                                "注意!\n"
                                "该功能可能导致数据丢失, 请先备份一份数据库Json文件后使用"
                                "该功能将会将当前使用的歌单数据库迁移到新的数据库中\n"
                                "请确保目标数据库中没有AppRhyme的数据, 否则会导致该目标数据库中数据完全丢失!!!\n"
                                "如果你想直接使用目标数据库下的数据, 请使用'使用歌单数据库'功能\n"
                                "是否继续?");
                            if (confirm == null || !confirm) return;
                            if (!context.mounted) return;
                            String? newDbUrl;

                            if (Platform.isIOS) {
                              newDbUrl =
                                  await showIosDatabaseUrlDialog(context);
                            } else {
                              newDbUrl =
                                  await showNewDatabaseUrlDialog(context);
                            }

                            if (newDbUrl == null) return;
                            if (!context.mounted) return;
                            try {
                              verifySqliteUrl(sqliteUrl: newDbUrl);
                            } catch (e) {
                              LogToast.error("数据库设置", "sqlite数据库链接有误: $e",
                                  "[storageConfig.moveDatabase] failed: $e");
                              return;
                            }
                            await showWaitDialog(
                                context, widget.isDesktop, "正在移动数据中");
                            try {
                              globalConfig.storageConfig.customDb = newDbUrl;
                              globalConfig.save(
                                  documentFolder: globalDocumentPath);
                              var musicDataJson =
                                  await MusicDataJsonWrapper.fromDatabase();
                              await clearDb();
                              await setDb(databaseUrl: newDbUrl);
                              await clearDb();
                              await musicDataJson.applyToDb();

                              playlistCollectionsPageRefreshStreamController
                                  .add(null);
                              LogToast.success("数据库设置", "数据库移动成功",
                                  "[storageConfig.moveDatabase] success");
                            } catch (e) {
                              LogToast.error("数据库设置", "数据库移动失败: $e",
                                  "[storageConfig.moveDatabase] failed: $e");
                            } finally {
                              if (context.mounted) {
                                popPage(context, widget.isDesktop);
                              }
                            }
                          },
                          child: const Icon(CupertinoIcons.tray_2_fill),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text(
                          '使用歌单数据库',
                          style: TextStyle(color: textColor)
                              .useSystemChineseFont(),
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
                            String? dbUrl;

                            if (Platform.isAndroid) {
                              dbUrl = await showNewDatabaseUrlDialog(context);
                            } else if (Platform.isIOS) {
                              dbUrl = await showIosDatabaseUrlDialog(context);
                            } else {
                              dbUrl = await showExistDatabaseUrlDialog(context);
                            }

                            if (dbUrl == null) return;
                            if (!context.mounted) return;
                            await showWaitDialog(
                                context, widget.isDesktop, "正在清除数据中");

                            try {
                              verifySqliteUrl(sqliteUrl: dbUrl);
                            } catch (e) {
                              LogToast.error("数据库设置", "sqlite数据库链接有误: $e",
                                  "[storageConfig.moveDatabase] failed: $e");
                              return;
                            }
                            try {
                              globalConfig.storageConfig.customDb = dbUrl;
                              globalConfig.save(
                                  documentFolder: globalDocumentPath);

                              await clearDb();
                              await setDb(databaseUrl: dbUrl);
                              playlistCollectionsPageRefreshStreamController
                                  .add(null);

                              LogToast.success("数据库设置", "数据库设置成功",
                                  "[storageConfig.moveDatabase] success");
                            } catch (e) {
                              LogToast.error("数据库设置", "数据库设置失败: $e",
                                  "[storageConfig.moveDatabase] failed: $e");
                            } finally {
                              if (context.mounted) {
                                popPage(context, widget.isDesktop);
                              }
                            }
                          },
                          child: const Icon(CupertinoIcons.tray_2_fill),
                        ),
                      ),
                    ],
                  ),
                  CupertinoFormSection.insetGrouped(
                      header:
                          Text('数据库Json设置', style: TextStyle(color: textColor)),
                      children: [
                        CupertinoFormRow(
                          prefix: Text(
                            '导出json文件',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
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
                                    await MusicDataJsonWrapper.fromDatabase();
                                await databaseJson.saveTo(path: filePath);
                                LogToast.success(
                                    "数据库导出",
                                    "数据库导出为json成功: $filePath",
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
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              await importDatabaseJson(
                                  context, widget.isDesktop);
                            },
                            child:
                                const Icon(CupertinoIcons.arrow_down_doc_fill),
                          ),
                        ),
                      ]),
                  CupertinoFormSection.insetGrouped(
                      header:
                          Text('导入Json文件', style: TextStyle(color: textColor)),
                      children: [
                        CupertinoFormRow(
                          prefix: Text(
                            '导入任意json文件',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              var file = await pickFile();
                              if (file == null) return;
                              try {
                                var musicDataJson =
                                    await MusicDataJsonWrapper.loadFrom(
                                        path: file);
                                switch (await musicDataJson.getType()) {
                                  case MusicDataType.database:
                                    if (context.mounted) {
                                      await importDatabaseJson(
                                          context, widget.isDesktop,
                                          musicDataJson: musicDataJson);
                                    }
                                  case MusicDataType.playlists:
                                    if (context.mounted) {
                                      await importPlaylistJson(context,
                                          musicDataJson: musicDataJson);
                                    }
                                  case MusicDataType.musicAggregators:
                                    if (context.mounted) {
                                      await importMusicAggrgegatorJson(context,
                                          musicDataJson: musicDataJson);
                                    }
                                }
                              } catch (e) {
                                LogToast.error("导入Json文件", "$e",
                                    "[storageConfig.importJson] $e");
                              }
                            },
                            child:
                                const Icon(CupertinoIcons.arrow_down_doc_fill),
                          ),
                        ),
                      ]),
                  CupertinoFormSection.insetGrouped(
                      header: Text('清理空间', style: TextStyle(color: textColor)),
                      children: [
                        CupertinoFormRow(
                          prefix: Text(
                            '清理未使用Db数据',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              try {
                                await MusicAggregator.clearUnused();
                                LogToast.success("清理空间", "清理未使用Db数据成功",
                                    "[storageConfig.clearDb] success");
                              } catch (e) {
                                LogToast.error("清理空间", "清理未使用Db数据失败: $e",
                                    "[storageConfig.clearDb] $e");
                              }
                            },
                            child:
                                const Icon(CupertinoIcons.clear_circled_solid),
                          ),
                        ),
                        CupertinoFormRow(
                          prefix: Text(
                            '清理缓存',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              var confirm = await showConfirmationDialog(
                                  context,
                                  "注意!\n"
                                  "该功能将会清理所有缓存数据, 请确保你不再需要这些数据\n"
                                  "是否继续?");
                              if (confirm == null || !confirm) return;
                              try {
                                await deleteCacheData(
                                    documentPath: globalDocumentPath,
                                    customCacheRoot: globalConfig
                                        .storageConfig.customCacheRoot);
                                LogToast.success("清理空间", "清理缓存成功",
                                    "[storageConfig.clearCache] success");
                              } catch (e) {
                                LogToast.error("清理空间", "清理缓存失败: $e",
                                    "[storageConfig.clearCache] $e");
                              }
                            },
                            child:
                                const Icon(CupertinoIcons.clear_circled_solid),
                          ),
                        ),
                      ])
                ],
              ),
            )
          ],
        ));
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
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    return CupertinoPageScaffold(
        backgroundColor: getSettingPageBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              middle: Text('第三方音源设置', style: TextStyle(color: textColor)),
              backgroundColor: getNavigatorBarColor(isDarkMode),
            ),
            Expanded(
              child: ListView(
                children: [
                  CupertinoFormSection.insetGrouped(
                    header: Text('音源状态', style: TextStyle(color: textColor)),
                    children: [
                      if (globalConfig.externalApi != null &&
                          globalConfig.externalApi!.url != null)
                        CupertinoFormRow(
                          prefix: Text('音源链接',
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont()),
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
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont()),
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
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont()),
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
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
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
                                LogToast.success("第三方音源", "删除第三方音源成功",
                                    "[externalApi] success");
                              } catch (e) {
                                LogToast.error("第三方音源", "删除第三方音源失败: $e",
                                    "[externalApi] $e");
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
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              var filePath = await pickFile();
                              if (filePath == null) return;
                              try {
                                var externalApi =
                                    await ExternalApiConfig.fromPath(
                                        path: filePath,
                                        customCacheRoot: globalConfig
                                            .storageConfig.customCacheRoot,
                                        documentFolder: globalDocumentPath);

                                globalConfig.externalApi = externalApi;
                                await globalConfig.save(
                                    documentFolder: globalDocumentPath);
                                globalExternalApiEvaler = PluginEvaler(
                                    globalConfig.externalApi!.filePath);

                                if (context.mounted) {
                                  context
                                      .findAncestorStateOfType<
                                          SettingPageState>()
                                      ?.refresh();
                                }
                                LogToast.success("第三方音源", "导入第三方音源成功",
                                    "[externalApi] success");
                              } catch (e) {
                                LogToast.error("第三方音源", "导入第三方音源失败: $e",
                                    "[externalApi] $e");
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
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont(),
                          ),
                          child: CupertinoButton(
                            onPressed: () async {
                              var link =
                                  await showInputExternalApiLinkDialog(context);
                              if (link == null) return;
                              try {
                                var externalApi =
                                    await ExternalApiConfig.fromUrl(
                                        url: link,
                                        documentFolder: globalDocumentPath,
                                        customCacheRoot: globalConfig
                                            .storageConfig.customCacheRoot);

                                globalConfig.externalApi = externalApi;
                                await globalConfig.save(
                                    documentFolder: globalDocumentPath);
                                globalExternalApiEvaler = PluginEvaler(
                                    globalConfig.externalApi!.filePath);
                                LogToast.success("第三方音源", "导入第三方音源成功",
                                    "[externalApi] success");
                              } catch (e) {
                                LogToast.error("第三方音源", "导入第三方音源失败: $e",
                                    "[externalApi] $e");
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
            )
          ],
        ));
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
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    globalConfig.windowConfig ??= WindowConfig.default_();

    if (globalConfig.windowConfig == null) {
      return const Center(
        child: Text('未找到窗口设置'),
      );
    }

    return CupertinoPageScaffold(
        backgroundColor: getSettingPageBackgroundColor(isDarkMode),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoNavigationBar(
              middle: Text('窗口设置(重启后生效)', style: TextStyle(color: textColor)),
              backgroundColor: getNavigatorBarColor(isDarkMode),
            ),
            Expanded(
              child: ListView(
                children: [
                  CupertinoFormSection.insetGrouped(
                      header:
                          Text('当前窗口大小', style: TextStyle(color: textColor)),
                      children: [
                        if (Platform.isLinux)
                          CupertinoFormRow(
                            prefix: Text(
                              '窗口大小',
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont(),
                            ),
                            child: CupertinoButton(
                              onPressed: openProjectRepoLink,
                              child: Text(
                                "${appWindow.size.width} - ${appWindow.size.height}",
                                style: TextStyle(color: textColor)
                                    .useSystemChineseFont(),
                              ),
                            ),
                          ),
                      ]),
                  CupertinoFormSection.insetGrouped(
                    header: Text('窗口大小设置', style: TextStyle(color: textColor)),
                    children: [
                      CupertinoFormRow(
                          prefix: Text('初始窗口宽度',
                              style: TextStyle(color: textColor)
                                  .useSystemChineseFont()),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: SizedBox(
                              height: 40,
                              width: 100,
                              child: CupertinoTextField(
                                controller: TextEditingController(
                                  text: globalConfig.windowConfig!.width
                                      .toString(),
                                ),
                                style: TextStyle(color: textColor),
                                onSubmitted: (value) {
                                  globalConfig.windowConfig!.width =
                                      int.parse(value);
                                  globalConfig.save(
                                      documentFolder: globalDocumentPath);
                                  setState(() {});
                                },
                              ),
                            ),
                          )),
                      CupertinoFormRow(
                        prefix: Text('初始窗口高度',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: SizedBox(
                            height: 40,
                            width: 100,
                            child: CupertinoTextField(
                              controller: TextEditingController(
                                  text: globalConfig.windowConfig!.height
                                      .toString()),
                              style: TextStyle(color: textColor),
                              onSubmitted: (value) {
                                globalConfig.windowConfig!.height =
                                    int.parse(value);
                                globalConfig.save(
                                    documentFolder: globalDocumentPath);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text('窗口最小宽度',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: SizedBox(
                            height: 40,
                            width: 100,
                            child: CupertinoTextField(
                              controller: TextEditingController(
                                  text: globalConfig.windowConfig!.minWidth
                                      .toString()),
                              style: TextStyle(color: textColor),
                              onSubmitted: (value) {
                                globalConfig.windowConfig!.minWidth =
                                    int.parse(value);
                                globalConfig.save(
                                    documentFolder: globalDocumentPath);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text('窗口最小高度',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: SizedBox(
                            height: 40,
                            width: 100,
                            child: CupertinoTextField(
                              controller: TextEditingController(
                                  text: globalConfig.windowConfig!.minHeight
                                      .toString()),
                              style: TextStyle(color: textColor),
                              onSubmitted: (value) {
                                globalConfig.windowConfig!.minHeight =
                                    int.parse(value);
                                globalConfig.save(
                                    documentFolder: globalDocumentPath);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text('启动时全屏',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoSwitch(
                          value: globalConfig.windowConfig!.fullscreen,
                          onChanged: (value) {
                            globalConfig.windowConfig!.fullscreen = value;
                            globalConfig.save(
                                documentFolder: globalDocumentPath);
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
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoButton(
                          onPressed: () {
                            globalConfig.windowConfig!.width =
                                appWindow.size.width.toInt();
                            globalConfig.windowConfig!.height =
                                appWindow.size.height.toInt();
                            globalConfig.save(
                                documentFolder: globalDocumentPath);
                            setState(() {});
                          },
                          child: const Icon(CupertinoIcons.rectangle),
                        ),
                      ),
                      CupertinoFormRow(
                        prefix: Text('将当前设为最小窗口大小',
                            style: TextStyle(color: textColor)
                                .useSystemChineseFont()),
                        child: CupertinoButton(
                          onPressed: () {
                            globalConfig.windowConfig!.minWidth =
                                appWindow.size.width.toInt();
                            globalConfig.windowConfig!.minHeight =
                                appWindow.size.height.toInt();
                            globalConfig.save(
                                documentFolder: globalDocumentPath);
                            setState(() {});
                          },
                          child: const Icon(CupertinoIcons.rectangle),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

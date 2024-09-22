import 'dart:async';
import 'dart:io';

import 'package:app_rhyme/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/dialogs/input_extern_api_link_dialog.dart';
import 'package:app_rhyme/dialogs/quality_select_dialog.dart';
import 'package:app_rhyme/dialogs/wait_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache/fs_util.dart';
import 'package:app_rhyme/src/rust/api/music_api/fns.dart';
import 'package:app_rhyme/src/rust/api/types/extern_api.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/types/extern_api.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  MorePageState createState() => MorePageState();
}

class MorePageState extends State<MorePage> with WidgetsBindingObserver {
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
                        child: imageWithCache(""),
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
                    value: globalConfig.versionAutoUpdate,
                    onChanged: (value) {
                      if (value != globalConfig.versionAutoUpdate) {
                        globalConfig.versionAutoUpdate = value;
                        globalConfig.save();
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
          CupertinoFormSection.insetGrouped(
            header: Text("音频设置",
                style: TextStyle(color: textColor).useSystemChineseFont()),
            children: [
              CupertinoFormRow(
                  prefix: Text("清空待播清单",
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: CupertinoButton(
                      child: Icon(
                        CupertinoIcons.clear,
                        color: activeIconRed,
                      ),
                      onPressed: () {
                        globalAudioHandler.clear();
                      }))
            ],
          ),
          _buildExternApiSection(textColor, iconColor),
          _buildQualitySelectSection(context, () {
            setState(() {});
          }, textColor),
          // IOS系统无法直接访问文件系统，且已开启在文件中显示应用数据，所以不显示此选项
          if (!Platform.isIOS)
            _buildExportCacheRoot(context, refresh, textColor, iconColor),
          CupertinoFormSection.insetGrouped(
            header: Text('储存设置',
                style: TextStyle(color: textColor).useSystemChineseFont()),
            children: [
              CupertinoFormRow(
                prefix: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      '保存歌曲时缓存歌曲封面',
                      style: TextStyle(color: textColor).useSystemChineseFont(),
                    )),
                child: CupertinoSwitch(
                    value: globalConfig.savePicWhenAddMusicList,
                    onChanged: (value) {
                      if (value != globalConfig.savePicWhenAddMusicList) {
                        globalConfig.savePicWhenAddMusicList = value;
                        globalConfig.save();
                        setState(() {});
                      }
                    }),
              ),
              CupertinoFormRow(
                prefix: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      '保存歌单时缓存歌曲歌词',
                      style: TextStyle(color: textColor).useSystemChineseFont(),
                    )),
                child: CupertinoSwitch(
                    value: globalConfig.saveLyricWhenAddMusicList,
                    onChanged: (value) {
                      if (value != globalConfig.saveLyricWhenAddMusicList) {
                        globalConfig.saveLyricWhenAddMusicList = value;
                        globalConfig.save();
                        setState(() {});
                      }
                    }),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text('其他',
                style: TextStyle(color: textColor).useSystemChineseFont()),
            children: [
              CupertinoFormRow(
                  prefix: Text("运行日志",
                      style:
                          TextStyle(color: textColor).useSystemChineseFont()),
                  child: CupertinoButton(
                      child: const Icon(
                        CupertinoIcons.book,
                        color: CupertinoColors.activeGreen,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) =>
                              TalkerScreen(talker: globalTalker),
                        ));
                      })),
            ],
          ),
        ],
      ),
    );
  }

  CupertinoFormSection _buildExternApiSection(
      Color textColor, Color iconColor) {
    bool hasExternApi = globalConfig.externApi != null;
    bool isOnlineLink = globalConfig.externApi?.url != null;
    List<Widget> children = [];
    if (hasExternApi) {
      children.add(CupertinoFormRow(
          prefix: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '音源状态',
                style: TextStyle(color: textColor).useSystemChineseFont(),
              )),
          child: Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              height: 50,
              child: Text(
                "正常",
                style: const TextStyle(color: CupertinoColors.activeGreen)
                    .useSystemChineseFont(),
              ))));
    } else {
      children.add(CupertinoFormRow(
          prefix: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '音源状态',
                style: TextStyle(color: textColor).useSystemChineseFont(),
              )),
          child: Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              height: 50,
              child: Text(
                "未导入",
                style: TextStyle(color: activeIconRed).useSystemChineseFont(),
              ))));
    }
    if (hasExternApi) {
      if (isOnlineLink) {
        children.add(CupertinoFormRow(
            prefix: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '音源链接',
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                )),
            child: CupertinoButton(
              child: Text(
                globalConfig.externApi!.url!,
                style: TextStyle(color: textColor).useSystemChineseFont(),
              ),
              onPressed: () async {
                try {
                  await Clipboard.setData(
                      ClipboardData(text: globalConfig.externApi!.url!));
                  LogToast.success("音源链接", "已复制至剪切板",
                      "[MorePage] Copied extern api link to clipboard");
                } catch (e) {
                  LogToast.error("音源链接", "复制链接失败: $e",
                      "[MorePage] Failed to copy extern api link: $e");
                }
              },
            )));
        children.add(
          CupertinoFormRow(
            prefix: Text('检查更新',
                style: TextStyle(color: textColor).useSystemChineseFont()),
            child: CupertinoButton(
              onPressed: () async {
                await checkExternApiUpdate(context, true);
                setState(() {});
              },
              child: Icon(CupertinoIcons.cloud, color: iconColor),
            ),
          ),
        );
        children.add(CupertinoFormRow(
          prefix: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '自动检查更新',
                style: TextStyle(color: textColor).useSystemChineseFont(),
              )),
          child: CupertinoSwitch(
              value: globalConfig.externApiAutoUpdate,
              onChanged: (value) {
                if (value != globalConfig.externApiAutoUpdate) {
                  globalConfig.externApiAutoUpdate = value;
                  globalConfig.save();
                  setState(() {});
                }
              }),
        ));
      }
    }
    if (hasExternApi) {
      children.add(CupertinoFormRow(
          prefix: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '删除音源',
                style: TextStyle(color: textColor).useSystemChineseFont(),
              )),
          child: CupertinoButton(
              onPressed: () {
                globalConfig.externApi = null;
                globalConfig.save();
                globalExternApiEvaler = null;

                setState(() {});
              },
              child: Icon(
                CupertinoIcons.delete,
                color: activeIconRed,
              ))));
    } else {
      children.add(CupertinoFormRow(
          prefix: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '导入音源',
                style: TextStyle(color: textColor).useSystemChineseFont(),
              )),
          child: ImportExternApiMenu(
              builder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  child:
                      Icon(CupertinoIcons.music_note_2, color: iconColor)))));
    }
    return CupertinoFormSection.insetGrouped(
        header: Text("自定义音源",
            style: TextStyle(color: textColor).useSystemChineseFont()),
        children: children);
  }
}

@immutable
class ImportExternApiMenu extends StatelessWidget {
  const ImportExternApiMenu({
    super.key,
    required this.builder,
  });
  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null) {
              var path = await cacheFileFromUriWrapper(
                result.files.single.path!,
                "",
                filename: "extern_api_cache",
              );
              try {
                var externApi = await ExternApi.fromPath(path: path);
                globalConfig.externApi = externApi;
                globalConfig.save();
                globalExternApiEvaler = ExternApiEvaler(path);
                if (context.mounted) {
                  context.findAncestorStateOfType<MorePageState>()?.refresh();
                }
              } catch (e) {
                globalTalker.error("[More Page] 导入第三方音乐源失败:$e");
              }
            }
          },
          title: '文件导入',
          icon: CupertinoIcons.folder,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            var link = await showInputExternApiLinkDialog(context);
            if (link != null) {
              var externApi = await ExternApi.fromUrl(url: link);
              globalConfig.externApi = externApi;
              globalConfig.save();
              globalExternApiEvaler =
                  ExternApiEvaler(globalConfig.externApi!.localPath);
              if (context.mounted) {
                context.findAncestorStateOfType<MorePageState>()?.refresh();
              }
            }
          },
          title: '链接导入',
          icon: CupertinoIcons.link,
        ),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

CupertinoFormSection _buildQualitySelectSection(
    BuildContext context, void Function() refresh, Color textColor) {
  List<Widget> children = [];

  if (Platform.isAndroid || Platform.isIOS) {
    children.add(CupertinoFormRow(
        prefix: Text("Wifi下音质选择",
            style: TextStyle(color: textColor).useSystemChineseFont()),
        child: CupertinoButton(
            onPressed: () async {
              QualityOption? selectedOption =
                  await showQualityOptionDialog(context);
              if (selectedOption != null) {
                String qualityString = qualityOptionToString(selectedOption);
                globalConfig.wifiAutoQuality = qualityString;
                await globalConfig.save();
              }
              refresh();
            },
            child: Text(globalConfig.wifiAutoQuality,
                style: TextStyle(color: textColor)))));
    children.add(CupertinoFormRow(
        prefix: Text("数据网络下音质选择",
            style: TextStyle(color: textColor).useSystemChineseFont()),
        child: CupertinoButton(
            onPressed: () async {
              QualityOption? selectedOption =
                  await showQualityOptionDialog(context);
              if (selectedOption != null) {
                String qualityString = qualityOptionToString(selectedOption);
                globalConfig.mobileAutoQuality = qualityString;
                await globalConfig.save();
              }
              refresh();
            },
            child: Text(globalConfig.mobileAutoQuality,
                style: TextStyle(color: textColor).useSystemChineseFont()))));
  } else {
    children.add(CupertinoFormRow(
        prefix: Text("音质选择",
            style: TextStyle(color: textColor).useSystemChineseFont()),
        child: CupertinoButton(
            onPressed: () async {
              QualityOption? selectedOption =
                  await showQualityOptionDialog(context);
              if (selectedOption != null) {
                String qualityString = qualityOptionToString(selectedOption);
                globalConfig.wifiAutoQuality = qualityString;
                await globalConfig.save();
              }
              refresh();
            },
            child: Text(globalConfig.wifiAutoQuality,
                style: TextStyle(color: textColor).useSystemChineseFont()))));
  }
  return CupertinoFormSection.insetGrouped(
    header:
        Text('音质选择', style: TextStyle(color: textColor).useSystemChineseFont()),
    children: children,
  );
}

CupertinoFormSection _buildExportCacheRoot(BuildContext context,
    void Function() refresh, Color textColor, Color iconColor) {
  Future<void> exportCacheRoot(bool copy) async {
    var path = await pickDirectory();
    if (path == null) return;
    if (globalConfig.exportCacheRoot != null &&
        globalConfig.exportCacheRoot == path) {
      LogToast.info("数据设定", "与原文件夹相同, 无需操作",
          "[exportCacheRoot] Same as original folder, no need to operate");
      return;
    }
    try {
      try {
        if (context.mounted) {
          await showWaitDialog(context, "正在处理中,稍后将自动退出应用以应用更改");
        }
        await globalAudioHandler.clear();
        await closeDb();
        late String originRootPath;
        if (globalConfig.exportCacheRoot != null &&
            globalConfig.exportCacheRoot!.isNotEmpty) {
          originRootPath = globalConfig.exportCacheRoot!;
        } else {
          originRootPath = "$globalDocumentPath/AppRhyme";
        }
        if (copy) {
          await copyDirectory(
              src: "$originRootPath/$picCacheFolder",
              dst: "$path/$picCacheFolder");
          await copyDirectory(
              src: "$originRootPath/$musicCacheFolder",
              dst: "$path/$musicCacheFolder");
          await copyFile(
              from: "$originRootPath/MusicData.db", to: "$path/MusicData.db");
        }

        globalConfig.lastExportCacheRoot = globalConfig.exportCacheRoot;
        globalConfig.exportCacheRoot = path;
        globalConfig.save();
        if (context.mounted) {
          context.findAncestorStateOfType<MorePageState>()?.refresh();
        }
      } finally {
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
      try {
        if (context.mounted) {
          await showWaitDialog(context,
              "应用将在3秒后退出\n下次打开时将删除旧文件夹下数据, 并应用新文件夹下数据\n如未正常退出, 请关闭应用后重新打开");
        }
        await Future.delayed(const Duration(seconds: 3));
      } finally {
        if (context.mounted) {
          Navigator.pop(context);
        }
        await exitApp();
      }
    } catch (e) {
      LogToast.error("数据设定", "数据设定失败: $e", "[exportCacheRoot] $e");
    }
  }

  List<CupertinoFormRow> children = [];
  if (globalConfig.exportCacheRoot == null) {
    children.add(CupertinoFormRow(
        prefix: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              '当前数据状态',
              style: TextStyle(color: textColor).useSystemChineseFont(),
            )),
        child: Container(
            padding: const EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            height: 50,
            child: Text(
              "应用内部数据",
              style: TextStyle(color: textColor).useSystemChineseFont(),
            ))));
  } else {
    children.add(CupertinoFormRow(
        prefix: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              '当前数据文件夹',
              style: TextStyle(color: textColor).useSystemChineseFont(),
            )),
        child: Container(
            padding: const EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            height: 50,
            child: Text(
              globalConfig.exportCacheRoot!,
              style: TextStyle(color: textColor).useSystemChineseFont(),
            ))));
  }
  children.add(
    CupertinoFormRow(
      prefix: Text(
        '迁移数据文件夹',
        style: TextStyle(color: textColor).useSystemChineseFont(),
      ),
      child: CupertinoButton(
        onPressed: () async {
          var confirm = await showConfirmationDialog(
              context,
              "注意!\n"
              "迁移数据将会将当前使用文件夹下的数据迁移到新的文件夹下\n"
              "请确保新的文件夹下没有AppRhyme的数据, 否则会导致该文件夹中数据完全丢失!!!\n"
              "如果你想直接使用指定文件夹下的数据, 请使用'使用数据'功能\n"
              "操作后应用将会自动退出, 请重新打开应用以应用更改\n"
              "是否继续?");
          if (confirm != null && confirm) {
            await exportCacheRoot(true);
          }
        },
        child: Icon(CupertinoIcons.folder, color: iconColor),
      ),
    ),
  );
  children.add(
    CupertinoFormRow(
      prefix: Text(
        '使用数据文件夹',
        style: TextStyle(color: textColor).useSystemChineseFont(),
      ),
      child: CupertinoButton(
        onPressed: () async {
          var confirm = await showConfirmationDialog(
              context,
              "注意!\n"
              "使用数据将会直接使用指定文件夹下的数据, 请确保指定下有正确的数据\n"
              "这将会导致当前使用的文件夹下的数据完全丢失!!!\n"
              "如果你想迁移数据, 请使用'迁移数据'功能\n"
              "操作后应用将会自动退出, 请重新打开应用以应用更改\n"
              "是否继续?");
          if (confirm != null && confirm) {
            await exportCacheRoot(false);
          }
        },
        child: Icon(CupertinoIcons.folder, color: iconColor),
      ),
    ),
  );
  return CupertinoFormSection.insetGrouped(
    header:
        Text('数据设定', style: TextStyle(color: textColor).useSystemChineseFont()),
    children: children,
  );
}

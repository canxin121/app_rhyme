import 'dart:io';

import 'package:app_rhyme/dialogs/input_extern_api_link_dialog.dart';
import 'package:app_rhyme/dialogs/quality_select_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/extern_api.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/extern_api.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  MorePageState createState() => MorePageState();
}

class MorePageState extends State<MorePage> with WidgetsBindingObserver {
  void _updateExternApiState() {
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

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: ListView(
        children: [
          CupertinoNavigationBar(
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
                  ),
                ),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          CupertinoFormSection.insetGrouped(
            header: Text('应用信息', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                  prefix: SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: imageCacheHelper(""),
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
                          ),
                        ),
                      ))),
              CupertinoFormRow(
                  prefix: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        '版本号',
                        style: TextStyle(color: textColor),
                      )),
                  child: Container(
                      padding: const EdgeInsets.only(right: 10),
                      alignment: Alignment.centerRight,
                      height: 40,
                      child: Text(
                        globalPackageInfo.version,
                        style: TextStyle(color: textColor),
                      ))),
              CupertinoFormRow(
                prefix: Text(
                  '检查更新',
                  style: TextStyle(color: textColor),
                ),
                child: CupertinoButton(
                  onPressed: () async {
                    await checkVersionUpdate(context);
                  },
                  child: Icon(CupertinoIcons.cloud, color: iconColor),
                ),
              ),
              CupertinoFormRow(
                prefix: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      '自动检查更新',
                      style: TextStyle(color: textColor),
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
                  style: TextStyle(color: textColor),
                ),
                child: CupertinoButton(
                  onPressed: openProjectLink,
                  child: Text(
                    'github.com/canxin121/app_rhyme',
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text("音频设置", style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                  prefix: Text("清空待播清单", style: TextStyle(color: textColor)),
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
          CupertinoFormSection.insetGrouped(
            header: Text('储存设置', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                  prefix: Text("清除冗余歌曲数据", style: TextStyle(color: textColor)),
                  child: CupertinoButton(
                      onPressed: () async {
                        try {
                          await SqlFactoryW.cleanUnusedMusicData();
                          toastification.show(
                              autoCloseDuration: const Duration(seconds: 2),
                              type: ToastificationType.success,
                              title: Text("储存清理",
                                  style: TextStyle(color: textColor)),
                              description: Text("清理无用歌曲数据成功",
                                  style: TextStyle(color: textColor)));
                        } catch (e) {
                          toastification.show(
                              autoCloseDuration: const Duration(seconds: 2),
                              type: ToastificationType.error,
                              title: Text("储存清理",
                                  style: TextStyle(color: textColor)),
                              description: Text("清理失败: ${e.toString()}",
                                  style: TextStyle(color: textColor)));
                        }
                      },
                      child: const Icon(
                        CupertinoIcons.bin_xmark,
                        color: CupertinoColors.systemRed,
                      ))),
            ],
          ),
          CupertinoFormSection.insetGrouped(
            header: Text('其他', style: TextStyle(color: textColor)),
            children: [
              CupertinoFormRow(
                  prefix: Text("运行日志", style: TextStyle(color: textColor)),
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
                style: TextStyle(color: textColor),
              )),
          child: Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              height: 50,
              child: const Text(
                "正常",
                style: TextStyle(color: CupertinoColors.activeGreen),
              ))));
    } else {
      children.add(CupertinoFormRow(
          prefix: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                '音源状态',
                style: TextStyle(color: textColor),
              )),
          child: Container(
              padding: const EdgeInsets.only(right: 10),
              alignment: Alignment.centerRight,
              height: 50,
              child: Text(
                "未导入",
                style: TextStyle(color: activeIconRed),
              ))));
    }
    if (hasExternApi) {
      if (isOnlineLink) {
        children.add(CupertinoFormRow(
            prefix: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '音源链接',
                  style: TextStyle(color: textColor),
                )),
            child: CupertinoButton(
              child: Text(
                globalConfig.externApi!.url!,
                style: TextStyle(color: textColor),
              ),
              onPressed: () async {
                try {
                  await Clipboard.setData(
                      ClipboardData(text: globalConfig.externApi!.url!));
                  toastification.show(
                      autoCloseDuration: const Duration(seconds: 2),
                      type: ToastificationType.success,
                      title: Text("音源链接", style: TextStyle(color: textColor)),
                      description:
                          Text("已复制至剪切板", style: TextStyle(color: textColor)));
                } catch (e) {
                  toastification.show(
                      autoCloseDuration: const Duration(seconds: 2),
                      type: ToastificationType.error,
                      title: Text("音源链接", style: TextStyle(color: textColor)),
                      description: Text("复制链接失败:${e.toString()}",
                          style: TextStyle(color: textColor)));
                }
              },
            )));
        children.add(
          CupertinoFormRow(
            prefix: Text('检查更新', style: TextStyle(color: textColor)),
            child: CupertinoButton(
              onPressed: () async {
                await checkExternApiUpdate(context);
                _updateExternApiState();
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
                style: TextStyle(color: textColor),
              )),
          child: CupertinoSwitch(
              value: globalConfig.externApiAutoUpdate,
              onChanged: (value) {
                if (value != globalConfig.externApiAutoUpdate) {
                  globalConfig.externApiAutoUpdate = value;
                  globalConfig.save();
                  _updateExternApiState();
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
                style: TextStyle(color: textColor),
              )),
          child: CupertinoButton(
              onPressed: () {
                globalConfig.externApi = null;
                globalConfig.save();
                globalExternApiEvaler = null;
                _updateExternApiState();
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
                style: TextStyle(color: textColor),
              )),
          child: ImportExternApiMenu(
              builder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  child:
                      Icon(CupertinoIcons.music_note_2, color: iconColor)))));
    }
    return CupertinoFormSection.insetGrouped(
        header: Text("自定义音源", style: TextStyle(color: textColor)),
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
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null) {
              var path = await cacheFile(
                  file: result.files.single.path!,
                  cachePath: "",
                  filename: "extern_api_cache");
              try {
                var externApi = await ExternApi.fromPath(path: path);
                globalConfig.externApi = externApi;
                globalConfig.save();
                globalExternApiEvaler = ExternApiEvaler(path);
                if (context.mounted) {
                  context
                      .findAncestorStateOfType<MorePageState>()
                      ?._updateExternApiState();
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
          onTap: () async {
            var link = await showInputExternApiLinkDialog(context);
            if (link != null) {
              var externApi = await ExternApi.fromUrl(url: link);
              globalConfig.externApi = externApi;
              globalConfig.save();
              globalExternApiEvaler =
                  ExternApiEvaler(globalConfig.externApi!.localPath);
              if (context.mounted) {
                context
                    .findAncestorStateOfType<MorePageState>()
                    ?._updateExternApiState();
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
        prefix: Text("Wifi下音质选择", style: TextStyle(color: textColor)),
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
        prefix: Text("数据网络下音质选择", style: TextStyle(color: textColor)),
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
                style: TextStyle(color: textColor)))));
  } else {
    children.add(CupertinoFormRow(
        prefix: Text("音质选择", style: TextStyle(color: textColor)),
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
  }
  return CupertinoFormSection.insetGrouped(
    header: Text('音质选择', style: TextStyle(color: textColor)),
    children: children,
  );
}

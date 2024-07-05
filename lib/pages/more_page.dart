import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
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

class MorePageState extends State<MorePage> {
  void _updateExternApiState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(onGenerateRoute: (RouteSettings settings) {
      return CupertinoPageRoute(
          builder: (context) => CupertinoPageScaffold(
                  child: Container(
                color: CupertinoColors.systemGroupedBackground,
                child: SafeArea(
                  child: ListView(
                    children: [
                      const CupertinoNavigationBar(
                        leading: Padding(
                          padding: EdgeInsets.only(left: 0.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '设置',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 20)),
                      CupertinoFormSection.insetGrouped(
                        header: const Text('应用信息'),
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
                                    child: const Text(
                                      'AppRhyme',
                                      style: TextStyle(
                                        color: CupertinoColors.black,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ))),
                          CupertinoFormRow(
                              prefix: const Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    '版本号',
                                  )),
                              child: Container(
                                  padding: const EdgeInsets.only(right: 10),
                                  alignment: Alignment.centerRight,
                                  height: 40,
                                  child: Text(
                                    globalPackageInfo.version,
                                  ))),
                          CupertinoFormRow(
                            prefix: const Text(
                              '检查更新',
                            ),
                            child: CupertinoButton(
                              onPressed: () async {
                                await checkVersionUpdate(context);
                              },
                              child: const Icon(CupertinoIcons.cloud),
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: Text(
                                  '自动检查更新',
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
                          const CupertinoFormRow(
                            prefix: Text(
                              '项目链接',
                            ),
                            child: CupertinoButton(
                              onPressed: openProjectLink,
                              child: Text(
                                'github.com/canxin121/app_rhyme',
                              ),
                            ),
                          ),
                        ],
                      ),
                      CupertinoFormSection.insetGrouped(
                        header: const Text("音频设置"),
                        children: [
                          CupertinoFormRow(
                              prefix: const Text("清空待播清单"),
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
                      _buildExternApiSection(),
                      _buildQualitySelectSection(context, () {
                        setState(() {});
                      }),
                      CupertinoFormSection.insetGrouped(
                        header: const Text('储存设置'),
                        children: [
                          CupertinoFormRow(
                              prefix: Text("清除冗余歌曲数据",
                                  style:
                                      const TextStyle().useSystemChineseFont()),
                              child: CupertinoButton(
                                  onPressed: () async {
                                    try {
                                      await SqlFactoryW.cleanUnusedMusicData();
                                      toastification.show(
                                          autoCloseDuration:
                                              const Duration(seconds: 2),
                                          type: ToastificationType.success,
                                          title: Text("储存清理",
                                              style: const TextStyle()
                                                  .useSystemChineseFont()),
                                          description: Text("清理无用歌曲数据成功",
                                              style: const TextStyle()
                                                  .useSystemChineseFont()));
                                    } catch (e) {
                                      toastification.show(
                                          autoCloseDuration:
                                              const Duration(seconds: 2),
                                          type: ToastificationType.error,
                                          title: Text("储存清理",
                                              style: const TextStyle()
                                                  .useSystemChineseFont()),
                                          description: Text(
                                              "清理失败: ${e.toString()}",
                                              style: const TextStyle()
                                                  .useSystemChineseFont()));
                                    }
                                  },
                                  child: const Icon(
                                    CupertinoIcons.bin_xmark,
                                    color: CupertinoColors.systemRed,
                                  ))),
                        ],
                      ),
                      CupertinoFormSection.insetGrouped(
                        header: const Text('其他'),
                        children: [
                          CupertinoFormRow(
                              prefix: Text("运行日志",
                                  style:
                                      const TextStyle().useSystemChineseFont()),
                              child: CupertinoButton(
                                  child: const Icon(
                                    CupertinoIcons.book,
                                    color: CupertinoColors.activeGreen,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(CupertinoPageRoute(
                                      builder: (context) =>
                                          TalkerScreen(talker: globalTalker),
                                    ));
                                  })),
                        ],
                      ),
                    ],
                  ),
                ),
              )));
    });
  }

  CupertinoFormSection _buildExternApiSection() {
    bool hasExternApi = globalConfig.externApi != null;
    bool isOnlineLink = globalConfig.externApi?.url != null;
    List<Widget> children = [];
    if (hasExternApi) {
      children.add(CupertinoFormRow(
          prefix: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '音源状态',
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
          prefix: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '音源状态',
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
            prefix: const Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  '音源链接',
                )),
            child: CupertinoButton(
              child: Text(
                globalConfig.externApi!.url!,
              ),
              onPressed: () async {
                try {
                  await Clipboard.setData(
                      ClipboardData(text: globalConfig.externApi!.url!));
                  toastification.show(
                      autoCloseDuration: const Duration(seconds: 2),
                      type: ToastificationType.success,
                      title: Text("音源链接",
                          style: const TextStyle().useSystemChineseFont()),
                      description: Text("已复制至剪切板",
                          style: const TextStyle().useSystemChineseFont()));
                } catch (e) {
                  toastification.show(
                      autoCloseDuration: const Duration(seconds: 2),
                      type: ToastificationType.error,
                      title: Text("音源链接",
                          style: const TextStyle().useSystemChineseFont()),
                      description: Text("复制链接失败:${e.toString()}",
                          style: const TextStyle().useSystemChineseFont()));
                }
              },
            )));
        children.add(
          CupertinoFormRow(
            prefix: const Text(
              '检查更新',
            ),
            child: CupertinoButton(
              onPressed: () async {
                await checkExternApiUpdate(context);
                _updateExternApiState();
              },
              child: const Icon(CupertinoIcons.cloud),
            ),
          ),
        );
        children.add(CupertinoFormRow(
          prefix: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '自动检查更新',
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
          prefix: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '删除音源',
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
          prefix: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                '导入音源',
              )),
          child: ImportExternApiMenu(
              builder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  child: const Icon(CupertinoIcons.music_note_2)))));
    }
    return CupertinoFormSection.insetGrouped(
        header: Text("自定义音源", style: const TextStyle().useSystemChineseFont()),
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
    BuildContext context, void Function() refresh) {
  List<Widget> children = [];

  if (Platform.isAndroid || Platform.isIOS) {
    children.add(CupertinoFormRow(
        prefix:
            Text("Wifi下音质选择", style: const TextStyle().useSystemChineseFont()),
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
            child: Text(globalConfig.wifiAutoQuality))));
    children.add(CupertinoFormRow(
        prefix:
            Text("数据网络下音质选择", style: const TextStyle().useSystemChineseFont()),
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
            child: Text(globalConfig.mobileAutoQuality))));
  } else {
    children.add(CupertinoFormRow(
        prefix: Text("音质选择", style: const TextStyle().useSystemChineseFont()),
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
            child: Text(globalConfig.wifiAutoQuality))));
  }
  return CupertinoFormSection.insetGrouped(
    header: const Text('音质选择'),
    children: children,
  );
}

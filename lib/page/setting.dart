import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/config.dart';
import 'package:app_rhyme/types/extern_api.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  void _pickMusicSource() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      var path = await cacheFile(
          file: result.files.single.path!, cachePath: apiCachePath);
      setState(() {
        try {
          globalExternApi = ExternApi(path);
          globalConfig = Config(
              externApiPath: path, userAgreement: globalConfig.userAgreement);
          globalConfig.save();
        } catch (e) {
          talker.error("[Setting Page] 设置第三方音乐源失败:$e");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Container(
      color: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: ListView(
          children: [
            const CupertinoNavigationBar(
              // 界面最上面的 编辑选项
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
              children: [
                CupertinoFormRow(
                  prefix: const Text(
                    '第三方音乐源',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  child: CupertinoSwitch(
                    value: globalExternApi != null,
                    onChanged: (bool value) {
                      if (!value) {
                        globalConfig =
                            Config(userAgreement: globalConfig.userAgreement);
                        globalConfig.save();
                        setState(() {
                          globalExternApi = null;
                        });
                      }
                    },
                    activeColor: CupertinoColors.activeGreen,
                    trackColor: CupertinoColors.destructiveRed,
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text(
                    '状态',
                    style: TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  child: globalExternApi != null
                      ? Container(
                          padding: const EdgeInsets.all(5),
                          child: const Icon(
                            CupertinoIcons.checkmark_alt_circle_fill,
                            color: CupertinoColors.activeGreen,
                            size: 30,
                          ))
                      : CupertinoButton(
                          onPressed: _pickMusicSource,
                          child: const Text(
                            '请选择第三方音乐源文件',
                            style: TextStyle(
                              color: CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                ),
                CupertinoFormRow(
                    prefix: const Text("运行日志"),
                    child: CupertinoButton(
                        child: const Icon(
                          CupertinoIcons.book,
                          color: CupertinoColors.activeGreen,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                            builder: (context) => TalkerScreen(talker: talker),
                          ));
                        }))
              ],
            ),
          ],
        ),
      ),
    ));
  }
}

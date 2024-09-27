import 'package:app_rhyme/utils/pick_file.dart';
import 'package:flutter/cupertino.dart';

Future<String?> showDatabaseUrlDialog(BuildContext context) async {
  TextEditingController urlController = TextEditingController();
  String? selectedUrl;

  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;
  final Color textColor =
      isDarkMode ? CupertinoColors.white : CupertinoColors.black;

  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          '输入新数据库链接',
          style: TextStyle(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(
              placeholder: '输入数据库链接',
              controller: urlController,
              keyboardType: TextInputType.url,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: () async {
                var newParentFolder = await pickDirectory();
                if (newParentFolder != null) {
                  String fullDbPath = "sqlite:///$newParentFolder/MusicData.db";
                  urlController.text = fullDbPath;
                }
              },
              child: Text(
                '选择目录生成sqilte链接',
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text(
              '取消',
              style: TextStyle(color: textColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              '确认URL',
              style: TextStyle(color: textColor),
            ),
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                Navigator.of(context).pop(urlController.text);
              }
            },
          ),
        ],
      );
    },
  ).then((value) {
    selectedUrl = value;
  });

  return selectedUrl;
}

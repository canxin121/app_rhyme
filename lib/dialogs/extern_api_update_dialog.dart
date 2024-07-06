import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<bool> showExternApiUpdateDialog(BuildContext context) async {
  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;

  return await showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          "自定义音源更新",
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ).useSystemChineseFont(),
        ),
        content: Column(
          children: [
            Text(
              '自定义音源有更新,是否更新?',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey4
                    : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('更新'),
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
          ),
          CupertinoDialogAction(
            child: const Text('关闭'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
}

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<bool?> showConfirmationDialog(BuildContext context, String body) async {
  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;

  return await showCupertinoModalPopup<bool>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        message: Text(
          body,
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ).useSystemChineseFont(),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, true); // Return true on confirmation
            },
            child: Text(
              '确认',
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, false); // Return false on cancellation
            },
            child: Text(
              '取消',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
          )
        ],
      );
    },
  );
}

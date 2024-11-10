import 'package:app_rhyme/src/rust/api/types/config.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<QualityOption?> showQualityOptionDialog(BuildContext context) async {
  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;

  return await showCupertinoModalPopup<QualityOption>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: Text(
          '选择音质选项',
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ).useSystemChineseFont(),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.low);
            },
            child: Text(
              qualityOptionToString(QualityOption.low),
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.medium);
            },
            child: Text(
              qualityOptionToString(QualityOption.medium),
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.high);
            },
            child: Text(
              qualityOptionToString(QualityOption.high),
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.highest);
            },
            child: Text(
              qualityOptionToString(QualityOption.highest),
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context, null); // null when cancelled
          },
          child: Text(
            '取消',
            style: TextStyle(
              color: isDarkMode
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.activeBlue,
            ).useSystemChineseFont(),
          ),
        ),
      );
    },
  );
}

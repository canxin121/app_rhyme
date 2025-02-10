import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<String?> showInputPlaylistShareLinkDialog(BuildContext context) async {
  TextEditingController textEditingController = TextEditingController();
  String? result;

  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;

  result = await showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          '打开歌单',
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ).useSystemChineseFont(),
        ),
        content: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              '输入分享链接',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey4
                    : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
            const SizedBox(height: 10),
            Text(
              '示例:',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey4
                    : CupertinoColors.black,
              ).useSystemChineseFont(),
            ),
            Text(
              '1. https://y.music.163.com/m/playlist?app_version=8.9.20&id=123456789\n'
              '2. https://m.kuwo.cn/newh5app/playlist_detail/123456789',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.systemGrey,
              ).useSystemChineseFont(),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              controller: textEditingController,
              placeholder: '歌单分享链接',
              placeholderStyle: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ],
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: Text(
              '取消',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              '确定',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
            onPressed: () {
              Navigator.of(context).pop(textEditingController.text);
            },
          ),
        ],
      );
    },
  );

  return result;
}

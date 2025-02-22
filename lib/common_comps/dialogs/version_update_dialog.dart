import 'package:app_rhyme/src/rust/api/types/version.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void showVersionUpdateDialog(BuildContext context, Release release) {
  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;

  showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          "版本更新",
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ).useSystemChineseFont(),
        ),
        content: Column(
          children: [
            Text(
              '作者: ${release.author.login}',
              style: const TextStyle().useSystemChineseFont(),
            ),
            Text('名称: ${release.name}',
                style: const TextStyle().useSystemChineseFont()),
            Text('版本: ${release.tagName}',
                style: const TextStyle().useSystemChineseFont()),
            Text('时间: ${release.createdAt}',
                style: const TextStyle().useSystemChineseFont()),
            Text('内容: ${release.body}',
                style: const TextStyle().useSystemChineseFont()),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              '下载',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              if (await canLaunchUrl(Uri.parse(release.htmlUrl))) {
                await launchUrl(Uri.parse(release.htmlUrl));
              } else {
                await Clipboard.setData(ClipboardData(text: release.htmlUrl));
                LogToast.error("打开下载页面失败", "已复制链接到剪切板，请在浏览器中打开并下载",
                    "[showVersionUpdateDialog] Failed to launch github url, copied to clipboard");
              }
            },
          ),
          CupertinoDialogAction(
            child: Text(
              '关闭',
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
        ],
      );
    },
  );
}

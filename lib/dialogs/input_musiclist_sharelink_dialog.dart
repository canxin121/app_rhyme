import 'package:flutter/cupertino.dart';

Future<String?> showInputPlaylistShareLinkDialog(BuildContext context) async {
  TextEditingController textEditingController = TextEditingController();
  String? result;

  result = await showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('打开歌单'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            const Text('输入分享链接'),
            const SizedBox(height: 10),
            const Text('示例:'),
            const Text(
              '1. https://y.music.163.com/m/playlist?app_version=8.9.20&id=123456789\n'
              '2. https://m.kuwo.cn/newh5app/playlist_detail/123456789',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
            CupertinoTextField(
              controller: textEditingController,
              placeholder: '歌单分享链接',
            ),
          ],
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('确定'),
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

import 'package:flutter/cupertino.dart';

Future<String?> showInputExternApiLinkDialog(BuildContext context) async {
  TextEditingController textEditingController = TextEditingController();
  String? result;

  result = await showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: const Text('导入音源'),
        content: Column(
          children: [
            const SizedBox(height: 10),
            const Text('输入自定义音源链接'),
            const SizedBox(height: 10),
            const Text('示例:'),
            const Text(
              '1. https://github.com/user/project/releases/download/release/extern_api.evc\n'
              '2. https://github.com/user/project/releases/download/release/extern_api.txt',
              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
            ),
            CupertinoTextField(
              controller: textEditingController,
              placeholder: '第三方音源链接',
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

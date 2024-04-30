import 'package:flutter/cupertino.dart';

Future<void> showCupertinoPopupWithActions({
  required BuildContext context,
  required List<String> options,
  required List<Future<void> Function()> actionCallbacks,
}) async {
  assert(options.length == actionCallbacks.length, '选项和回调函数的数量必须匹配。');

  return await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('选择一个选项'),
        actions: List.generate(options.length, (int index) {
          return CupertinoActionSheetAction(
            child: Text(
              options[index],
              style: const TextStyle(color: CupertinoColors.black), // 设置文本颜色为黑色
            ),
            onPressed: () async {
              if (context.mounted) {
                Navigator.pop(context);
              }
              await actionCallbacks[index]();
            },
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '取消',
            style: TextStyle(color: CupertinoColors.black), // 设置文本颜色为黑色
          ),
        ),
      );
    },
  );
}

Future<void> showCupertinoPopupWithSameAction({
  required BuildContext context,
  required List<String> options,
  required Future<void> Function(int index) actionCallbacks,
}) async {
  return await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('选择一个选项'),
        actions: List.generate(options.length, (int index) {
          return CupertinoActionSheetAction(
            child: Text(
              options[index],
              style: const TextStyle(color: CupertinoColors.black), // 设置文本颜色为黑色
            ),
            onPressed: () async {
              if (context.mounted) {
                Navigator.pop(context);
              }
              await actionCallbacks(index);
            },
          );
        }),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '取消',
            style: TextStyle(color: CupertinoColors.black), // 设置文本颜色为黑色
          ),
        ),
      );
    },
  );
}

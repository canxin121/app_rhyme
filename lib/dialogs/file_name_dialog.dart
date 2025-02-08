import 'package:flutter/cupertino.dart';

Future<String?> showFileNameDialog(BuildContext context, String suffix,
    {String defaultFileName = ""}) async {
  TextEditingController controller =
      TextEditingController(text: defaultFileName);

  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;
  final Color textColor =
      isDarkMode ? CupertinoColors.white : CupertinoColors.black;

  return await showCupertinoDialog<String>(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: const Text("输入文件名"),
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: "请输入文件名",
                  placeholderStyle: TextStyle(
                      color: textColor.withAlpha((255.0 * 0.5).round())),
                  style: TextStyle(color: textColor),
                  autofocus: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(suffix,
                    style: const TextStyle(color: CupertinoColors.systemGrey)),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("确定"),
            onPressed: () {
              String fileName = controller.text;
              if (fileName.isEmpty) {
                return;
              }
              if (!fileName.endsWith(suffix)) {
                fileName += ".";
                fileName += suffix;
              }
              Navigator.of(context).pop(fileName);
            },
          ),
        ],
      );
    },
  );
}

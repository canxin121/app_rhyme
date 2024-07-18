import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<void> showWaitDialog(BuildContext context, String body) async {
  showCupertinoModalPopup(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CupertinoActivityIndicator(radius: 15.0),
              const SizedBox(height: 10),
              Text(body, style: const TextStyle().useSystemChineseFont()),
            ],
          ),
        ),
      );
    },
  );
}

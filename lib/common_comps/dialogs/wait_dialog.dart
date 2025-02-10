import 'package:app_rhyme/desktop/home.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<void> showWaitDialog(
    BuildContext context, bool isDesktop, String body) async {
  showCupertinoModalPopup(
    context: isDesktop ? globalDesktopNavigatorKey.currentContext! : context,
    barrierDismissible: false,
    useRootNavigator: false,
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

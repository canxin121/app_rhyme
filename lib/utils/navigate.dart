import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/home.dart';
import 'package:flutter/cupertino.dart';

void navigate(
    BuildContext context, Widget page, bool isDesktop, String navItemKey,
    {bool replaceDestkop = false}) async {
  if (isDesktop) {
    globalDesktopNavigatorToPage(page, replace: replaceDestkop);
    globalSetNavItemSelected(navItemKey);
  } else {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (BuildContext context) => page,
      ),
    );
  }
}

void popPage(BuildContext context, bool isDesktop) {
  if (isDesktop) {
    if (globalDesktopNavigatorKey.currentContext == null) return;
    var navigator = Navigator.of(globalDesktopNavigatorKey.currentContext!);
    if (navigator.canPop()) {
      navigator.pop();
    }
  } else {
    Navigator.of(context).pop();
  }
}

import 'package:flutter/cupertino.dart';

Color activeIconRed = const Color.fromARGB(255, 250, 35, 59);

Color getDividerColor(bool isDarkMode) {
  return isDarkMode
      ? const Color.fromARGB(255, 58, 58, 58)
      : const Color.fromARGB(255, 236, 236, 236);
}

Color getNavigatorBarColor(bool isDarkMode) {
  return isDarkMode
      ? const Color.fromARGB(255, 43, 43, 43)
      : const Color.fromARGB(255, 247, 247, 247);
}

Color getPrimaryBackgroundColor(bool isDarkMode) {
  return isDarkMode
      ? const Color.fromARGB(255, 40, 40, 40)
      : const Color.fromARGB(255, 249, 249, 249);
}

Color getSettingPageBackgroundColor(bool isDarkMode) {
  return isDarkMode
      ? CupertinoColors.black
      : CupertinoColors.systemGroupedBackground;
}

import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Widget buildButton(BuildContext context,
    {required IconData icon,
    required String label,
    required VoidCallback onPressed}) {
  final Brightness brightness = MediaQuery.of(context).platformBrightness;
  final bool isDarkMode = brightness == Brightness.dark;

  final Color buttonBackgroundColor = isDarkMode
      ? const Color.fromARGB(255, 28, 28, 30)
      : const Color.fromARGB(255, 238, 238, 239);
  double screenWidth = MediaQuery.of(context).size.width;

  return CupertinoButton(
    onPressed: onPressed,
    padding: EdgeInsets.zero,
    child: Container(
      width: screenWidth * 0.4,
      height: 50,
      decoration: BoxDecoration(
        color: buttonBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: activeIconRed,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: activeIconRed,
              fontWeight: FontWeight.bold,
            ).useSystemChineseFont(),
          ),
        ],
      ),
    ),
  );
}

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final String label;
  final VoidCallback? onClick;

  const Badge({
    super.key,
    required this.label,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;

    final bool isDarkMode = brightness == Brightness.dark;
    Color backgroundColor =
        isDarkMode ? Colors.white : const Color.fromRGBO(0, 0, 0, 0.56);
    Color textColor = isDarkMode ? Colors.black : Colors.white;

    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ).useSystemChineseFont(),
        ),
      ),
    );
  }
}

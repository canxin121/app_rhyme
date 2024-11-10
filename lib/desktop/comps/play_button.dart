import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Widget buildMobileRedButton(BuildContext context,
    {required IconData icon,
    required String label,
    required VoidCallback onPressed}) {
  return CupertinoButton(
    onPressed: onPressed,
    padding: EdgeInsets.zero,
    child: Container(
      width: 120,
      height: 33,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 250, 45, 72),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: CupertinoColors.white,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.white,
            ).useSystemChineseFont(),
          ),
        ],
      ),
    ),
  );
}

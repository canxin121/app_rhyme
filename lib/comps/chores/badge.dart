import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback? onClick; // 新增onClick属性
  const Badge(
      {super.key, required this.label, this.isDark = false, this.onClick});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor =
        isDark ? Colors.white : const Color.fromRGBO(0, 0, 0, 0.56);
    Color textColor = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      // 使用GestureDetector包装Container以添加点击事件
      onTap: onClick, // 将onClick属性绑定到GestureDetector的onTap回调
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
          ),
        ),
      ),
    );
  }
}

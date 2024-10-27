import 'package:app_rhyme/utils/multi_select.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 全部选中
PullDownMenuItem selectAllPullDownItemPullDownItem(
    DragSelectGridViewController controller, int total) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => selectAll(controller, total),
    title: '全部选中',
    icon: CupertinoIcons.checkmark_seal_fill,
  );
}

/// 取消选中
PullDownMenuItem clearSelectionPullDownItem(
    VoidCallback setState, DragSelectGridViewController controller) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      controller.clear();
      setState();
    },
    title: '取消选中',
    icon: CupertinoIcons.xmark,
  );
}

/// 反转选中
PullDownMenuItem reverseSelectionPullDownItem(
    DragSelectGridViewController controller, int total) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => reverseSelect(controller, total),
    title: '反转选中',
    icon: CupertinoIcons.arrow_swap,
  );
}

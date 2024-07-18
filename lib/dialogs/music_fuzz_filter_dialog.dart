import 'dart:async';

import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

Future<MusicFuzzFilter?> showMusicFuzzFilterDialog(BuildContext context,
    {MusicFuzzFilter? defaultFilter, bool readonly = false}) async {
  return showCupertinoDialog<MusicFuzzFilter>(
    context: context,
    builder: (BuildContext context) =>
        MusicFuzzFilterDialog(defaultFilter: defaultFilter, readonly: readonly),
  );
}

class MusicFuzzFilterDialog extends StatefulWidget {
  final MusicFuzzFilter? defaultFilter;
  final bool readonly;

  const MusicFuzzFilterDialog(
      {super.key, this.defaultFilter, this.readonly = false});

  @override
  MusicFuzzFilterDialogState createState() => MusicFuzzFilterDialogState();
}

class MusicFuzzFilterDialogState extends State<MusicFuzzFilterDialog> {
  late TextEditingController nameController;
  late TextEditingController artistController;
  late TextEditingController albumController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.defaultFilter?.name ?? '');
    artistController = TextEditingController(
        text: widget.defaultFilter?.artist.join(', ') ?? '');
    albumController =
        TextEditingController(text: widget.defaultFilter?.album ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    String title;
    if (widget.readonly) {
      title = '音乐筛选';
    } else if (widget.defaultFilter != null) {
      title = "编辑筛选条件";
    } else {
      title = '创建筛选条件';
    }

    return CupertinoAlertDialog(
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ).useSystemChineseFont(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: nameController,
              placeholder: '音乐名字',
              readOnly: widget.readonly,
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
              placeholderStyle: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: artistController,
              placeholder: '艺术家(多个用逗号分隔)',
              readOnly: widget.readonly,
              maxLines: widget.readonly ? null : 1,
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
              placeholderStyle: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: albumController,
              placeholder: '专辑',
              readOnly: widget.readonly,
              maxLines: widget.readonly ? null : 1,
              style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
              placeholderStyle: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? CupertinoColors.darkBackgroundGray
                    : CupertinoColors.white,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
        if (!widget.readonly)
          CupertinoDialogAction(
            child: Text(
              '取消',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        if (!widget.readonly)
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (artistController.text.isNotEmpty) {
                Navigator.of(context).pop(MusicFuzzFilter(
                  name: nameController.text,
                  artist: artistController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  album: albumController.text,
                ));
              }
            },
            child: Text(
              '完成',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
          ),
        if (widget.readonly)
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '关闭',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
          ),
      ],
    );
  }
}

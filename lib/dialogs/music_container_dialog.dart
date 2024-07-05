import 'dart:async';
import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

Future<MusicInfo?> showMusicInfoDialog(BuildContext context,
    {MusicInfo? defaultMusicInfo, bool readonly = false}) async {
  return showCupertinoDialog<MusicInfo>(
    context: context,
    builder: (BuildContext context) =>
        MusicInfoDialog(defaultMusicInfo: defaultMusicInfo, readonly: readonly),
  );
}

class MusicInfoDialog extends StatefulWidget {
  final MusicInfo? defaultMusicInfo;
  final bool readonly;

  const MusicInfoDialog(
      {super.key, this.defaultMusicInfo, this.readonly = false});

  @override
  MusicInfoDialogState createState() => MusicInfoDialogState();
}

class MusicInfoDialogState extends State<MusicInfoDialog> {
  late TextEditingController nameController;
  late TextEditingController artistController;
  late TextEditingController albumController;
  late TextEditingController durationController;
  late TextEditingController lyricController;
  late ExtendedImage image;
  late String artPicPath;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.defaultMusicInfo?.name ?? '');
    artistController = TextEditingController(
        text: widget.defaultMusicInfo?.artist.join(', ') ?? '');
    albumController =
        TextEditingController(text: widget.defaultMusicInfo?.album ?? '');
    durationController = TextEditingController(
        text: widget.defaultMusicInfo?.duration?.toString() ?? '');
    lyricController =
        TextEditingController(text: widget.defaultMusicInfo?.lyric ?? '');
    if (widget.defaultMusicInfo != null) {
      image = imageCacheHelper(widget.defaultMusicInfo!.artPic);
    } else {
      image = ExtendedImage.asset(defaultArtPicPath);
    }
    artPicPath = widget.defaultMusicInfo?.artPic ?? '';
  }

  @override
  Widget build(BuildContext context) {
    String title;
    if (widget.readonly) {
      title = '音乐详情';
    } else if (widget.defaultMusicInfo != null) {
      title = "编辑音乐";
    } else {
      title = '创建音乐';
    }
    return CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: widget.readonly
                ? null
                : () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? imageFile =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (imageFile != null) {
                      setState(() {
                        artPicPath = imageFile.path;
                        image = ExtendedImage.file(File(artPicPath));
                        cacheFile(
                          file: imageFile.path,
                          cachePath: picCacheRoot,
                        );
                      });
                    }
                  },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemGrey,
                  width: 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: image,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: nameController,
              placeholder: '音乐名字',
              readOnly: widget.readonly,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: artistController,
              placeholder: '艺术家(多个用逗号分隔)',
              readOnly: widget.readonly,
              maxLines: widget.readonly ? null : 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: albumController,
              placeholder: '专辑',
              readOnly: widget.readonly,
              maxLines: widget.readonly ? null : 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: durationController,
              placeholder: '时长 (秒)',
              readOnly: widget.readonly,
              keyboardType: TextInputType.number,
              maxLines: widget.readonly ? null : 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: lyricController,
              placeholder: '歌词',
              readOnly: widget.readonly,
              maxLines: null,
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
        if (!widget.readonly)
          CupertinoDialogAction(
            child: Text(
              '取消',
              style: const TextStyle(color: CupertinoColors.black)
                  .useSystemChineseFont(),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        if (!widget.readonly)
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.of(context).pop(MusicInfo(
                  name: nameController.text,
                  artist: artistController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  duration: int.tryParse(durationController.text),
                  album: albumController.text,
                  artPic: artPicPath,
                  lyric: lyricController.text,
                  id: 0,
                  source: '',
                  qualities: [],
                ));
              }
            },
            child: Text(
              '完成',
              style: const TextStyle(color: CupertinoColors.black)
                  .useSystemChineseFont(),
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
              style: const TextStyle(color: CupertinoColors.black)
                  .useSystemChineseFont(),
            ),
          ),
      ],
    );
  }
}

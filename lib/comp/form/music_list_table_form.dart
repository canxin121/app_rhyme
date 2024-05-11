import 'dart:io';

import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

Future<MusicList?> createMusicListTableForm(BuildContext context,
    [MusicList? defaultMusicList]) async {
  return showCupertinoDialog<MusicList>(
    context: context,
    builder: (BuildContext context) =>
        MusicListDialog(defaultMusicList: defaultMusicList),
  );
}

class MusicListDialog extends StatefulWidget {
  final MusicList? defaultMusicList;

  const MusicListDialog({super.key, this.defaultMusicList});

  @override
  MusicListDialogState createState() => MusicListDialogState();
}

class MusicListDialogState extends State<MusicListDialog> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late Image image;
  late String artPicPath;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.defaultMusicList?.name ?? '');
    descController =
        TextEditingController(text: widget.defaultMusicList?.desc ?? '');
    image = defaultArtPic;
    if (widget.defaultMusicList != null) {
      useCacheImage(widget.defaultMusicList!.artPic).then((value) {
        setState(() {
          image = value;
        });
      });
    }
    artPicPath = widget.defaultMusicList?.artPic ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('创建歌单'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? imageFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (imageFile != null) {
                setState(() {
                  artPicPath = imageFile.path;
                  image = Image.file(File(artPicPath));
                  cacheFile(
                    file: imageFile.path,
                    cachePath: picCachePath,
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
              placeholder: '歌单名字',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: descController,
              placeholder: '介绍',
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
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
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              Navigator.of(context).pop(MusicList(
                name: nameController.text,
                artPic: artPicPath,
                desc: descController.text,
              ));
            }
          },
          child: Text(
            '完成',
            style: const TextStyle(color: CupertinoColors.black)
                .useSystemChineseFont(),
          ),
        ),
      ],
    );
  }
}

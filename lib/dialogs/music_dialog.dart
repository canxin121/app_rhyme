import 'dart:async';
import 'dart:io';

import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

Future<Music?> showMusicInfoDialog(BuildContext context,
    {Music? defaultMusicInfo, bool readonly = false}) async {
  return showCupertinoDialog<Music>(
    context: context,
    builder: (BuildContext context) =>
        MusicInfoDialog(music: defaultMusicInfo, readonly: readonly),
  );
}

class MusicInfoDialog extends StatefulWidget {
  final Music? music;
  final bool readonly;

  const MusicInfoDialog({super.key, this.music, this.readonly = false});

  @override
  MusicInfoDialogState createState() => MusicInfoDialogState();
}

class MusicInfoDialogState extends State<MusicInfoDialog> {
  late TextEditingController nameController;
  late TextEditingController albumController;
  late TextEditingController durationController;
  late ExtendedImage image;
  late String artPicPath;
  late List<Artist> artists;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.music?.name ?? '');
    albumController = TextEditingController(text: widget.music?.album ?? '');
    durationController =
        TextEditingController(text: widget.music?.duration?.toString() ?? '');
    if (widget.music != null) {
      image = imageWithCache(widget.music?.cover);
      artists = List.from(widget.music!.artists);
    }
    artPicPath = widget.music?.cover ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    String title;
    if (widget.readonly) {
      title = '音乐详情';
    } else if (widget.music != null) {
      title = "编辑音乐";
    } else {
      title = '创建音乐';
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
                        image = imageWithCache(artPicPath);
                        cacheFileFromUriWrapper(imageFile.path, picCacheFolder);
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
          // Section for "歌曲"
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '歌曲',
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.systemGrey2
                        : CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
                CupertinoTextField(
                  controller: nameController,
                  readOnly: widget.readonly,
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? CupertinoColors.darkBackgroundGray
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.readonly)
            ...artists.asMap().entries.map((entry) {
              int index = entry.key;
              Artist artist = entry.value;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '艺人',
                      style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.systemGrey2
                            : CupertinoColors.black,
                        fontSize: 14,
                      ),
                    ),
                    CupertinoTextField(
                      placeholder: '演唱者',
                      controller: TextEditingController(text: artist.name),
                      onChanged: (value) {
                        setState(() {
                          artists[index].name = value;
                        });
                      },
                      style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? CupertinoColors.darkBackgroundGray
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    )
                  ],
                ),
              );
            }),
          // Section for "专辑"
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '专辑',
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.systemGrey2
                        : CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
                CupertinoTextField(
                  controller: albumController,
                  readOnly: widget.readonly,
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? CupertinoColors.darkBackgroundGray
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ],
            ),
          ),
          // Section for "时长 (秒)"
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '时长 (秒)',
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.systemGrey2
                        : CupertinoColors.black,
                    fontSize: 14,
                  ),
                ),
                CupertinoTextField(
                  controller: durationController,
                  readOnly: widget.readonly,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? CupertinoColors.darkBackgroundGray
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ],
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
              if (nameController.text.isNotEmpty) {
                // Update the music object with the new values
                Navigator.of(context).pop(Music(
                  name: nameController.text,
                  duration: int.tryParse(durationController.text),
                  album: albumController.text,
                  cover: artPicPath,
                  qualities: [],
                  fromDb: widget.music!.fromDb,
                  server: widget.music!.server,
                  identity: widget.music!.identity,
                  artists: artists, // Use updated artists list
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

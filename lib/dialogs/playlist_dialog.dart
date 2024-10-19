import 'dart:async';

import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

Future<Playlist?> showPlaylistDialog(BuildContext context,
    {Playlist? defaultPlaylist, bool readonly = false}) async {
  return showCupertinoDialog<Playlist>(
    context: context,
    builder: (BuildContext context) =>
        PlaylistDialog(defaultMusicList: defaultPlaylist, readonly: readonly),
  );
}

class PlaylistDialog extends StatefulWidget {
  final Playlist? defaultMusicList;
  final bool readonly;

  const PlaylistDialog(
      {super.key, this.defaultMusicList, this.readonly = false});

  @override
  PlaylistDialogState createState() => PlaylistDialogState();
}

class PlaylistDialogState extends State<PlaylistDialog> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late ExtendedImage image;
  late String artPicPath;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.defaultMusicList?.name ?? '');
    descController =
        TextEditingController(text: widget.defaultMusicList?.summary ?? '');
    image = imageWithCache(widget.defaultMusicList?.cover);
    artPicPath = widget.defaultMusicList?.getCover(size: 250) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    String title;
    if (widget.readonly) {
      title = '歌单详情';
    } else if (widget.defaultMusicList != null) {
      title = "编辑歌单";
    } else {
      title = '创建歌单';
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        // image = ExtendedImage.file(File(artPicPath));
                        image =
                            imageWithCache(artPicPath, width: 100, height: 100);
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '歌单',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.black,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoTextField(
              controller: nameController,
              placeholder: '歌单',
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
          Text(
            '介绍',
            style: TextStyle(
              color: isDarkMode
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.black,
              fontSize: 14,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: CupertinoTextField(
              controller: descController,
              placeholder: '介绍',
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
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                if (widget.defaultMusicList != null) {
                  Navigator.of(context).pop(Playlist(
                    fromDb: widget.defaultMusicList!.fromDb,
                    typeField: widget.defaultMusicList!.typeField,
                    identity: widget.defaultMusicList!.identity,
                    name: nameController.text,
                    summary: descController.text,
                    cover: artPicPath,
                    subscription: widget.defaultMusicList!.subscription,
                    collectionId: widget.defaultMusicList!.collectionId,
                    order: widget.defaultMusicList!.order,
                    server: widget.defaultMusicList!.server,
                    creator: widget.defaultMusicList!.creator,
                    creatorId: widget.defaultMusicList!.creatorId,
                    musicNum: widget.defaultMusicList!.musicNum,
                    playTime: widget.defaultMusicList!.playTime,
                  ));
                } else {
                  Navigator.of(context).pop(await Playlist.newInstance(
                    name: nameController.text,
                    summary: descController.text,
                    cover: artPicPath,
                    subscriptions: [],
                  ));
                }
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

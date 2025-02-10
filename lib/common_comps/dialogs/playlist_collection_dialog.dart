import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<PlaylistCollection?> showPlaylistCollectionDialog(
  BuildContext context, {
  PlaylistCollection? defaultPlaylistCollection,
}) async {
  TextEditingController textController =
      TextEditingController(text: defaultPlaylistCollection?.name);

  return await showCupertinoDialog<PlaylistCollection?>(
    context: context,
    builder: (BuildContext context) {
      final isDarkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;

      return CupertinoAlertDialog(
        title: Text('歌单列表'),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: CupertinoTextField(
            controller: textController,
            placeholder: '歌单列表名称',
            autofocus: true,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            placeholderStyle:
                TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54),
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              if (defaultPlaylistCollection != null) {
                var playlistCollection = PlaylistCollection(
                  name: textController.text,
                  id: defaultPlaylistCollection.id,
                  order: defaultPlaylistCollection.order,
                );
                Navigator.of(context).pop(playlistCollection);
              } else {
                Navigator.of(context).pop(await PlaylistCollection.newInstance(
                    name: textController.text));
              }
            },
            child: Text('确认'),
          ),
        ],
      );
    },
  );
}

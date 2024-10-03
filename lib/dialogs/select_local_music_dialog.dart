import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_list_item.dart';
import 'package:flutter/cupertino.dart';

Future<Playlist?> showMusicListSelectionDialog(BuildContext context) async {
  var musicLists = await Playlist.getFromDb();
  if (context.mounted) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return await showCupertinoModalPopup<Playlist>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            "选择一个歌单",
            style: TextStyle(
              color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ).useSystemChineseFont(),
          ),
          actions: List<Widget>.generate(musicLists.length, (index) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context, musicLists[index]);
              },
              child: MusicListListItem(
                playlist: musicLists[index],
                onTap: () {
                  Navigator.of(context).pop(musicLists[index]);
                },
              ),
            );
          }),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, null);
            },
            isDefaultAction: true,
            child: Text(
              '取消',
              style: TextStyle(
                color: isDarkMode
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.activeBlue,
              ).useSystemChineseFont(),
            ),
          ),
        );
      },
    );
  }
  return null;
}

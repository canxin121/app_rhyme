import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_list_item.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:flutter/cupertino.dart';

Future<MusicListW?> showMusicListSelectionDialog(
  BuildContext context,
) async {
  var musicLists = await SqlFactoryW.getAllMusiclists();
  if (context.mounted) {
    return await showCupertinoModalPopup<MusicListW>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title:
              Text("选择一个歌单", style: const TextStyle().useSystemChineseFont()),
          actions: List<Widget>.generate(musicLists.length, (index) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context, musicLists[index]);
              },
              child: MusicListListItem(
                musicListW: musicLists[index],
                online: false,
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
            child: const Text('取消'),
          ),
        );
      },
    );
  }
  return null;
}

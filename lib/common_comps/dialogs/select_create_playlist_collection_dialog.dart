import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:flutter/cupertino.dart';

Future<PlaylistCollection?> showSelectCreatePlaylistCollectionDialog(
    BuildContext context) async {
  try {
    List<PlaylistCollection> playlistCollections =
        await PlaylistCollection.getFormDb();
    if (context.mounted) {
      return await showCupertinoModalPopup<PlaylistCollection>(
        context: context,
        builder: (context) {
          return SelectCreatePlaylistCollectionDialog(
            playlistCollections: playlistCollections,
          );
        },
      );
    }
  } catch (e) {
    LogToast.error(
      "歌单集合",
      "从数据库获取歌单集合失败: $e",
      "[selectPlaylistCollectionDialog] Failed to get playlist collections from db: $e",
    );
  }
  return null;
}

class SelectCreatePlaylistCollectionDialog extends StatefulWidget {
  final List<PlaylistCollection> playlistCollections;

  const SelectCreatePlaylistCollectionDialog(
      {super.key, required this.playlistCollections});

  @override
  SelectCreatePlaylistCollectionDialogState createState() =>
      SelectCreatePlaylistCollectionDialogState();
}

class SelectCreatePlaylistCollectionDialogState
    extends State<SelectCreatePlaylistCollectionDialog> {
  int selectedIndex = 0;
  TextEditingController newPlaylistController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoActionSheet(
      title: Text(
        "选择或创建歌单列表",
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          fontSize: 18,
        ),
      ),
      actions: [
        for (int index = 0; index < widget.playlistCollections.length; index++)
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedIndex = index;
              });
              Navigator.pop(context, widget.playlistCollections[index]);
            },
            child: Text(
              widget.playlistCollections[index].name,
              style: TextStyle(fontSize: 20, color: getTextColor(isDarkMode)),
            ),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () async {
          var newPc = await createPlaylistCollection(context);
          if (newPc != null && context.mounted) {
            Navigator.pop(context, newPc);
          }
        },
        isDefaultAction: true,
        child: Text("创建新歌单列表"),
      ),
    );
  }
}

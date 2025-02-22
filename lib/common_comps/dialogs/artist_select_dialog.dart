import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/types/log_toast.dart';

Future<Artist?> showArtistSelectDialog(
    BuildContext context, List<Artist> artists) async {
  try {
    if (context.mounted) {
      return await showCupertinoModalPopup<Artist>(
        context: context,
        builder: (context) {
          return ArtistSelectDialog(
            artists: artists,
          );
        },
      );
    }
  } catch (e) {
    LogToast.error(
      "艺术家选择",
      "获取艺术家列表失败: $e",
      "[showArtistSelectDialog] Failed to show artist selection dialog: $e",
    );
  }
  return null;
}

class ArtistSelectDialog extends StatefulWidget {
  final List<Artist> artists;

  const ArtistSelectDialog({super.key, required this.artists});

  @override
  ArtistSelectDialogState createState() => ArtistSelectDialogState();
}

class ArtistSelectDialogState extends State<ArtistSelectDialog> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoActionSheet(
      title: Text(
        "选择艺术家",
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          fontSize: 18,
        ),
      ),
      actions: [
        for (int index = 0; index < widget.artists.length; index++)
          CupertinoActionSheetAction(
            onPressed: widget.artists[index].id != null
                ? () {
                    setState(() {
                      selectedIndex = index;
                    });
                    Navigator.pop(context, widget.artists[index]);
                  }
                : () {
                    LogToast.error(
                      "艺术家选择",
                      "艺术家Id为空,无法选择",
                      "[ArtistSelectDialog] Artist is disabled",
                    );
                  },
            child: Text(
              widget.artists[index].name,
              style: TextStyle(
                fontSize: 20,
                color: widget.artists[index].id != null
                    ? getTextColor(isDarkMode)
                    : CupertinoColors.systemGrey,
              ),
            ),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        isDefaultAction: true,
        child: Text("取消"),
      ),
    );
  }
}

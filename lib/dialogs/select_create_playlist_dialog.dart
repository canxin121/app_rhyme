import 'package:app_rhyme/dialogs/select_create_playlist_collection_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/common_comps/playlist/playlist_list_item.dart';
import 'package:flutter/cupertino.dart';

Future<Playlist?> showSelectCratePlaylistDialog(
    BuildContext context, PlaylistCollection? playlistCollection) async {
  var playlistCollection =
      await showSelectCreatePlaylistCollectionDialog(context);
  if (playlistCollection == null) return null;

  var playlists = await playlistCollection.getPlaylistsFromDb();

  if (context.mounted) {
    return await showCupertinoModalPopup<Playlist>(
      context: context,
      builder: (BuildContext context) {
        return MusicListSelectionDialog(
          playlists: playlists,
          playlistCollection: playlistCollection,
        );
      },
    );
  }
  return null;
}

class MusicListSelectionDialog extends StatelessWidget {
  final List<Playlist> playlists;
  final PlaylistCollection playlistCollection;

  const MusicListSelectionDialog(
      {super.key, required this.playlists, required this.playlistCollection});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return CupertinoActionSheet(
      title: Text(
        "选择或创建一个歌单",
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          fontSize: 18,
        ).useSystemChineseFont(),
      ),
      message: Text(
        '请选择一个已有的歌单，或创建一个新的。',
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          fontSize: 16,
        ).useSystemChineseFont(),
      ),
      actions: [
        for (int index = 0; index < playlists.length; index++)
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, playlists[index]);
            },
            child: PlaylistListItem(
              playlist: playlists[index],
              onTap: () {
                Navigator.pop(context, playlists[index]);
              },
            ),
          ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () async {
          var newPlaylist = await createPlaylist(context,
              playlistCollection: playlistCollection);

          if (newPlaylist != null && context.mounted) {
            Navigator.pop(context, newPlaylist);
          }
        },
        isDefaultAction: true,
        child: Text("创建新歌单"),
      ),
    );
  }
}

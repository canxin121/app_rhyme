import 'package:app_rhyme/common_pages/db_playlist_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:flutter/material.dart';

class PlaylistCollectionSlider extends StatelessWidget {
  final List<(PlaylistCollection, List<Playlist>)> playlistsCollections;
  final bool isDesktop;

  const PlaylistCollectionSlider({
    super.key,
    required this.playlistsCollections,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final TextStyle textStyle = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w500,
      color: tagRedColor,
    );

    final Color dividerColor = isDarkMode ? Colors.white : Colors.black;

    Widget buildPlaylistCollectionItem(
        PlaylistCollection playlistCollection, List<Playlist> playlists) {
      return GestureDetector(
        onTap: () {
          navigate(
            context,
            DbPlaylistGridPage(
              isDesktop: isDesktop,
              playlists: playlists,
              playlistCollection: playlistCollection,
            ),
            isDesktop,
            "",
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(playlistCollection.name, style: textStyle),
        ),
      );
    }

    List<Widget> buildPlaylistItemsWithDivider() {
      List<Widget> items = [];

      items.add(buildPlaylistCollectionItem(
        PlaylistCollection(id: -1, order: -1, name: "全部歌单"),
        playlistsCollections.expand((collection) => collection.$2).toList(),
      ));

      for (var i = 0; i < playlistsCollections.length; i++) {
        items.add(
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 20,
              thickness: 2,
              color: dividerColor,
            ),
          ),
        );

        var (collection, playlists) = playlistsCollections[i];
        items.add(buildPlaylistCollectionItem(collection, playlists));
      }

      return items;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buildPlaylistItemsWithDivider(),
          ),
        ),
      ),
    );
  }
}

import 'package:app_rhyme/common_comps/card/rhyme_card.dart';
import 'package:app_rhyme/common_pages/online_playlist_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

class PlaylistTagCollectionSlider extends StatelessWidget {
  final MusicServer server;
  final PlaylistTagCollection tagCollection;
  final bool isDesktop;
  final double imageCardSize;

  const PlaylistTagCollectionSlider({
    super.key,
    required this.server,
    required this.tagCollection,
    required this.isDesktop,
    this.imageCardSize = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
          child: Text(
            tagCollection.name,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: getTextColor(isDarkMode),
            ).useSystemChineseFont(),
          ),
        ),
        SizedBox(
          height: imageCardSize + 16,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tagCollection.tags.length,
            itemBuilder: (context, index) {
              final tag = tagCollection.tags[index];

              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    height: imageCardSize + 16,
                    width: imageCardSize,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: RhymeCard(
                            title: tag.name,
                            onClick: () {
                              navigate(
                                context,
                                OnlinePlaylistGridViewPage(
                                  title: tag.name,
                                  isDesktop: isDesktop,
                                  fetchPlaylists: (int page, int limit,
                                      List<Playlist> playlists) async {
                                    return await ServerPlaylistTagCollection
                                        .getPlaylistsFromTag(
                                      server: server,
                                      tagId: tag.id,
                                      order: TagPlaylistOrder.hot,
                                      page: page,
                                      limit: limit,
                                    );
                                  },
                                ),
                                isDesktop,
                                "",
                              );
                            },
                            onSecondaryClick: () {},
                          )),
                    ),
                  ));
            },
          ),
        ),
      ],
    );
  }
}

class ServerPlaylistTagCollectionSliderRows extends StatelessWidget {
  final ServerPlaylistTagCollection serverPlaylistTagCollection;
  final double imageCardSize;
  final bool isDesktop;

  const ServerPlaylistTagCollectionSliderRows({
    super.key,
    required this.serverPlaylistTagCollection,
    required this.isDesktop,
    this.imageCardSize = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            serverPlaylistTagCollection.server.name,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ).useSystemChineseFont(),
          ),
        ),
        const SizedBox(height: 16.0),
        Column(
          children:
              serverPlaylistTagCollection.collections.map((tagCollection) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PlaylistTagCollectionSlider(
                server: serverPlaylistTagCollection.server,
                tagCollection: tagCollection,
                isDesktop: isDesktop,
                imageCardSize: imageCardSize,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PlaylistTagCollectionList extends StatelessWidget {
  final List<ServerPlaylistTagCollection> collections;
  final bool isDesktop;

  const PlaylistTagCollectionList({
    super.key,
    required this.collections,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final serverPlaylistTagCollection = collections[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ServerPlaylistTagCollectionSliderRows(
            serverPlaylistTagCollection: serverPlaylistTagCollection,
            isDesktop: isDesktop,
          ),
        );
      },
    );
  }
}

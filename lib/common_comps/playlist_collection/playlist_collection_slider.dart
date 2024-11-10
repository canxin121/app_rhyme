import 'package:app_rhyme/common_comps/card/playlist_card.dart';
import 'package:app_rhyme/common_pages/db_music_agg_listview_page.dart';
import 'package:app_rhyme/common_pages/db_playlist_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:flutter/cupertino.dart';

class PlaylistCollectionCardSlider extends StatelessWidget {
  final GestureTapCallback? onTagTap;
  final PlaylistCollection playlistCollection;
  final List<Playlist> playlists;
  final bool isDesktop;
  final double imageCardSize = 200.0;

  const PlaylistCollectionCardSlider({
    super.key,
    required this.playlists,
    this.onTagTap,
    required this.isDesktop,
    required this.playlistCollection,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTagTap,
          child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          Text(
                            playlistCollection.name,
                            style: TextStyle(
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold,
                              color: getTextColor(isDarkMode),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.forward,
                            size: 35.0,
                            color: getTextColor(isDarkMode),
                          ),
                        ],
                      ),
                      onPressed: () {
                        navigate(
                            context,
                            DbPlaylistGridPage(
                              isDesktop: isDesktop,
                              playlists: playlists,
                              playlistCollection: playlistCollection,
                            ),
                            isDesktop,
                            "");
                      }),
                  CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.play_circle_fill,
                        color: activeIconRed,
                        size: 32.0,
                      ),
                      onPressed: () async {
                        final Map<String, MusicAggregator> musicMap = {};
                        for (final playlist in playlists) {
                          final musicList = await playlist.getMusicsFromDb();
                          for (final music in musicList) {
                            musicMap["${music.name}_${music.artist}"] = music;
                          }
                        }
                        final musicList = musicMap.values
                            .map((e) => MusicContainer(e))
                            .toList();
                        globalAudioHandler.clearReplaceMusicAll(musicList);
                      })
                ],
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 18.0, top: 12),
          child: SizedBox(
              height: imageCardSize + 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: SizedBox(
                        width: imageCardSize,
                        height: imageCardSize,
                        child: PlaylistCard(
                          playlist: playlist,
                          onTap: () {
                            navigate(
                                context,
                                DbMusicContainerListPage(
                                  playlist: playlist,
                                  isDesktop: isDesktop,
                                ),
                                isDesktop,
                                "");
                          },
                          cacheCover: globalConfig.storageConfig.saveCover,
                          showDesc: false,
                        ),
                      ));
                },
              )),
        ),
      ],
    );
  }
}

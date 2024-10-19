import 'package:app_rhyme/common_pages/db_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:flutter/cupertino.dart';

class TagPlaylistCardSlider extends StatelessWidget {
  final String tag;
  final GestureTapCallback? onTagTap;
  final List<Playlist> playlists;
  final bool isDesktop;
  final double imageCardSize = 200.0;

  const TagPlaylistCardSlider({
    super.key,
    required this.tag,
    required this.playlists,
    this.onTagTap,
    this.isDesktop = false,
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
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
                color: getTextColor(isDarkMode),
              ),
            ),
          ),
        ),
        SizedBox(
            height: imageCardSize + 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: isDesktop
                        ? SizedBox(
                            width: imageCardSize,
                            height: imageCardSize,
                            child: DesktopPlaylistImageCard(
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
                              cacheCover: true,
                              showDesc: false,
                            ),
                          )
                        : SizedBox(
                            width: imageCardSize,
                            height: imageCardSize,
                            child: MobilePlaylistImageCard(
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
                              cacheCover: true,
                              showDesc: true,
                            )));
              },
            )),
      ],
    );
  }
}

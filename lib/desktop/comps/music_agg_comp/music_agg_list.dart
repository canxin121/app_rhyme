import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MusicAggregatorList extends StatelessWidget {
  final Playlist playlist;
  final List<MusicAggregator> musicAggs;
  final bool cacheCover;

  const MusicAggregatorList({
    super.key,
    required this.musicAggs,
    required this.playlist,
    this.cacheCover = false,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return const MusicAggregatorListHeaderRow();
          }
          final musicAgg = musicAggs[index - 1];
          return Padding(
            padding: const EdgeInsets.only(
              top: 2,
              bottom: 2,
            ),
            child: DesktopMusicAggregatorListItem(
              key: ValueKey(musicAgg.identity()),
              musicAgg: musicAgg,
              isDarkMode: isDarkMode,
              hasBackgroundColor: index % 2 == 1,
              playlist: playlist,
              cacheCover: cacheCover,
            ),
          );
        },
        childCount: musicAggs.length + 1,
      ),
    );
  }
}

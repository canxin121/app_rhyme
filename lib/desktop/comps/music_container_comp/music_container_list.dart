import 'package:app_rhyme/desktop/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:flutter/material.dart';

class MusicContainerList extends StatelessWidget {
  final MusicListW musicListW;
  final List<MusicContainer> musicContainers;

  const MusicContainerList({
    super.key,
    required this.musicContainers,
    required this.musicListW,
  });

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: MusicContainerListHeaderRow(),
            );
          }
          final musicContainer = musicContainers[index - 1];
          return Padding(
            padding: const EdgeInsets.only(
              top: 2,
              bottom: 2,
            ),
            child: MusicContainerListItem(
              musicContainer: musicContainer,
              isDarkMode: isDarkMode,
              hasBackgroundColor: index % 2 == 1,
              musicListW: musicListW,
            ),
          );
        },
        childCount: musicContainers.length + 1,
      ),
    );
  }
}

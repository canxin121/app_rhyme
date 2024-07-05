import 'package:app_rhyme/comps/chores/badge.dart';
import 'package:app_rhyme/comps/music_container_comp/music_container_pulldown_menu.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';

class MusicContainerImageCard extends StatelessWidget {
  final MusicContainer musicContainer;
  final GestureTapCallback? onTap;
  const MusicContainerImageCard({
    super.key,
    required this.musicContainer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: onTap ??
                () {
                  globalAudioHandler.addMusicPlay(musicContainer);
                },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    MusicContainerMenu(
                      builder: (context, showMenu) => GestureDetector(
                        onLongPress: showMenu,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: imageCacheHelper(musicContainer.info.artPic),
                        ),
                      ),
                      musicContainer: musicContainer,
                    ),
                    Positioned(
                      top: 3,
                      left: 3,
                      child: Badge(
                        label: sourceToShort(musicContainer.info.source),
                        isDark: true,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: MusicContainerMenu(
                        builder: (context, showMenu) => GestureDetector(
                          onTap: showMenu,
                          child: Icon(CupertinoIcons.ellipsis_circle,
                              color: activeIconRed),
                        ),
                        musicContainer: musicContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Center(
                    child: Text(
                      musicContainer.info.name,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Center(
                    child: ArtistsMenu(
                        artists: musicContainer.info.artist,
                        builder: (_, showMenu) => GestureDetector(
                              onTap: () {
                                showMenu();
                              },
                              child: Text(
                                musicContainer.info.artist.join(", "),
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .copyWith(
                                      color: CupertinoColors.systemRed,
                                      fontSize: 16,
                                    ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

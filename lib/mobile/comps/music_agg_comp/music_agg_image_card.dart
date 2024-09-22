import 'package:app_rhyme/mobile/comps/chores/badge.dart';
import 'package:app_rhyme/pulldown_menus/music_aggregator_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';

class MusicContainerImageCard extends StatelessWidget {
  final MusicAggregator musicAgg;
  final GestureTapCallback? onTap;

  const MusicContainerImageCard({
    super.key,
    required this.musicAgg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的亮度
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    Music? defaultMusic = getMusicAggregatorDefaultMusic(musicAgg);
    if (defaultMusic == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: onTap ??
                () {
                  globalAudioHandler.addMusicPlay(MusicContainer(musicAgg));
                },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onLongPressEnd: (details) {
                        Rect position = Rect.fromPoints(
                          details.globalPosition,
                          details.globalPosition,
                        );
                        showMusicAggregatorMenu(
                          context,
                          musicAgg,
                          false,
                          position,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: imageWithCache(defaultMusic.cover),
                      ),
                    ),
                    if (!musicAgg.fromDb)
                      Positioned(
                        top: 3,
                        left: 3,
                        child: Badge(
                          label: defaultMusic.server.toString(),
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTapDown: (details) {
                          Rect position = Rect.fromPoints(
                            details.globalPosition,
                            details.globalPosition,
                          );
                          showMusicAggregatorMenu(
                            context,
                            musicAgg,
                            false,
                            position,
                          );
                        },
                        child: Icon(
                          CupertinoIcons.ellipsis_circle,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : activeIconRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Center(
                    child: Text(
                      defaultMusic.name,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle().useSystemChineseFont(),
                    ),
                  ),
                ),
                // const SizedBox(height: 4),
                // Flexible(
                //   child: Center(
                //     child: ArtistsMenu(
                //         artists: musicContainer.info.artist,
                //         builder: (_, showMenu) => GestureDetector(
                //               onTap: () {
                //                 showMenu();
                //               },
                //               child: Text(
                //                 musicContainer.info.artist.join(", "),
                //                 textAlign: TextAlign.center,
                //                 overflow: TextOverflow.ellipsis,
                //               ),
                //             )),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}

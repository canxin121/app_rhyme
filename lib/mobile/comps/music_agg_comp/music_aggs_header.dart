import 'package:app_rhyme/common_comps/card/playlist_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_rhyme/mobile/comps/chores/button.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/global_vars.dart';

class MobileMusicAggsHeader extends StatelessWidget {
  const MobileMusicAggsHeader(
      {super.key,
      required this.musicAggregators,
      required this.isDarkMode,
      this.fetchAllMusicAggregators,
      required this.title,
      this.summary,
      this.cover});
  final String title;
  final String? summary;
  final String? cover;
  final List<MusicAggregator> musicAggregators;
  final bool isDarkMode;
  final Future<List<MusicAggregator>> Function()? fetchAllMusicAggregators;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.only(
              top: 10, left: screenWidth * 0.15, right: screenWidth * 0.15),
          child: Container(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.7,
              ),
              child: CustomPlaylistCard(
                title: title,
                cover: cover,
                showButton: false,
                size: screenWidth * 0.7,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildButton(
                context,
                icon: CupertinoIcons.play_fill,
                label: '播放',
                onPressed: () async {
                  var musicAggs = musicAggregators;
                  if (fetchAllMusicAggregators != null) {
                    musicAggs = await fetchAllMusicAggregators!();
                  }
                  await globalAudioHandler.clearReplaceMusicAll(musicAggs
                      .map(
                        (e) => MusicContainer(e),
                      )
                      .toList());
                },
              ),
              buildButton(
                context,
                icon: Icons.shuffle,
                label: '随机播放',
                onPressed: () async {
                  var musicAggs = musicAggregators;
                  if (fetchAllMusicAggregators != null) {
                    musicAggs = await fetchAllMusicAggregators!();
                  }
                  await globalAudioHandler.clearReplaceMusicAll(shuffleList(
                    musicAggs
                        .map(
                          (e) => MusicContainer(e),
                        )
                        .toList(),
                  ));
                },
              ),
            ],
          ),
        ),
        Center(
          child: SizedBox(
            width: screenWidth * 0.85,
            child: Divider(
              color: dividerColor,
              height: 0.5,
            ),
          ),
        ),
      ]),
    );
  }
}

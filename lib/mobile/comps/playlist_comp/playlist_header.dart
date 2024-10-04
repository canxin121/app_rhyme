import 'package:app_rhyme/utils/log_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_rhyme/mobile/comps/chores/button.dart';
import 'package:app_rhyme/mobile/comps/playlist_comp/playlist_image_card.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/global_vars.dart';

class MobilePlaylistHeader extends StatelessWidget {
  const MobilePlaylistHeader(
      {super.key,
      required this.playlist,
      required this.musicAggregators,
      required this.isDarkMode,
      this.fetchAllMusicAggregators});
  final Playlist playlist;
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
            child: MobilePlaylistImageCard(
              playlist: playlist,
              cacheCover: globalConfig.storageConfig.saveCover,
            ),
          ),
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
                    LogToast.info("加载音乐", "正在加载所有音乐,请稍等",
                        "[MobilePlaylistHeader.fetchAllMuiscAggregators] loading");
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
                    LogToast.info("加载音乐", "正在加载所有音乐,请稍等",
                        "[MobilePlaylistHeader.fetchAllMuiscAggregators] loading");
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

import 'package:app_rhyme/desktop/comps/play_button.dart';
import 'package:app_rhyme/common_comps/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class MusicListHeader extends StatelessWidget {
  const MusicListHeader({
    super.key,
    required this.isDarkMode,
    required this.screenWidth,
    required this.playlist,
    required this.musicAggregators,
    this.fetchAllMusicAggregators,
    this.cacheCover = false,
  });
  final Playlist playlist;
  final List<MusicAggregator> musicAggregators;
  final Future<List<MusicAggregator>> Function()? fetchAllMusicAggregators;
  final bool isDarkMode;
  final bool cacheCover;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 封面
          Container(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
            ),
            margin: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: imageWithCache(playlist.getCover(size: 250),
                  enableCache: cacheCover, width: 250, height: 250),
            ),
          ),
          // 歌单信息
          SizedBox(
            width: screenWidth * 0.3,
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  playlist.name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)
                      .useSystemChineseFont(),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  playlist.summary ?? "",
                  maxLines: 4,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 14)
                      .useSystemChineseFont(),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildMobileRedButton(context,
                        icon: CupertinoIcons.play_fill,
                        label: "播放", onPressed: () async {
                      var musicAggs = musicAggregators;
                      if (fetchAllMusicAggregators != null) {
                        musicAggs = await fetchAllMusicAggregators!();
                      }
                      await globalAudioHandler.clearReplaceMusicAll(musicAggs
                          .map(
                            (e) => MusicContainer(e),
                          )
                          .toList());
                    }),
                    const SizedBox(width: 10),
                    buildMobileRedButton(context,
                        icon: CupertinoIcons.shuffle,
                        label: "随机播放", onPressed: () async {
                      var musicAggs = musicAggregators;
                      if (fetchAllMusicAggregators != null) {
                        musicAggs = await fetchAllMusicAggregators!();
                      }
                      await globalAudioHandler
                          .clearReplaceMusicAll(shuffleList(musicAggs
                              .map(
                                (e) => MusicContainer(e),
                              )
                              .toList()));
                    }),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  top: 250 - 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.pencil,
                          color: activeIconRed,
                          size: 20,
                        ),
                        onPressed: () async {
                          editPlaylistListToDb(context, playlist);
                        }),
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(
                          CupertinoIcons.arrow_down,
                          color: activeIconRed,
                          size: 20,
                        ),
                        onPressed: () async {
                          bool confirm = (await showConfirmationDialog(
                                  context, "确定要缓存所有音乐吗?")) ??
                              false;
                          if (!confirm) return;
                          cacheMusicAggs(musicAggregators);
                        }),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

import 'package:app_rhyme/common_pages/multi_selection_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/reorder_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/comps/play_button.dart';
import 'package:app_rhyme/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MusicListHeader extends StatelessWidget {
  const MusicListHeader({
    super.key,
    required this.isDarkMode,
    required this.screenWidth,
    required this.playlist,
    this.pagingController,
    this.musicAggs,
    this.fetchAllMusicAggregators,
  });
  final Playlist playlist;
  final PagingController<int, MusicAggregator>? pagingController;
  final List<MusicAggregator>? musicAggs;
  final Future<void> Function()? fetchAllMusicAggregators;
  final bool isDarkMode;
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
                  cacheNow: globalConfig.storageConfig.savePic,
                  width: 250,
                  height: 250),
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
                    buildButton(context,
                        icon: CupertinoIcons.play_fill,
                        label: "播放", onPressed: () async {
                      try {
                        if (musicAggs != null) {
                          await globalAudioHandler.clearReplaceMusicAll(
                              musicAggs!
                                  .map((e) => MusicContainer(e))
                                  .toList());
                        } else if (pagingController != null &&
                            pagingController!.itemList != null) {
                          await fetchAllMusicAggregators!();
                          await globalAudioHandler.clearReplaceMusicAll(
                              pagingController!.itemList!
                                  .map((e) => MusicContainer(e))
                                  .toList());
                        } else {
                          throw "musicAggs and pagingController is null";
                        }
                      } catch (e) {
                        LogToast.error("播放全部", "播放失败",
                            "[MusicListHeader] play all failed");
                      }
                    }),
                    const SizedBox(width: 10),
                    buildButton(context,
                        icon: CupertinoIcons.shuffle,
                        label: "随机播放", onPressed: () async {
                      try {
                        if (musicAggs != null) {
                          await globalAudioHandler.clearReplaceMusicAll(
                              shuffleList(musicAggs!
                                  .map((e) => MusicContainer(e))
                                  .toList()));
                        } else if (pagingController != null &&
                            pagingController!.itemList != null) {
                          await fetchAllMusicAggregators!();
                          await globalAudioHandler.clearReplaceMusicAll(
                              shuffleList(pagingController!.itemList!
                                  .map((e) => MusicContainer(e))
                                  .toList()));
                        } else {
                          throw "musicAggs and pagingController is null";
                        }
                      } catch (e) {
                        LogToast.error("随机播放", "播放失败",
                            "[MusicListHeader] shuffle play all failed");
                      }
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
                    if (musicAggs != null)
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(
                            CupertinoIcons.pencil,
                            color: activeIconRed,
                            size: 20,
                          ),
                          onPressed: () async {
                            editPlaylistListInfo(context, playlist);
                          }),
                    if (musicAggs != null)
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
                            for (var musicAgg in musicAggs!) {
                              await cacheMusicContainer(
                                  MusicContainer(musicAgg));
                            }
                          }),
                    if (musicAggs == null)
                      GestureDetector(
                          onTapDown: (details) {
                            Rect position = Rect.fromPoints(
                              details.globalPosition,
                              details.globalPosition,
                            );
                            showPlaylistMenu(
                                context, playlist, position, true, false);
                          },
                          child: Icon(
                            CupertinoIcons.ellipsis,
                            color: activeIconRed,
                            size: 20,
                          )),
                    if (musicAggs != null)
                      DesktopLocalMusicListChoicMenu(
                          builder: (context, showMenu) => CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: showMenu,
                              child: Icon(
                                CupertinoIcons.ellipsis,
                                color: activeIconRed,
                                size: 20,
                              )),
                          playlist: playlist,
                          musicAggs: musicAggs!)
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

@immutable
class DesktopLocalMusicListChoicMenu extends StatelessWidget {
  const DesktopLocalMusicListChoicMenu({
    super.key,
    required this.builder,
    required this.playlist,
    required this.musicAggs,
  });

  final PullDownMenuButtonBuilder builder;
  final Playlist playlist;
  final List<MusicAggregator> musicAggs;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          leading: imageWithCache(playlist.getCover(size: 250),
              width: 40, height: 40),
          title: playlist.name,
          subtitle: playlist.summary,
        ),
        const PullDownMenuDivider.large(),
        ...playlistMenuItems(context, playlist, true, true),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            for (var musicAgg in musicAggs) {
              await cacheMusicContainer(MusicContainer(musicAgg));
            }
          },
          title: '缓存歌单所有音乐',
          icon: CupertinoIcons.cloud_download,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            for (var musicContainer in musicAggs) {
              await delMusicAggregatorCache(musicContainer, showToast: false);
            }
            LogToast.success("删除所有音乐缓存", "删除所有音乐缓存成功",
                "[LocalMusicListChoicMenu] Successfully deleted all music caches");
          },
          title: '删除所有音乐缓存',
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            globalNavigatorToPage(
                MuiscAggregatorReorderPage(
                  musicAggregators: musicAggs,
                  playlist: playlist,
                  isDesktop: true,
                ),
                replace: false);
          },
          title: "手动排序",
          icon: CupertinoIcons.sort_up_circle,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            globalNavigatorToPage(
                MusicAggregatorMultiSelectionPage(
                  playlist: playlist,
                  musicAggs: musicAggs,
                  isDesktop: true,
                ),
                replace: false);
          },
          title: "多选操作",
          icon: CupertinoIcons.selection_pin_in_out,
        )
      ],
      buttonBuilder: builder,
    );
  }
}

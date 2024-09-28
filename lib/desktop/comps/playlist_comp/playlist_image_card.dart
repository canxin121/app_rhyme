import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/cache_helper.dart';

class DesktopPlaylistImageCard extends StatefulWidget {
  final Playlist playlist;
  final GestureTapCallback? onTap;
  final bool cachePic;
  final bool showDesc;

  const DesktopPlaylistImageCard(
      {super.key,
      required this.playlist,
      this.onTap,
      this.cachePic = false,
      this.showDesc = true});

  @override
  DesktopPlaylistImageCardState createState() =>
      DesktopPlaylistImageCardState();
}

class DesktopPlaylistImageCardState extends State<DesktopPlaylistImageCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() {
            _hovering = true;
          }),
          onExit: (_) => setState(() {
            _hovering = false;
          }),
          child: GestureDetector(
            onSecondaryTapDown: (details) {
              final Offset tapPosition = details.globalPosition;
              final Rect position =
                  Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
              showPlaylistMenu(context, widget.playlist, position, true, false);
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: imageWithCache(widget.playlist.getCover(size: 250),
                        cacheNow: widget.cachePic, width: 250, height: 250),
                  ), // 100x100
                ),
                if (_hovering)
                  Positioned.fill(
                    child: Container(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                    ),
                  ),
                if (_hovering || isTablet(context))
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTapDown: (details) {
                        Rect position = Rect.fromPoints(
                          details.globalPosition,
                          details.globalPosition,
                        );
                        showPlaylistMenu(
                            context, widget.playlist, position, true, false);
                      },
                      child: Icon(
                        CupertinoIcons.ellipsis_circle,
                        color:
                            isDarkMode ? CupertinoColors.white : activeIconRed,
                      ),
                    ),
                  ),
                if (_hovering || isTablet(context))
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () async { 
                        try {
                          List<MusicAggregator> aggs;
                          if (widget.playlist.fromDb) {
                            aggs = await widget.playlist.getMusicsFromDb();
                          } else {
                            LogToast.info("获取歌曲", "正在获取歌曲，请稍等",
                                "[PlaylistImageCard] fetching musics, please wait");

                            aggs = await widget.playlist
                                .fetchMusicsOnline(page: 1, limit: 2333);
                          }

                          await globalAudioHandler.clearReplaceMusicAll(
                              aggs.map((e) => MusicContainer(e)).toList());
                        } catch (e) {
                          LogToast.error("播放全部", "播放失败: $e",
                              "[PlaylistImageCard] play all failed: $e");
                        }
                      },
                      child: Icon(
                        CupertinoIcons.play_circle,
                        color:
                            isDarkMode ? CupertinoColors.white : activeIconRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          fit: FlexFit.loose,
          child: Center(
            child: Text(
              widget.playlist.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
              style: TextStyle(color: textColor, fontSize: 16)
                  .useSystemChineseFont(),
              maxLines: 2,
            ),
          ),
        ),
        if (widget.showDesc) const SizedBox(height: 4),
        if (widget.showDesc)
          Flexible(
            fit: FlexFit.loose,
            child: Center(
              child: Text(
                widget.playlist.summary ?? "",
                style: TextStyle(
                  color: isDarkMode
                      ? CupertinoColors.systemGrey4
                      : CupertinoColors.systemGrey,
                  fontSize: 12,
                ).useSystemChineseFont(),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return widget.onTap != null
              ? GestureDetector(
                  onTap: widget.onTap,
                  child: cardContent,
                )
              : cardContent;
        },
      ),
    );
  }
}

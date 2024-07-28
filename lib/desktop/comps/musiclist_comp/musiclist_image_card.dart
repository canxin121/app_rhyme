import 'package:app_rhyme/pulldown_menus/musiclist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MusicListImageCard extends StatefulWidget {
  final MusicListW musicListW;
  final bool online;
  final GestureTapCallback? onTap;
  final bool cachePic;
  final bool showDesc;

  const MusicListImageCard(
      {super.key,
      required this.musicListW,
      required this.online,
      this.onTap,
      this.cachePic = false,
      this.showDesc = true});

  @override
  _MusicListImageCardState createState() => _MusicListImageCardState();
}

class _MusicListImageCardState extends State<MusicListImageCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    MusicListInfo musicListInfo = widget.musicListW.getMusiclistInfo();
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
              List<PullDownMenuEntry> menuItems;
              if (!widget.online) {
                // 本地歌单的歌曲
                menuItems = localMusiclistItems(context, widget.musicListW);
              } else {
                // 在线的歌曲
                menuItems = onlineMusicListItems(context, widget.musicListW);
              }
              showPullDownMenu(
                  context: context, items: menuItems, position: position);
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: imageCacheHelper(musicListInfo.artPic,
                      cacheNow: widget.cachePic),
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
                        showMusicListMenu(context, widget.musicListW,
                            widget.online, position);
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
                        var aggs = await widget.musicListW
                            .fetchAllMusicAggregators(
                                pagesPerBatch: 5, limit: 50, withLyric: false);
                        await globalAudioHandler.clearReplaceMusicAll(
                            aggs.map((e) => MusicContainer(e)).toList());
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
              musicListInfo.name,
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
                musicListInfo.desc,
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

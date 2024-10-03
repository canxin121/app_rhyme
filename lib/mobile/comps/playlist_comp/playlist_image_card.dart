import 'package:app_rhyme/pulldown_menus/playlist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/cache_helper.dart';

class MobilePlaylistImageCard extends StatelessWidget {
  final Playlist playlist;
  final GestureTapCallback? onTap;
  final bool cacheCover;
  final bool showDesc;
  const MobilePlaylistImageCard(
      {super.key,
      required this.playlist,
      this.onTap,
      this.cacheCover = false,
      this.showDesc = true});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textCOlor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imageWithCache(playlist.getCover(size: 250),
                  cacheHeight: 100, cacheWidth: 100, enableCache: cacheCover),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTapDown: (details) {
                  Rect position = Rect.fromLTWH(details.globalPosition.dx,
                      details.globalPosition.dy, 0, 0);
                  showPlaylistMenu(context, playlist, position, false, false);
                },
                child: Icon(
                  CupertinoIcons.ellipsis_circle,
                  color: isDarkMode ? CupertinoColors.white : activeIconRed,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Flexible(
          fit: FlexFit.loose,
          child: Center(
            child: Text(
              playlist.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textCOlor, fontSize: 16)
                  .useSystemChineseFont(),
              maxLines: 2,
            ),
          ),
        ),
        if (showDesc) const SizedBox(height: 4),
        if (showDesc)
          Flexible(
            fit: FlexFit.loose,
            child: Center(
              child: Text(
                playlist.summary ?? "",
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
          return onTap != null
              ? GestureDetector(
                  onTap: onTap,
                  child: cardContent,
                )
              : cardContent;
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:app_rhyme/common_comps/card/rhyme_card.dart';
import 'package:app_rhyme/common_comps/custom/custom_button.dart';
import 'package:app_rhyme/pulldown_menus/musics_playlist_smart_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/cache_helper.dart';

class PlaylistCardButtons extends StatefulWidget {
  final VoidCallback onPlayAll;

  final void Function(TapDownDetails details) onShowMenu;
  final Widget child;

  const PlaylistCardButtons({
    super.key,
    required this.onPlayAll,
    required this.onShowMenu,
    required this.child,
  });

  @override
  PlaylistCardButtonsState createState() => PlaylistCardButtonsState();
}

class PlaylistCardButtonsState extends State<PlaylistCardButtons> {
  bool _hovering = false;

  bool get isDesktop {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (isDesktop) {
          setState(() {
            _hovering = true;
          });
        }
      },
      onExit: (_) {
        if (isDesktop) {
          setState(() {
            _hovering = false;
          });
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_hovering || !isDesktop)
            Positioned.fill(
              child: Container(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
              ),
            ),
          Positioned(
              bottom: -5,
              right: -5,
              child: CustomCupertinoButton(
                  child: Icon(
                    CupertinoIcons.ellipsis_circle,
                    size: 32,
                    color: activeIconRed,
                  ),
                  onPressed: (details) {
                    widget.onShowMenu(details);
                  })),
          Positioned(
            bottom: -5,
            left: -5,
            child: CupertinoButton(
              onPressed: widget.onPlayAll,
              child: Icon(
                CupertinoIcons.play_circle,
                size: 32,
                color: activeIconRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPlaylistCard extends StatefulWidget {
  final String title;
  final String? summary;
  final String? cover;
  final GestureTapCallback? onTap;
  final bool cacheCover;
  final bool showTitle;
  final bool showDesc;
  final void Function(Rect position)? showMenu;
  final Future<List<MusicAggregator>?> Function()?
      getOrFetchAllMusicAggregators;
  final double? cacheImageSize;
  final double? size;
  final bool showButton;

  const CustomPlaylistCard({
    super.key,
    required this.title,
    this.summary,
    required this.cover,
    this.onTap,
    this.showTitle = true,
    this.cacheCover = false,
    this.showDesc = false,
    this.showMenu,
    this.getOrFetchAllMusicAggregators,
    this.cacheImageSize,
    this.showButton = true,
    this.size,
  });

  @override
  CustomPlaylistCardState createState() => CustomPlaylistCardState();
}

class CustomPlaylistCardState extends State<CustomPlaylistCard> {
  void handleshowMenu(TapDownDetails details) async {
    if (widget.showMenu == null) return;
    final Offset tapPosition = details.globalPosition;
    final Rect position = Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
    widget.showMenu!(position);
  }

  void handlePlayAll() async {
    if (widget.getOrFetchAllMusicAggregators == null) return;

    List<MusicAggregator>? aggs = await widget.getOrFetchAllMusicAggregators!();

    if (aggs == null || aggs.isEmpty) return;

    try {
      await globalAudioHandler
          .clearReplaceMusicAll(aggs.map((e) => MusicContainer(e)).toList());
    } catch (e) {
      LogToast.error(
          "播放全部", "播放失败: $e", "[CustomPlaylistCard] play all failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    Widget playlistCardChild = SizedBox(
      height: widget.cacheImageSize,
      width: widget.cacheImageSize,
      child: widget.cover != null
          ? AspectRatio(
              aspectRatio: 1,
              child: imageWithCache(
                widget.cover,
                enableCache: widget.cacheCover,
                width: widget.size,
                height: widget.size,
                cacheHeight: widget.cacheImageSize,
                cacheWidth: widget.cacheImageSize,
              ))
          : SizedBox(
              width: widget.size,
              height: widget.size,
              child: RhymeCard(title: widget.title),
            ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: GestureDetector(
              onTap: widget.onTap,
              child: widget.showButton
                  ? PlaylistCardButtons(
                      onPlayAll: handlePlayAll,
                      onShowMenu: handleshowMenu,
                      child: playlistCardChild,
                    )
                  : playlistCardChild,
            )),
        if (widget.showTitle) const SizedBox(height: 8),
        if (widget.showTitle)
          Flexible(
            fit: FlexFit.loose,
            child: Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        fontSize: 20)
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
                widget.summary ?? "",
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
  }
}

class PlaylistCard extends StatefulWidget {
  final Playlist playlist;
  final GestureTapCallback? onTap;
  final bool cacheCover;
  final bool showDesc;
  final double? cacheImageSize;
  final bool showButton;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.cacheCover = false,
    this.showDesc = false,
    this.cacheImageSize,
    this.showButton = true,
  });

  @override
  PlaylistCardState createState() => PlaylistCardState();
}

class PlaylistCardState extends State<PlaylistCard> {
  @override
  Widget build(BuildContext context) {
    return CustomPlaylistCard(
      title: widget.playlist.name,
      summary: widget.playlist.summary,
      cover: widget.playlist.getCover(size: 250) ?? "",
      onTap: widget.onTap,
      cacheCover: widget.cacheCover,
      showDesc: widget.showDesc,
      getOrFetchAllMusicAggregators: () async {
        return await getOrFetchAllMusicAgrgegatorsFromPlaylist(widget.playlist);
      },
      showMenu: (Rect position) {
        showMusicPlaylistSmartMenu(
            context, widget.playlist, position, true, false);
      },
      cacheImageSize: widget.cacheImageSize,
      showButton: widget.showButton,
    );
  }
}

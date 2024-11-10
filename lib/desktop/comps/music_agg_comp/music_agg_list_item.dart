import 'dart:async';

import 'package:app_rhyme/pulldown_menus/music_aggregator_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MusicAggregatorListHeaderRow extends StatelessWidget {
  const MusicAggregatorListHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor = isDarkMode
        ? CupertinoColors.systemGrey
        : const Color.fromARGB(255, 160, 160, 160);
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
      child: TableRowWidget(
        children: [
          Text(
            '歌曲',
            style: TextStyle(color: textColor).useSystemChineseFont(),
          ),
          Text(
            '艺人',
            style: TextStyle(color: textColor).useSystemChineseFont(),
          ),
          Text(
            '专辑',
            style: TextStyle(color: textColor).useSystemChineseFont(),
          ),
          Text(
            '时长',
            style: TextStyle(color: textColor).useSystemChineseFont(),
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}

class DesktopMusicAggregatorListItem extends StatefulWidget {
  final Playlist? playlist;
  final MusicAggregator musicAgg;
  final bool isDarkMode;
  final bool hasBackgroundColor;
  final void Function()? onTap;
  final bool cacheCover;

  const DesktopMusicAggregatorListItem({
    super.key,
    required this.musicAgg,
    required this.isDarkMode,
    required this.hasBackgroundColor,
    this.onTap,
    this.playlist,
    this.cacheCover = false,
  });

  @override
  DesktopMusicAggregatorListItemState createState() =>
      DesktopMusicAggregatorListItemState();
}

class DesktopMusicAggregatorListItemState
    extends State<DesktopMusicAggregatorListItem> {
  bool isHovered = false;
  Music? defaultMusic;

  late StreamSubscription<Music> musicInfoUpdateSubscription;

  @override
  void initState() {
    super.initState();
    defaultMusic = getMusicAggregatorDefaultMusic(widget.musicAgg);
    musicInfoUpdateSubscription =
        musicAggregatorUpdateStreamController.stream.listen((e) {
      if (defaultMusic?.identity == e.identity) {
        setState(() {
          defaultMusic = e;
        });
        var musicIndex =
            widget.musicAgg.musics.indexWhere((m) => m.server == e.server);
        if (musicIndex != -1) {
          widget.musicAgg.musics[musicIndex] = e;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    musicInfoUpdateSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.isDarkMode
        ? const Color.fromARGB(255, 44, 44, 44)
        : const Color.fromARGB(255, 244, 244, 244);

    Color hoverColor = widget.isDarkMode
        ? const Color.fromARGB(255, 54, 54, 54)
        : const Color.fromARGB(255, 232, 232, 232);

    if (defaultMusic == null) {
      return const SizedBox();
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap ??
            () {
              globalAudioHandler.addMusicPlay(MusicContainer(widget.musicAgg));
            },
        onSecondaryTapDown: (details) async {
          final Offset tapPosition = details.globalPosition;
          final Rect position =
              Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
          await showMusicAggregatorMenu(
              context, widget.musicAgg, true, position,
              playlist: widget.playlist);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isHovered
                  ? hoverColor
                  : (widget.hasBackgroundColor
                      ? backgroundColor
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 10),
              child: TableRowWidget(
                children: [
                  MusicCell(
                    music: defaultMusic!,
                    isDarkMode: widget.isDarkMode,
                    cacheCover: widget.cacheCover,
                  ),
                  ArtistCell(
                      artists:
                          defaultMusic!.artists.map((e) => e.name).join(", "),
                      isDarkMode: widget.isDarkMode),
                  AlbumCell(
                      album: defaultMusic!.album ?? '',
                      isDarkMode: widget.isDarkMode),
                  DurationCell(
                      duration: defaultMusic!.duration,
                      isDarkMode: widget.isDarkMode),
                  OptionsCell(
                    musicAgg: widget.musicAgg,
                    isDarkMode: widget.isDarkMode,
                    onTapDown: (details) {
                      final Offset tapPosition = details.globalPosition;
                      final Rect position =
                          Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
                      showMusicAggregatorMenu(
                        context,
                        widget.musicAgg,
                        true,
                        position,
                        playlist: widget.playlist,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TableRowWidget extends StatelessWidget {
  final List<Widget> children;

  const TableRowWidget({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(0.5),
        4: FlexColumnWidth(0.5),
      },
      children: [
        TableRow(children: children),
      ],
    );
  }
}

class MusicCell extends StatelessWidget {
  final Music music;
  final bool isDarkMode;
  final bool cacheCover;

  const MusicCell({
    super.key,
    required this.music,
    required this.isDarkMode,
    required this.cacheCover,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ClipRRect(
        //   borderRadius: BorderRadius.circular(2.0),
        //   child: imageWithCache(music.getCover(size: 250),
        //       width: 40, height: 40, enableCache: cacheCover),
        // ),
        // const SizedBox(width: 8),
        Expanded(
            child: SizedBox(
          height: 40,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                music.name,
                style: TextStyle(
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ).useSystemChineseFont(),
                overflow: TextOverflow.ellipsis,
              )),
        )),
      ],
    );
  }
}

class ArtistCell extends StatelessWidget {
  final String artists;
  final bool isDarkMode;

  const ArtistCell({
    super.key,
    required this.isDarkMode,
    required this.artists,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      artists,
      style: TextStyle(
        color: isDarkMode
            ? CupertinoColors.systemGrey4
            : CupertinoColors.inactiveGray,
      ).useSystemChineseFont(),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class AlbumCell extends StatelessWidget {
  final String album;
  final bool isDarkMode;

  const AlbumCell({
    super.key,
    required this.isDarkMode,
    required this.album,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      album,
      style: TextStyle(
        color: isDarkMode
            ? CupertinoColors.systemGrey4
            : CupertinoColors.inactiveGray,
      ).useSystemChineseFont(),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class DurationCell extends StatelessWidget {
  final int? duration;
  final bool isDarkMode;

  const DurationCell({
    super.key,
    required this.duration,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      duration != null ? formatDuration(duration!) : "",
      style: TextStyle(
        color: isDarkMode
            ? CupertinoColors.systemGrey4
            : CupertinoColors.inactiveGray,
      ).useSystemChineseFont(),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class OptionsCell extends StatefulWidget {
  final bool isDarkMode;
  final MusicAggregator musicAgg;
  final void Function(TapDownDetails)? onTapDown;
  const OptionsCell({
    super.key,
    required this.isDarkMode,
    required this.musicAgg,
    this.onTapDown,
  });

  @override
  OptionsCellState createState() => OptionsCellState();
}

class OptionsCellState extends State<OptionsCell> {
  bool hasCache = false;
  late StreamSubscription<(bool, String)> cacheUpdateSubscription;

  @override
  void initState() {
    super.initState();
    hasCacheMusic(
            name: widget.musicAgg.name,
            artists: widget.musicAgg.artist,
            documentFolder: globalDocumentPath)
        .then((value) {
      if (mounted) {
        setState(() {
          hasCache = value;
        });
      }
    });

    cacheUpdateSubscription = musicAggregatorCacheController.stream.listen((e) {
      var (newHasCache, identity) = e;
      if (identity == widget.musicAgg.identity()) {
        setState(() {
          hasCache = newHasCache;
        });
      }
    });
  }

  @override
  void dispose() {
    cacheUpdateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        if (hasCache)
          Positioned(
            right: 32,
            child: Icon(
              CupertinoIcons.arrow_down_circle_fill,
              color: widget.isDarkMode
                  ? CupertinoColors.systemGrey4
                  : activeIconRed,
            ),
          ),
        GestureDetector(
          onTapDown: widget.onTapDown,
          child: Icon(
            CupertinoIcons.ellipsis,
            color:
                widget.isDarkMode ? CupertinoColors.systemGrey4 : activeIconRed,
          ),
        ),
      ],
    );
  }
}

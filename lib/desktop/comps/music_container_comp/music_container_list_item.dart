import 'dart:async';

import 'package:app_rhyme/pulldown_menus/music_container_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MusicContainerListHeaderRow extends StatelessWidget {
  const MusicContainerListHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor = isDarkMode
        ? CupertinoColors.systemGrey
        : const Color.fromARGB(255, 160, 160, 160);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
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

class MusicContainerListItem extends StatefulWidget {
  final MusicListW? musicListW;
  final MusicContainer musicContainer;
  final bool isDarkMode;
  final bool hasBackgroundColor;
  final void Function()? onTap;

  const MusicContainerListItem({
    super.key,
    required this.musicContainer,
    required this.isDarkMode,
    required this.hasBackgroundColor,
    this.onTap,
    this.musicListW,
  });

  @override
  _MusicContainerListItemState createState() => _MusicContainerListItemState();
}

class _MusicContainerListItemState extends State<MusicContainerListItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.isDarkMode
        ? const Color.fromARGB(255, 44, 44, 44)
        : const Color.fromARGB(255, 244, 244, 244);

    Color hoverColor = widget.isDarkMode
        ? const Color.fromARGB(255, 54, 54, 54)
        : const Color.fromARGB(255, 232, 232, 232);

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
              globalAudioHandler.addMusicPlay(widget.musicContainer);
            },
        onSecondaryTapDown: (details) async {
          final Offset tapPosition = details.globalPosition;
          final Rect position =
              Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
          List menuItems;
          if (widget.musicListW == null) {
            menuItems =
                onlineMusicContainerItems(context, widget.musicContainer, true);
          } else {
            bool hasCache = await widget.musicContainer.hasCache();
            if (context.mounted) {
              menuItems = localMusicContainerItems(context, widget.musicListW!,
                  widget.musicContainer, hasCache, true);
            } else {
              return;
            }
          }
          if (context.mounted) {
            showPullDownMenu(
                context: context,
                items: [
                  PullDownMenuHeader(
                    itemTheme: PullDownMenuItemTheme(
                        textStyle: const TextStyle().useSystemChineseFont()),
                    leading:
                        imageCacheHelper(widget.musicContainer.info.artPic),
                    title: widget.musicContainer.info.name,
                    subtitle: widget.musicContainer.info.artist.join(", "),
                  ),
                  const PullDownMenuDivider.large(),
                  ...menuItems,
                ],
                position: position);
          }
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
                      musicContainer: widget.musicContainer,
                      isDarkMode: widget.isDarkMode),
                  ArtistCell(
                      musicContainer: widget.musicContainer,
                      isDarkMode: widget.isDarkMode),
                  AlbumCell(
                      musicContainer: widget.musicContainer,
                      isDarkMode: widget.isDarkMode),
                  DurationCell(
                      musicContainer: widget.musicContainer,
                      isDarkMode: widget.isDarkMode),
                  OptionsCell(
                    musicContainer: widget.musicContainer,
                    isDarkMode: widget.isDarkMode,
                    onTapDown: (details) {
                      final Offset tapPosition = details.globalPosition;
                      final Rect position =
                          Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 0, 0);
                      showMusicContainerMenu(
                        context,
                        widget.musicContainer,
                        true,
                        position,
                        musicList: widget.musicListW,
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
  final MusicContainer musicContainer;
  final bool isDarkMode;

  const MusicCell({
    super.key,
    required this.musicContainer,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2.0),
          child: imageCacheHelper(
            musicContainer.info.artPic,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            cacheNow: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            musicContainer.info.name,
            style: TextStyle(
              color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ).useSystemChineseFont(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ArtistCell extends StatelessWidget {
  final MusicContainer musicContainer;
  final bool isDarkMode;

  const ArtistCell({
    super.key,
    required this.musicContainer,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      musicContainer.info.artist.join(", "),
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
  final MusicContainer musicContainer;
  final bool isDarkMode;

  const AlbumCell({
    super.key,
    required this.musicContainer,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      musicContainer.info.album ?? '未知专辑',
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
  final MusicContainer musicContainer;
  final bool isDarkMode;

  const DurationCell({
    super.key,
    required this.musicContainer,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (musicContainer.info.duration == null) {
      return const SizedBox();
    }
    return Text(
      formatDuration(musicContainer.info.duration!),
      style: TextStyle(
        color: isDarkMode
            ? CupertinoColors.systemGrey4
            : CupertinoColors.inactiveGray,
      ).useSystemChineseFont(),
      overflow: TextOverflow.ellipsis,
    );
  }
}

final StreamController<void> _cacheUpdateController =
    StreamController<void>.broadcast();

Stream<void> get cacheUpdateStream => _cacheUpdateController.stream;

void globalNotifyMusicContainerCacheUpdated() {
  _cacheUpdateController.add(null);
}

class OptionsCell extends StatefulWidget {
  final bool isDarkMode;
  final MusicContainer musicContainer;
  final void Function(TapDownDetails)? onTapDown;
  const OptionsCell({
    super.key,
    required this.isDarkMode,
    required this.musicContainer,
    this.onTapDown,
  });

  @override
  _OptionsCellState createState() => _OptionsCellState();
}

class _OptionsCellState extends State<OptionsCell> {
  bool hasCache = false;
  StreamSubscription<void>? _cacheUpdateSubscription;

  @override
  void initState() {
    super.initState();
    widget.musicContainer.hasCache().then((value) {
      if (mounted) {
        setState(() {
          hasCache = value;
        });
      }
    });

    _cacheUpdateSubscription = cacheUpdateStream.listen((_) {
      widget.musicContainer.hasCache().then((value) {
        if (mounted) {
          setState(() {
            hasCache = value;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _cacheUpdateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        if (hasCache)
          Positioned(
            right: 50,
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

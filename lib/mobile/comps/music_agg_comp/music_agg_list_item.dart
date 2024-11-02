import 'dart:async';
import 'package:app_rhyme/pulldown_menus/music_aggregator_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class MobileMusicAggregatorListItem extends StatefulWidget {
  final MusicAggregator musicAgg;
  final Playlist? playlist;
  final bool? isDark;
  final GestureTapCallback? onTap;
  final bool cacheCover;
  final bool showMenu;
  final int index;

  const MobileMusicAggregatorListItem({
    super.key,
    required this.musicAgg,
    this.playlist,
    this.isDark,
    this.onTap,
    this.cacheCover = false,
    this.showMenu = true,
    this.index = -1,
  });

  @override
  MobileMusicAggregatorListItemState createState() =>
      MobileMusicAggregatorListItemState();
}

class MobileMusicAggregatorListItemState
    extends State<MobileMusicAggregatorListItem> {
  Music? defaultMusic;
  bool _hasCache = false;
  late StreamSubscription<Music> subscription;

  @override
  void initState() {
    super.initState();
    defaultMusic = getMusicAggregatorDefaultMusic(widget.musicAgg);
    subscription = musicAggregatorUpdateStreamController.stream.listen((e) {
      if (defaultMusic?.identity == e.identity) {
        setState(() {
          defaultMusic = e;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  void _checkCache() async {
    if (defaultMusic == null) {
      return;
    }
    bool cacheStatus = await hasCacheMusic(
        name: widget.musicAgg.name,
        artists: widget.musicAgg.artist,
        documentFolder: globalDocumentPath);
    if (mounted) {
      setState(() {
        _hasCache = cacheStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultMusic == null) {
      return const SizedBox();
    }
    // 每次重绘时检查缓存状态
    _checkCache();
    // 获取当前主题的亮度
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = widget.isDark ?? (brightness == Brightness.dark);
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
      onPressed: widget.onTap ??
          () {
            globalAudioHandler.addMusicPlay(MusicContainer(widget.musicAgg));
          },
      child: Row(
        key: ValueKey("${_hasCache}_${widget.musicAgg.hashCode}"),
        children: <Widget>[
          // 歌曲的封面
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imageWithCache(defaultMusic!.getCover(size: 250),
                width: 40, height: 40, enableCache: widget.cacheCover),
          ),
          // 歌曲的信息(歌名, 歌手)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    defaultMusic!.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey5
                          : CupertinoColors.black,
                      overflow: TextOverflow.ellipsis,
                    ).useSystemChineseFont(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    defaultMusic!.artists.map((e) => e.name).join(", "),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey4
                          : CupertinoColors.inactiveGray,
                      overflow: TextOverflow.ellipsis,
                    ).useSystemChineseFont(),
                  ),
                ],
              ),
            ),
          ),
          // 缓存标志
          if (widget.playlist != null && widget.index == -1)
            _hasCache
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(CupertinoIcons.arrow_down_circle_fill,
                        color: CupertinoColors.systemGrey2))
                : const SizedBox.shrink(),
          if (widget.showMenu)
            GestureDetector(
              onTapDown: (details) {
                Rect position = Rect.fromPoints(
                  details.globalPosition,
                  details.globalPosition,
                );
                showMusicAggregatorMenu(
                  context,
                  widget.musicAgg,
                  false,
                  position,
                  playlist: widget.playlist,
                  index: widget.index,
                );
              },
              child: Icon(
                CupertinoIcons.ellipsis,
                color: activeIconRed,
              ),
            )
        ],
      ),
    );
  }
}

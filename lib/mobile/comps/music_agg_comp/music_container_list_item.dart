import 'package:app_rhyme/pulldown_menus/music_aggregator_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
// import 'package:app_rhyme/utils/source_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

// 有三种使用场景: 1. 本地歌单的歌曲 2. 在线的歌曲 3. 播放列表
// 区分:
// 1. 本地歌单的歌曲: musicListW != null && index == -1
// 2. 在线的歌曲: musicListW == null && index == -1
// 3. 播放列表的歌曲: musicListW == null && index != -1

class MobileMusicAggregatorListItem extends StatefulWidget {
  final MusicAggregator musicAgg;
  final Playlist? playlist;
  final bool? isDark;
  final GestureTapCallback? onTap;
  final bool cachePic;
  final bool showMenu;
  final int index;

  const MobileMusicAggregatorListItem({
    super.key,
    required this.musicAgg,
    this.playlist,
    this.isDark,
    this.onTap,
    this.cachePic = false,
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

  @override
  void initState() {
    super.initState();
    defaultMusic = getMusicAggregatorDefaultMusic(widget.musicAgg);
  }

  void _checkCache() async {
    if (defaultMusic == null) {
      return;
    }
    bool cacheStatus = await hasCacheMusic(
        music: defaultMusic!, documentFolder: globalDocumentPath);
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
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                cacheNow: widget.cachePic),
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
          // 具有误导性，暂时不显示
          // // 标志音乐信息来源的Badge
          // Badge(
          //   label: sourceToShort(widget.musicContainer.info.source),
          // ),
          // 歌曲的操作按钮
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

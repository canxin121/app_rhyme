import 'package:app_rhyme/comps/chores/badge.dart';
import 'package:app_rhyme/comps/music_container_comp/music_container_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:flutter/cupertino.dart';

// 有三种使用场景: 1. 本地歌单的歌曲 2. 在线的歌曲 3. 播放列表
// 区分:
// 1. 本地歌单的歌曲: musicListW != null && inPlayList == false
// 2. 在线的歌曲: musicListW == null && inPlayList == false
// 3. 播放列表的歌曲: musicListW == null && inPlayList == true

class MusicContainerListItem extends StatelessWidget {
  final MusicContainer musicContainer;
  final MusicListW? musicListW;
  final bool inPlayList;
  final bool? isDark;
  final GestureTapCallback? onTap;
  final bool cachePic;

  const MusicContainerListItem(
      {super.key,
      required this.musicContainer,
      this.musicListW,
      this.inPlayList = false,
      this.isDark,
      this.onTap,
      this.cachePic = false});

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的亮度
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = isDark ?? (brightness == Brightness.dark);

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
      onPressed: onTap ??
          () {
            globalAudioHandler.addMusicPlay(musicContainer);
          },
      child: Row(
        children: <Widget>[
          // 歌曲的封面
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: imageCacheHelper(musicContainer.info.artPic,
                width: 50, height: 50, fit: BoxFit.cover, cacheNow: cachePic),
          ),
          // 歌曲的信息(歌名, 歌手)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    musicContainer.info.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey5
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    musicContainer.info.artist.join(", "),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey4
                          : CupertinoColors.inactiveGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 缓存标志
          if (musicListW != null && !inPlayList && musicContainer.hasCache())
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Badge(
                label: '缓存',
              ),
            ),
          // 标志音乐信息来源的Badge
          Badge(
            label: sourceToShort(musicContainer.info.source),
          ),
          // 歌曲的操作按钮
          MusicContainerMenu(
            musicContainer: musicContainer,
            musicListW: musicListW,
            inPlayList: inPlayList,
            builder: (_, showMenu) => CupertinoButton(
              onPressed: showMenu,
              padding: EdgeInsets.zero,
              child: Icon(
                CupertinoIcons.ellipsis,
                color: isDarkMode ? CupertinoColors.white : activeIconRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

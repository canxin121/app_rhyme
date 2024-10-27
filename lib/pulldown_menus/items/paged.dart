import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 加载所有歌曲
PullDownMenuItem loadAllMusicAggregatorsMenuItem(
    BuildContext context, Future<void> Function() fetchAllMusicAggregators) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      await fetchAllMusicAggregators();
    },
    title: "加载所有歌曲",
    icon: CupertinoIcons.music_note_2,
  );
}

/// 加载所有歌单
PullDownMenuItem loadAllPlaylistsMenuItem(
    BuildContext context, Future<void> Function() fetchAllPlaylists) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      await fetchAllPlaylists();
    },
    title: "加载所有歌单",
    icon: CupertinoIcons.music_albums,
  );
}

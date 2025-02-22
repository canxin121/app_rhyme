import 'package:app_rhyme/common_comps/dialogs/music_dialog.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

/// 移出播放列表
PullDownMenuItem removeMusicAggFromPlaylistPullDownItem(int index) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () async {
      try {
        globalAudioHandler.removeAt(index);
      } catch (e) {
        LogToast.error("移出播放列表", "移出播放列表失败",
            "[removeMusicAggFromPlaylistPullDownItem] failed to remove music from playlist: $e");
      }
    },
    title: '移出播放列表',
    icon: CupertinoIcons.delete,
  );
}

/// 保存到歌单
PullDownMenuItem addMusicToPlaylistPullDownItem(
    BuildContext context, MusicAggregator musicAgg) {
  return PullDownMenuItem(
    itemTheme:
        PullDownMenuItemTheme(textStyle: TextStyle().useSystemChineseFont()),
    onTap: () => addMusicsToPlayList(context, [musicAgg]),
    title: '保存到歌单',
    icon: CupertinoIcons.add_circled,
  );
}

/// 创建新歌单
PullDownMenuItem createNewPlaylistFromMusicAggPullDownItem(
    BuildContext context, MusicAggregator musicAgg) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => createPlaylistFromMusics(context, [musicAgg]),
    title: '创建新歌单',
    icon: CupertinoIcons.add_circled,
  );
}

/// 查看详情 or 编辑信息
PullDownMenuItem showOrEditMusicAggPullDownItem(
  BuildContext context,
  Music music,
) {
  bool readOnly = !music.fromDb;
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      if (readOnly) {
        showMusicInfoDialog(context,
            defaultMusicInfo: music, readonly: readOnly);
      } else {
        editMusicToDb(context, music);
      }
    },
    title: readOnly ? '查看详情' : "编辑信息",
    icon: CupertinoIcons.photo,
  );
}

/// 查看专辑
PullDownMenuItem viewMusicAlbumPullDownItem(
    BuildContext context, Music music, bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => viewMusicAlbum(context, music, isDesktop),
    title: '查看专辑',
    icon: CupertinoIcons.music_albums,
  );
}

/// 从歌单删除
PullDownMenuItem deleteMusicAggFromDbPlaylistPullDownItem(
    BuildContext context, MusicAggregator musicAgg, Playlist playlist) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => deleteMusicAggsFromDbPlaylist([musicAgg], playlist),
    title: '从歌单删除',
    icon: CupertinoIcons.delete,
  );
}

/// 缓存歌曲 or 删除缓存
PullDownMenuItem musicCachePullDownItem(
    MusicAggregator musicAgg, bool hasCache) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () {
      if (hasCache) {
        delMusicCache(musicAgg);
      } else {
        cacheMusicContainer(MusicContainer(musicAgg));
      }
    },
    title: hasCache ? '删除缓存' : '缓存歌曲',
    icon: hasCache ? CupertinoIcons.delete : CupertinoIcons.cloud_download,
  );
}

/// 查看歌手专辑
PullDownMenuItem viewArtistAlbumPullDownItem(
    BuildContext context, Music music, bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => viewArtistAlbums(context, music, isDesktop),
    title: '查看歌手专辑',
    icon: CupertinoIcons.music_albums,
  );
}

/// 查看歌手单曲
PullDownMenuItem viewArtistMusicAggregatorsPullDownItem(
    BuildContext context, Music music, bool isDesktop) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => viewArtistMusicAggregators(context, music, isDesktop),
    title: '查看歌手单曲',
    icon: CupertinoIcons.music_note,
  );
}

/// 导出歌曲Json
PullDownMenuItem exportMusicAggregatorsJsonPullDownItem(
    BuildContext context, MusicAggregator musicAggregator) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => exportMusicAggregatorsJson(context, [musicAggregator]),
    title: '导出歌曲Json',
    icon: CupertinoIcons.square_arrow_down,
  );
}

/// 设为歌单封面
PullDownMenuItem setMusicCoverAsPlaylistCoverPullDownItem(
    Playlist playlist, Music music) {
  return PullDownMenuItem(
    itemTheme: PullDownMenuItemTheme(
        textStyle: const TextStyle().useSystemChineseFont()),
    onTap: () => setMusicCoverAsPlaylistCover(music, playlist),
    title: '设为歌单封面',
    icon: CupertinoIcons.photo,
  );
}

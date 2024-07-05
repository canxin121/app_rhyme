// Helper functions for actions

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/dialogs/music_container_dialog.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/pages/local_music_list_grid_page.dart';
import 'package:app_rhyme/pages/local_music_list_page.dart';
import 'package:app_rhyme/pages/online_music_list_page.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:toastification/toastification.dart';

Future<void> deleteFromMusicList(BuildContext context,
    MusicContainer musicContainer, MusicListW musicListW) async {
  try {
    await SqlFactoryW.delMusics(
        musicListName: musicListW.getMusiclistInfo().name,
        ids: Int64List.fromList([musicContainer.info.id]));
    await globalMusicContainerListPageRefreshFunction();
  } catch (e) {
    toastification.show(
      type: ToastificationType.error,
      title: Text("删除失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("删除音乐失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> deleteMusicCache(MusicContainer musicContainer) async {
  try {
    if (!musicContainer.hasCache()) return;
    await deleteCacheFile(
        file: "",
        cachePath: musicCacheRoot,
        filename: musicContainer.toCacheFileName());
    await globalMusicContainerListPageRefreshFunction();
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
      title: Text("删除成功", style: const TextStyle().useSystemChineseFont()),
      description: Text("成功删除: ${musicContainer.info.name}",
          style: const TextStyle().useSystemChineseFont()),
    );
  } catch (e) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("删除失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("删除音乐失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> cacheMusic(MusicContainer musicContainer) async {
  try {
    var success = await musicContainer.updateAll();
    if (!success) {
      return;
    }
    var playinfo = musicContainer.playInfo;
    await cacheFile(
        file: playinfo!.uri,
        cachePath: musicCacheRoot,
        filename: musicContainer.toCacheFileName());
    await globalMusicContainerListPageRefreshFunction();
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
      title: Text("缓存成功", style: const TextStyle().useSystemChineseFont()),
      description: Text("成功缓存: ${musicContainer.info.name}",
          style: const TextStyle().useSystemChineseFont()),
    );
  } catch (e) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("缓存失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("缓存音乐失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> editMusicInfo(
    BuildContext context, MusicContainer musicContainer) async {
  try {
    var musicInfo = await showMusicInfoDialog(context,
        defaultMusicInfo: musicContainer.info);
    if (musicInfo == null) {
      return;
    }
    await SqlFactoryW.changeMusicInfo(
        musics: [musicContainer.currentMusic], newInfos: [musicInfo]);
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
      title: Text("编辑成功", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("编辑音乐信息成功", style: const TextStyle().useSystemChineseFont()),
    );
    await globalMusicContainerListPageRefreshFunction();
  } catch (e) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("编辑失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("编辑音乐信息失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> viewAlbum(
    BuildContext context, MusicContainer musicContainer) async {
  try {
    var result =
        await musicContainer.currentMusic.fetchAlbum(page: 1, limit: 30);
    var musicList = result.$1;
    var aggs = result.$2;
    if (context.mounted) {
      Navigator.of(context).push(
        CupertinoPageRoute(
            builder: (context) => OnlineMusicListPage(
                  musicList: musicList,
                  firstPageMusicAggregators: aggs,
                )),
      );
    }
  } catch (e) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("查看专辑失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("查看专辑失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> addToMusicList(
    BuildContext context, MusicContainer musicContainer) async {
  var targetMusicList = await showMusicListSelectionDialog(context);
  if (targetMusicList != null) {
    try {
      await SqlFactoryW.addMusics(
          musicsListName: targetMusicList.getMusiclistInfo().name,
          musics: [musicContainer.aggregator]);
      await globalMusicContainerListPageRefreshFunction();

      toastification.show(
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.success,
        title: Text("添加成功", style: const TextStyle().useSystemChineseFont()),
        description: Text(
            "成功添加'${musicContainer.info.name}'到: ${targetMusicList.getMusiclistInfo().name}"),
      );
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 2),
        type: ToastificationType.error,
        title: Text("添加失败", style: const TextStyle().useSystemChineseFont()),
        description:
            Text("添加音乐失败: $e", style: const TextStyle().useSystemChineseFont()),
      );
    }
  }
}

Future<void> createNewMusicList(
    BuildContext context, MusicContainer musicContainer) async {
  var newMusicListInfo = await showMusicListInfoDialog(context,
      defaultMusicList: MusicListInfo(
          id: 0,
          name: musicContainer.info.artist.join(","),
          artPic: musicContainer.info.artPic ?? "",
          desc: ""));
  if (newMusicListInfo == null) {
    return;
  }
  try {
    await SqlFactoryW.createMusiclist(musicListInfos: [newMusicListInfo]);
    await SqlFactoryW.addMusics(
        musicsListName: newMusicListInfo.name,
        musics: [musicContainer.aggregator]);
    globalMusicListGridPageRefreshFunction();
    await globalMusicContainerListPageRefreshFunction();

    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
      title: Text("添加成功", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("成功添加'${musicContainer.info.name}'到新歌单${newMusicListInfo.name}"),
    );
  } catch (e) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("添加失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("添加音乐失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> setAsMusicListCover(
    MusicContainer musicContainer, MusicListW musicListW) async {
  var picLink = musicContainer.info.artPic;
  if (picLink == null || picLink.isEmpty) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("设置封面失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("歌曲没有封面", style: const TextStyle().useSystemChineseFont()),
    );
    return;
  }
  var oldMusicListInfo = musicListW.getMusiclistInfo();
  var newMusicListInfo = MusicListInfo(
    name: oldMusicListInfo.name,
    desc: oldMusicListInfo.desc,
    artPic: picLink,
    id: 0,
  );
  try {
    await SqlFactoryW.changeMusiclistInfo(
        old: [oldMusicListInfo], new_: [newMusicListInfo]);
    await globalMusicContainerListPageRefreshFunction();
    globalMusicListGridPageRefreshFunction();
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.success,
      title: Text("设置封面成功", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("成功设置为封面", style: const TextStyle().useSystemChineseFont()),
    );
  } catch (e) {
    toastification.show(
      autoCloseDuration: const Duration(seconds: 2),
      type: ToastificationType.error,
      title: Text("设置封面失败", style: const TextStyle().useSystemChineseFont()),
      description:
          Text("设置封面失败: $e", style: const TextStyle().useSystemChineseFont()),
    );
  }
}

Future<void> showDetailsDialog(
    BuildContext context, MusicContainer musicContainer) async {
  await showMusicInfoDialog(context, defaultMusicInfo: musicContainer.info);
}

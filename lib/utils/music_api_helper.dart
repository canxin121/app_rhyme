import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/dialogs/file_name_dialog.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/dialogs/wait_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart'
    as rust_api_music_cache;
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_api/wrapper.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/music_dialog.dart';
import 'package:app_rhyme/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/pick_file.dart';
import 'package:app_rhyme/utils/type_helper.dart';
import 'package:flutter/cupertino.dart';

Music? getMusicAggregatorDefaultMusic(MusicAggregator musicAggregator) {
  return musicAggregator.musics
      .where((e) => e.server == musicAggregator.defaultServer)
      .first;
}

Future<void> delMusicAggregatorCache(MusicAggregator musicAggregator,
    {bool showToast = true, bool showToastWhenNoMsuicCache = false}) async {
  // 这个函数运行耗时短，连续使用时应showToast = false
  try {
    await rust_api_music_cache.deleteMusicCache(
        name: musicAggregator.name,
        artists: musicAggregator.artist,
        documentFolder: globalDocumentPath);

    musicAggregatorCacheController.add((false, musicAggregator.identity()));

    if (showToast) {
      LogToast.success("删除缓存成功", "成功删除缓存: ${musicAggregator.name}",
          "[deleteMusicCache] Successfully deleted cache: ${musicAggregator.name}");
    }
  } catch (e) {
    // 失败时总是要显示toast
    LogToast.error("删除缓存失败", "删除缓存'${musicAggregator.name}'失败: $e",
        "[deleteMusicCache] Failed to delete cache: $e");
  }
}

Future<void> cacheMusicContainer(MusicContainer musicContainer) async {
  try {
    var success = await musicContainer.updateAll();
    if (!success || musicContainer.playInfo == null) {
      return;
    }
    await rust_api_music_cache.cacheMusic(
        name: musicContainer.musicAggregator.name,
        artists: musicContainer.musicAggregator.artist,
        playinfo: musicContainer.playInfo!,
        lyric: musicContainer.lyric,
        documentFolder: globalDocumentPath);

    musicAggregatorCacheController
        .add((true, musicContainer.musicAggregator.identity()));

    LogToast.success("缓存成功", "成功缓存: ${musicContainer.musicAggregator.name}",
        "[cacheMusic] Successfully cached: ${musicContainer.musicAggregator.name}");
  } catch (e) {
    LogToast.error("缓存失败", "缓存'${musicContainer.musicAggregator.name}'失败: $e",
        "[cacheMusic] Failed to cache: $e");
  }
}

Future<Music?> editMusicInfoToDb(BuildContext context, Music music) async {
  try {
    var editedMusic =
        await showMusicInfoDialog(context, defaultMusicInfo: music);
    if (editedMusic == null) {
      return null;
    }
    var newMusic = await editedMusic.updateToDb();
    LogToast.success(
        "编辑成功", "编辑音乐信息成功", "[editMusicInfo] Successfully edited music info");
    musicAggregatorInfoUpdateStreamController.add(newMusic);
    return newMusic;
  } catch (e) {
    LogToast.error("编辑失败", "编辑音乐信息失败: $e",
        "[editMusicInfo] Failed to edit music info: $e");
  }
  return null;
}

Future<void> viewMusicAlbum(
    BuildContext context, Music music, bool isDesktop) async {
  try {
    var (album, musicAggs) = await music.getAlbum(page: 1, limit: 30);
    if (album == null) {
      LogToast.error(
          "查看专辑失败", "专辑为空", "[viewAlbum] Failed to view album: album is null");
      return;
    }
    if (context.mounted) {
      if (isDesktop) {
        globalSetNavItemSelected("");
        globalDesktopNavigatorToPage(
            OnlineMusicListPage(
              isDesktop: true,
              playlist: album,
              firstPageMusicAggregators: musicAggs,
            ),
            replace: false);
      } else {
        Navigator.of(context).push(
          CupertinoPageRoute(
              builder: (context) => OnlineMusicListPage(
                    playlist: album,
                    firstPageMusicAggregators: musicAggs,
                    isDesktop: false,
                  )),
        );
      }
    }
  } catch (e) {
    LogToast.error(
        "查看专辑失败", "查看专辑失败: $e", "[viewAlbum] Failed to view album: $e");
  }
}

Future<void> addMusicsToPlayList(
    BuildContext context, List<MusicAggregator> musicAggs,
    {Playlist? playlist}) async {
  Playlist? targetMusicList;

  if (playlist != null) {
    targetMusicList = playlist;
  } else {
    targetMusicList = (await showMusicListSelectionDialog(context));
  }

  if (targetMusicList != null) {
    try {
      await targetMusicList.addAggsToDb(musicAggs: musicAggs);
      musicAggregatorListUpdateStreamController
          .add(await targetMusicList.getMusicsFromDb());
      LogToast.success("添加成功", "成功添加音乐到: ${targetMusicList.name}",
          "[addToMusicList] Successfully added musics to: ${targetMusicList.name}");
    } catch (e) {
      LogToast.error(
          "添加失败", "添加音乐失败: $e", "[addToMusicList] Failed to add music: $e");
    }
  }
}

// 从一些音乐中创建一个新的歌单
Future<void> createNewMusicListFromMusics(
    BuildContext context, List<MusicAggregator> musicAggs) async {
  if (musicAggs.isEmpty) {
    return;
  }
  var defaultMusicOfFirstAgg = getMusicAggregatorDefaultMusic(musicAggs.first);
  if (!context.mounted) return;
  // ignore: use_build_context_synchronously
  var newPlaylist = await showPlaylistInfoDialog(context,
      defaultPlaylist: await Playlist.newInstance(
        name: defaultMusicOfFirstAgg?.artists.first.name ?? "",
        cover: defaultMusicOfFirstAgg?.cover ?? "",
        subscriptions: [],
      ));

  // 用户取消
  if (newPlaylist == null) {
    return;
  }

  // 保存新歌单的图片
  if (newPlaylist.cover != null || newPlaylist.cover!.isNotEmpty) {
    cacheFileFromUriWrapper(newPlaylist.cover!, picCacheFolder);
  }

  // 创建新歌单，插入音乐
  try {
    int identity = await newPlaylist.insertToDb();
    Playlist? createdPlaylist = await Playlist.findInDb(id: identity);
    if (createdPlaylist == null) {
      throw "未找到新建的歌单";
    }
    Playlist.getFromDb().then((e) => playlistGridUpdateStreamController.add(e));
    if (context.mounted) {
      LogToast.success("创建成功", "成功创建新歌单: ${createdPlaylist.name}, 正在添加音乐",
          "[createNewMusicList] Successfully created new music list: ${createdPlaylist.name}, adding musics");
      await addMusicsToPlayList(context, musicAggs, playlist: createdPlaylist);
      createdPlaylist
          .getMusicsFromDb()
          .then((e) => musicAggregatorListUpdateStreamController.add(e));
    } else {
      await createdPlaylist.delFromDb();
      Playlist.getFromDb()
          .then((e) => playlistGridUpdateStreamController.add(e));
      LogToast.error("创建失败", "创建歌单失败: context is not mounted",
          "[createNewMusicList] Failed to create music list: context is not mounted");
    }
  } catch (e) {
    LogToast.error("创建失败", "创建歌单失败: $e",
        "[createNewMusicList] Failed to create music list: $e");
  }
}

Future<void> setMusicCoverAsPlaylistCover(
    Music music, Playlist playlist) async {
  var picLink = music.cover;
  if (picLink == null || picLink.isEmpty) {
    LogToast.error("设置封面失败", "歌曲没有封面",
        "[setAsMusicListCover] Failed to set cover: music has no cover");
    return;
  }

  try {
    playlist.cover = picLink;
    playlist = await playlist.updateToDb();

    playlistUpdateStreamController.add(playlist);
    playlist
        .getMusicsFromDb()
        .then((e) => musicAggregatorListUpdateStreamController.add(e));

    LogToast.success(
        "设置封面成功", "成功设置为封面", "[setAsMusicListCover] Successfully set as cover");
  } catch (e) {
    LogToast.error("设置封面失败", "设置封面失败:   $e",
        "[setAsMusicListCover] Failed to set cover: $e");
  }
}

Future<void> saveMusicList(Playlist playlist, bool toastWhenSuccess) async {
  LogToast.info("保存歌单", "正在获取歌单'${playlist.name}'数据，请稍等",
      "[OnlineMusicListItemsPullDown] Start to save music list");
  try {
    var musicAggs = await playlist.fetchMusicsOnline(page: 1, limit: 2333);
    var playlistId = await playlist.insertToDb();
    var newPlaylist = await Playlist.findInDb(id: playlistId);
    if (newPlaylist == null) {
      throw "Failed to find playlist inserted in db";
    }

    await newPlaylist.addAggsToDb(musicAggs: musicAggs);
    Playlist.getFromDb().then((e) => playlistGridUpdateStreamController.add(e));

    if (!toastWhenSuccess) {
      LogToast.success("保存歌单", "保存'${playlist.name}'成功",
          "[OnlineMusicListItemsPullDown] Succeed to save music list '${playlist.name}'");
    }
  } catch (e) {
    LogToast.error("保存歌单", "保存'${playlist.name}'失败: $e",
        "[OnlineMusicListItemsPullDown] Failed to save music list '${playlist.name}': $e");
  }
}

Future<void> addAggsOfPlayListToTargetMusicList(
  Playlist from,
  Playlist to,
) async {
  LogToast.info("添加歌曲", "正在获取歌单'${from.name}'数据，请稍等",
      "[OnlineMusicListItemsPullDown] Start to add music");
  try {
    List<MusicAggregator> musicAggs;
    if (from.fromDb) {
      musicAggs = await from.getMusicsFromDb();
    } else {
      musicAggs = await from.fetchMusicsOnline(page: 1, limit: 2333);
    }

    to.addAggsToDb(musicAggs: musicAggs);

    to
        .getMusicsFromDb()
        .then((e) => musicAggregatorListUpdateStreamController.add(e));

    LogToast.success("添加歌曲", "添加歌单'${from.name}'中的歌曲到'${to.name}'成功",
        "[OnlineMusicListItemsPullDown] Succeed to add music from '${from.name}' to '${to.name}'");
  } catch (e) {
    LogToast.error("添加歌曲", "添加歌单'${from.name}'中的歌曲到'${to.name}'失败: $e",
        "[OnlineMusicListItemsPullDown] Failed to add music from '${from.name}' to '${to.name}': $e");
  }
}

Future<void> editPlaylistListInfo(
    BuildContext context, Playlist playlist) async {
  var newPlaylist = await showPlaylistInfoDialog(context,
      defaultPlaylist: playlist, readonly: false);
  if (newPlaylist != null) {
    try {
      playlist = await newPlaylist.updateToDb();
      playlistUpdateStreamController.add(playlist);
      Playlist.getFromDb()
          .then((e) => playlistGridUpdateStreamController.add(e));
      LogToast.success("编辑歌单", "编辑歌单成功",
          "[LocalMusicListItemsPullDown] Succeed to edit music list");
    } catch (e) {
      LogToast.error("编辑歌单", "编辑歌单失败: $e",
          "[LocalMusicListItemsPullDown] Failed to edit music list: $e");
    }
  }
}

Future<void> addAggsOfPlaylistsToTargetPlayList(
    List<Playlist> playlists, BuildContext context,
    {Playlist? targetPlaylist}) async {
  try {
    Playlist? finalTargetPlaylist =
        targetPlaylist ?? await showMusicListSelectionDialog(context);

    if (finalTargetPlaylist == null) return;

    for (var fromPlaylist in playlists) {
      await addAggsOfPlayListToTargetMusicList(
          fromPlaylist, finalTargetPlaylist);
    }

    LogToast.success("添加到目标歌单成功", "添加到目标歌单成功",
        "[MutiSelectOnlineMusicListGridPage] Successfully added to target music list");
  } catch (e) {
    LogToast.error("添加到目标歌单失败", "添加到目标歌单失败: $e",
        "[MutiSelectOnlineMusicListGridPage] Failed to add to target music list: $e");
  }
}

Future<void> savePlaylistsAsOneNewPlaylist(
    List<Playlist> playlists, BuildContext context) async {
  try {
    Playlist? targetPlayListInfo =
        await showPlaylistInfoDialog(context, defaultPlaylist: playlists.first);

    if (targetPlayListInfo == null) return;
    int newPlayListId = await targetPlayListInfo.insertToDb();
    Playlist? newPlaylist = await Playlist.findInDb(id: newPlayListId);

    if (newPlaylist == null) {
      LogToast.error("保存为新歌单失败", "创建新歌单失败： 未找到新歌单",
          "[MutiSelectOnlineMusicListGridPage] Failed to save as new music list");
      return;
    }
    Playlist.getFromDb().then((e) => playlistGridUpdateStreamController.add(e));

    for (var musicList in playlists) {
      await addAggsOfPlayListToTargetMusicList(musicList, newPlaylist);
    }

    LogToast.success("保存为新歌单", "保存为新建歌单成功",
        "[MutiSelectOnlineMusicListGridPage] Successfully saved as new music list");
  } catch (e) {
    LogToast.error("保存为新歌单失败", "保存为新建歌单失败: $e",
        "[MutiSelectOnlineMusicListGridPage] Failed to save as new music list: $e");
  }
}

Future<void> savePlaylists(
  List<Playlist> playlists,
) async {
  await Future.wait(playlists.map((musicList) async {
    await saveMusicList(musicList, false);
  }));
  LogToast.success("保存歌单", "保存所选歌单成功",
      "[MutliSelectLocalMusicListGridPage] Successfully saved music list");
}

Future<void> cacheMusicAggs(
    List<MusicAggregator> musicAggs, VoidCallback refresh) async {
  for (var musicContainer in musicAggs) {
    await cacheMusicContainer(MusicContainer(musicContainer));
  }
  refresh();
  LogToast.success("缓存选中音乐", "缓存选中音乐成功",
      "[cacheMusicAggs] succeed to cache music aggregators");
}

Future<void> deleteMusicAggsCache(
    List<MusicAggregator> musicAggs, VoidCallback refresh) async {
  for (var musicContainer in musicAggs) {
    await delMusicAggregatorCache(musicContainer, showToast: false);
  }
  refresh();
  LogToast.success("删除选中音乐缓存", "删除选中音乐缓存成功",
      "[handleDeleteCacheSelected] succeed to delete cache of selected music aggregators");
}

Future<void> deleteMusicAggsFromDbPlaylist(
  List<MusicAggregator> musicAggs,
  Playlist playlist,
) async {
  if (playlist.fromDb) {
    for (var musicAgg in musicAggs) {
      try {
        await playlist.delMusicAgg(musicAggIdentity: musicAgg.identity());
      } catch (e) {
        LogToast.error("删除失败", "删除音乐失败: $e",
            "[deleteMusicAggsFromDbPlaylist] Failed to delete music: $e");
      } finally {
        playlist
            .getMusicsFromDb()
            .then((e) => musicAggregatorListUpdateStreamController.add(e));
      }
    }
  }
}

Future<void> delDbPlaylist(
  Playlist playlist,
  bool inPlaylist,
  bool isDesktop,
  BuildContext context,
) async {
  try {
    await playlist.delFromDb();

    if (inPlaylist) {
      dbPlaylistPagePopStreamController.add(null);
    }

    LogToast.success("删除歌单", "删除歌单成功",
        "[LocalMusicListItemsPullDown] Succeed to delete music list");
    Playlist.getFromDb().then((e) => playlistGridUpdateStreamController.add(e));
  } catch (e) {
    LogToast.error("删除歌单", "删除歌单失败: $e",
        "[LocalMusicListItemsPullDown] Failed to delete music list: $e");
  }
}

Future<void> openSharePlaylist(BuildContext context, bool isDesktop) async {
  var url = await showInputPlaylistShareLinkDialog(context);
  if (url != null) {
    var musicListW = await Playlist.getFromShare(share: url);
    if (context.mounted) {
      if (isDesktop) {
        globalDesktopNavigatorToPage(
          OnlineMusicListPage(
            playlist: musicListW,
            isDesktop: isDesktop,
          ),
          replace: false,
        );
      } else {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => OnlineMusicListPage(
              playlist: musicListW,
              isDesktop: isDesktop,
            ),
          ),
        );
      }
    }
  }
}

Future<void> importDatabaseJson(BuildContext context, bool isDesktop,
    {MusicDataJsonWrapper? musicDataJson}) async {
  var confirm = await showConfirmationDialog(
      context,
      "注意!\n"
      "该功能可以将数据库Json文件导入数据库, 包含所有歌单和其中的歌曲\n"
      "这将会导致当前使用的数据库下的歌单数据完全丢失!!!\n"
      "请选择要导入的数据库Json文件, 请确保Json文件是从相同版本的AppRhyme中导出的\n"
      "是否继续?");
  if (confirm == null || !confirm) return;

  if (!context.mounted) return;
  await showWaitDialog(context, isDesktop, "正在应用数据库Json文件, 请稍等");

  try {
    if (musicDataJson == null) {
      String? filePath = await pickFile();
      if (filePath == null) {
        return;
      }
      musicDataJson = await MusicDataJsonWrapper.loadFrom(path: filePath);
    }

    var type = await musicDataJson.getType();

    if (type != MusicDataType.musicAggregators) {
      throw "错误的Json数据类型, 应导入'数据库'数据Json, 而非${musicDataTypeToString(type)}";
    }

    await musicDataJson.applyToDb();

    Playlist.getFromDb().then((e) => playlistGridUpdateStreamController.add(e));
    LogToast.success("导入数据库", "从Json文件导入数据库成功",
        "[importDatabaseJson] succeed to imprt json file to database");
  } catch (e) {
    LogToast.error("导入数据库", "Json导入失败: $e", "[importDatabaseJson] failed: $e");
  } finally {
    if (context.mounted) Navigator.of(context).pop();
  }
}

Future<void> importPlaylistJson(BuildContext context, bool isDesktop,
    {MusicDataJsonWrapper? musicDataJson}) async {
  try {
    if (musicDataJson == null) {
      String? filePath = await pickFile();
      if (filePath == null) {
        return;
      }
      musicDataJson = await MusicDataJsonWrapper.loadFrom(path: filePath);
    }

    var type = await musicDataJson.getType();
    if (type != MusicDataType.musicAggregators) {
      throw "错误的Json数据类型, 应导入'歌单'数据Json, 而非${musicDataTypeToString(type)}";
    }
    await musicDataJson.applyToDb();

    Playlist.getFromDb().then((e) => playlistGridUpdateStreamController.add(e));
    LogToast.success("导入歌单", "从Json文件导入歌单成功",
        "[importPlaylistJson] succeed to imprt json file to database");
  } catch (e) {
    LogToast.error("导入歌单", "Json导入失败: $e", "[importPlaylistJson] failed: $e");
  }
}

Future<void> importMusicAggrgegatorJson(BuildContext context, bool isDesktop,
    {MusicDataJsonWrapper? musicDataJson, Playlist? targetPlaylist}) async {
  targetPlaylist ??= await showMusicListSelectionDialog(context);
  if (targetPlaylist == null) return;

  try {
    if (musicDataJson == null) {
      String? filePath = await pickFile();
      if (filePath == null) {
        return;
      }
      musicDataJson = await MusicDataJsonWrapper.loadFrom(path: filePath);
    }
    var type = await musicDataJson.getType();
    if (type != MusicDataType.musicAggregators) {
      throw "错误的Json数据类型, 应导入'音乐'数据Json, 而非${musicDataTypeToString(type)}";
    }

    await musicDataJson.applyToDb(
        playlistId: int.parse(targetPlaylist.identity));
    targetPlaylist
        .getMusicsFromDb()
        .then((e) => musicAggregatorListUpdateStreamController.add(e));
    LogToast.success("导入歌曲", "从Json文件导入歌曲成功",
        "[importMusicAggrgegatorJson] succeed to imprt json file to database");
  } catch (e) {
    LogToast.error(
        "导入歌曲", "Json导入失败: $e", "[importMusicAggrgegatorJson] failed: $e");
  }
}

Future<void> exportMusicAggregatorsJson(
  BuildContext context,
  List<MusicAggregator> musicAggs,
) async {
  String? dir = await pickDirectory();
  if (dir == null) return;
  if (!context.mounted) return;
  String? fileName = await showFileNameDialog(context, "json",
      defaultFileName: "app_rhyme_musics");
  if (fileName == null) return;
  String filePath = "$dir/$fileName";

  try {
    LogToast.info("导出Json文件", "正在导出歌单'数据，请稍等",
        "[exportMusicAggregatorsJson] Start to export json file");

    MusicDataJsonWrapper musicDataJson =
        await MusicDataJsonWrapper.fromMusicAggregators(
            musicAggregators: musicAggs);

    await musicDataJson.saveTo(path: filePath);
    LogToast.success(
      "导出Json文件成功",
      "导出Json文件成功",
      "[exportMusicAggregatorsJson] Successfully exported json file",
    );
  } catch (e) {
    LogToast.error(
      "导出Json文件失败",
      "导出Json文件失败: $e",
      "[exportMusicAggregatorsJson] Failed to export json file: $e",
    );
  }
}

Future<void> exportPlaylistsJson(
    BuildContext context, List<Playlist> playlists) async {
  bool? confirm = await showConfirmationDialog(
      context, "本功能可以导出歌单为Json文件, 包括其中的所有歌曲\n请选择要保存的目录");
  if (confirm == null || !confirm) return;
  String? dir = await pickDirectory();
  if (dir == null) return;
  if (!context.mounted) return;
  String? fileName = await showFileNameDialog(context, "json",
      defaultFileName: "app_rhyme_playlists");
  if (fileName == null) return;
  String filePath = "$dir/$fileName";

  try {
    LogToast.info("导出Json文件", "正在导出歌单'数据，请稍等",
        "[exportPlaylistsJson] Start to export json file");

    MusicDataJsonWrapper musicDataJson =
        await MusicDataJsonWrapper.fromPlaylists(playlists: playlists);

    await musicDataJson.saveTo(path: filePath);
    LogToast.success(
      "导出Json文件成功",
      "导出Json文件成功",
      "[exportPlaylistsJson] Successfully exported json file",
    );
  } catch (e) {
    LogToast.error(
      "导出Json文件失败",
      "导出Json文件失败: $e",
      "[exportPlaylistsJson] Failed to export json file: $e",
    );
  }
}

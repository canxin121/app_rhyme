import 'dart:io';

import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:app_rhyme/common_pages/online_playlist_gridview_page.dart';
import 'package:app_rhyme/common_comps/dialogs/artist_select_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/confirm_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/file_name_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/playlist_collection_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/select_create_playlist_collection_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/wait_dialog.dart';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart'
    as rust_api_music_cache;
import 'package:app_rhyme/src/rust/api/log.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_api/wrapper.dart';
import 'package:app_rhyme/src/rust/api/utils/path_util.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:app_rhyme/common_comps/dialogs/music_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/playlist_dialog.dart';
import 'package:app_rhyme/common_comps/dialogs/select_create_playlist_dialog.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/navigate.dart';
import 'package:app_rhyme/utils/pick_file.dart';
import 'package:app_rhyme/utils/type_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// safe
Music? getMusicAggregatorDefaultMusic(MusicAggregator musicAggregator) {
  try {
    return musicAggregator.musics
        .where((e) => e.server == musicAggregator.defaultServer)
        .first;
  } catch (e) {
    LogToast.error("获取默认音乐失败", "获取默认音乐失败: $e",
        "[getMusicAggregatorDefaultMusic] Failed to get default music: $e");
  }
  return null;
}

const int fetchAllPageSize = 2333;
const int fetchOnePageSize = 30;

Future<void> fetchItemWithInputPagingController<T>({
  required TextEditingController inputController,
  required PagingController<int, T> pagingController,
  required Future<List<T>> Function(
          int page, int pageSize, String content, List<T> items)
      fetchFunction,
  required int pageKey,
  required String itemName,
  bool Function(PagingController<int, T> pagingController, int lastItemLen,
          List<T> newResult)?
      shouldEnd,
}) async {
  try {
    int lastItemLen = pagingController.itemList?.length ?? 0;

    if (inputController.value.text.isEmpty) {
      pagingController.appendLastPage([]);
      return;
    }

    var results = await fetchFunction(
      pageKey,
      fetchOnePageSize,
      inputController.value.text,
      pagingController.itemList ?? [],
    );
    if (shouldEnd != null) {
      if (shouldEnd(pagingController, lastItemLen, results)) {
        pagingController.appendLastPage(results);
      } else {
        pagingController.appendPage(results, pageKey + 1);
      }
    } else {
      if (results.isEmpty) {
        pagingController.appendLastPage([]);
      } else {
        pagingController.appendPage(results, pageKey + 1);
      }
    }
  } catch (error) {
    LogToast.error(
      "获取$itemName失败",
      "获取$itemName失败: $error",
      "[fetchItemWithInputPagingController] Failed to fetch $itemName: $error",
    );
    pagingController.appendLastPage([]);
  }
}

Future<void> fetchItemWithPagingController<T>({
  required PagingController<int, T> pagingController,
  required Future<List<T>> Function(int page, int pageSize, List<T> items)
      fetchFunction,
  required int pageKey,
  required String itemName,
}) async {
  try {
    var results = await fetchFunction(
        pageKey, fetchOnePageSize, pagingController.itemList ?? []);

    if (results.isEmpty) {
      pagingController.appendLastPage([]);
    } else {
      pagingController.appendPage(results, pageKey + 1);
    }
  } catch (error) {
    LogToast.error(
      "获取$itemName失败",
      "获取$itemName失败: $error",
      "[fetchItemWithPagingController] Failed to fetch $itemName: $error",
    );
    pagingController.appendLastPage([]);
  }
}

/// safe
Future<List<T>?> fetchAllItems<T>(
    Future<List<T>> Function(int page, int limit) fetchItems,
    String itemName) async {
  // LogToast.info("获取所有$itemName", "正在获取所有$itemName,请稍等",
  //     "[fetchAllItems] fetching all $itemName, please wait.");
  try {
    List<T> items = [];
    int page = 1;

    while (true) {
      var fetchedItems = await fetchItems(page, fetchAllPageSize);
      if (fetchedItems.isEmpty) {
        break;
      }
      items.addAll(fetchedItems);
      page++;
    }

    // LogToast.success("获取所有$itemName", "成功获取所有$itemName",
    //     "[fetchAllItems] Successfully fetched all items");
    return items;
  } catch (e) {
    LogToast.error(
        "获取数据失败", "获取数据失败: $e", "[fetchAllItems] Failed to fetch items: $e");
  }
  return null;
}

// safe
Future<List<T>?> fetchAllItemsWithPagingController<T>(
    {required Future<List<T>> Function(int page, int limit, List<T> items)
        fetchItems,
    required PagingController<int, T> pagingController,
    required String itemName,
    bool Function(PagingController<int, T> pagingController, int lastItemLen,
            List<T> newResult)?
        shouldEnd}) async {
  if (pagingController.nextPageKey == null) return null;
  LogToast.info("获取所有$itemName", "正在获取所有$itemName,请稍等",
      "[fetchAllItemsWithPagingController] fetching all $itemName, please wait.");
  try {
    var fetchedItems =
        await fetchItems(1, fetchAllPageSize, pagingController.itemList ?? []);

    pagingController.value = PagingState<int, T>(
        nextPageKey: 2, itemList: fetchedItems, error: null);

    while (pagingController.nextPageKey != null) {
      var fetchedItems = await fetchItems(pagingController.nextPageKey!,
          fetchAllPageSize, pagingController.itemList ?? []);

      if (shouldEnd != null) {
        if (shouldEnd(pagingController, pagingController.itemList!.length,
            fetchedItems)) {
          pagingController.appendLastPage(fetchedItems);
          break;
        }
      } else {
        if (fetchedItems.isEmpty) {
          pagingController.appendLastPage([]);
          break;
        }
      }

      pagingController.appendPage(
          fetchedItems, pagingController.nextPageKey! + 1);
    }

    LogToast.success("获取所有$itemName", "成功获取所有$itemName",
        "[fetchAllItemsWithPagingController] Successfully fetched all items");
    return pagingController.itemList;
  } catch (e) {
    LogToast.error("获取$itemName失败", "获取$itemName失败: $e",
        "[fetchAllItemsWithPagingController] Failed to fetch items: $e");
  }
  return null;
}

/// safe
Future<List<MusicAggregator>?> getOrFetchAllMusicAgrgegatorsFromPlaylist(
    Playlist playlist) async {
  if (playlist.fromDb) {
    return playlist.getMusicsFromDb();
  }

  return await fetchAllItems((int page, int limit) async {
    return await playlist.fetchMusicsOnline(page: page, limit: limit);
  }, "歌曲");
}

/// safe
/// 这个函数运行耗时短，连续使用时应showToast = false
Future<void> delMusicCache(
  MusicAggregator musicAggregator, {
  bool showToast = true,
}) async {
  if (!await rust_api_music_cache.hasCacheMusic(
      documentFolder: globalDocumentPath,
      customCacheRoot: globalConfig.storageConfig.customCacheRoot,
      name: musicAggregator.name,
      artists: musicAggregator.artist)) {
    return;
  }

  try {
    await rust_api_music_cache.deleteMusicCache(
        name: musicAggregator.name,
        artists: musicAggregator.artist,
        documentFolder: globalDocumentPath);

    musicAggregatorCacheController.add((false, musicAggregator.identity()));
  } catch (e) {
    // 失败时总是要显示toast
    LogToast.error("删除缓存失败", "删除缓存'${musicAggregator.name}'失败: $e",
        "[deleteMusicCache] Failed to delete cache: $e");
  }
}

/// safe
Future<void> deleteMusicsCache(
  List<MusicAggregator> musicAggs,
) async {
  await Future.wait(musicAggs.map((musicContainer) async {
    await delMusicCache(musicContainer, showToast: false);
  }));
}

/// safe
Future<void> cacheMusicContainer(MusicContainer musicContainer,
    {bool hasCache = false}) async {
  if (await rust_api_music_cache.hasCacheMusic(
      documentFolder: globalDocumentPath,
      customCacheRoot: globalConfig.storageConfig.customCacheRoot,
      name: musicContainer.musicAggregator.name,
      artists: musicContainer.musicAggregator.artist)) {
    return;
  }

  try {
    if (musicContainer.shouldUpdate()) {
      var success = await musicContainer.updateSelf();
      if (!success || musicContainer.playinfo == null) {
        return;
      }
    }
    await rust_api_music_cache.cacheMusic(
        name: musicContainer.musicAggregator.name,
        artists: musicContainer.musicAggregator.artist,
        playinfo: musicContainer.playinfo!,
        lyric: musicContainer.lyric,
        documentFolder: globalDocumentPath,
        customCacheRoot: globalConfig.storageConfig.customCacheRoot);

    musicAggregatorCacheController
        .add((true, musicContainer.musicAggregator.identity()));
  } catch (e) {
    LogToast.error("缓存失败", "缓存'${musicContainer.musicAggregator.name}'失败: $e",
        "[cacheMusic] Failed to cache: $e");
  }
}

/// safe
Future<void> cacheMusicAggs(List<MusicAggregator> musicAggs) async {
  await Future.wait(musicAggs.map((musicContainer) async {
    await cacheMusicContainer(MusicContainer(musicContainer));
  }));
}

/// safe
Future<Music?> editMusicToDb(BuildContext context, Music music) async {
  try {
    var editedMusic =
        await showMusicInfoDialog(context, defaultMusicInfo: music);
    if (editedMusic == null) {
      return null;
    }
    var newMusic = await editedMusic.updateToDb();
    LogToast.success(
        "编辑成功", "编辑音乐信息成功", "[editMusicInfo] Successfully edited music info");
    musicAggregatorUpdateStreamController.add(newMusic);
    return newMusic;
  } catch (e) {
    LogToast.error("编辑失败", "编辑音乐信息失败: $e",
        "[editMusicInfo] Failed to edit music info: $e");
  }
  return null;
}

/// safe
Future<void> editPlaylistListToDb(
    BuildContext context, Playlist playlist) async {
  var newPlaylist = await showPlaylistDialog(
    context,
    defaultPlaylist: playlist,
  );

  if (newPlaylist == null) return;

  try {
    playlist = await newPlaylist.updateToDb();
    playlistUpdateStreamController.add(playlist);
  } catch (e) {
    LogToast.error("编辑歌单", "编辑歌单失败: $e",
        "[LocalMusicListItemsPullDown] Failed to edit music list: $e");
  }
}

/// safe
Future<void> viewMusicAlbum(
    BuildContext context, Music music, bool isDesktop) async {
  try {
    var (album, musicAggs) = await music.getAlbum(page: 1, limit: 30);
    if (album == null) {
      LogToast.error(
          "查看专辑失败", "专辑为空", "[viewAlbum] Failed to view album: album is null");
      return;
    }
    if (!context.mounted) return;
    navigate(
        context,
        OnlineMusicAggregatorListViewPage(
          isDesktop: isDesktop,
          playlist: album,
          firstPageMusicAggregators: musicAggs,
        ),
        isDesktop,
        "");
  } catch (e) {
    LogToast.error(
        "查看专辑失败", "查看专辑失败: $e", "[viewAlbum] Failed to view album: $e");
  }
}

/// safe
Future<void> viewSharePlaylist(BuildContext context, bool isDesktop) async {
  var url = await showInputPlaylistShareLinkDialog(context);
  if (url == null) return;
  var musicListW = await Playlist.getFromShare(share: url);

  if (context.mounted) {
    navigate(
        context,
        OnlineMusicAggregatorListViewPage(
          playlist: musicListW,
          isDesktop: isDesktop,
        ),
        isDesktop,
        "");
  }
}

/// safe
Future<void> addMusicsToPlayList(
    BuildContext context, List<MusicAggregator> musicAggs,
    {PlaylistCollection? playlistCollection, Playlist? playlist}) async {
  if (playlist == null) {
    playlistCollection ??=
        await showSelectCreatePlaylistCollectionDialog(context);
    if (playlistCollection == null || !context.mounted) return;
    playlist ??=
        await showSelectCratePlaylistDialog(context, playlistCollection);
  }

  if (playlist == null) return;

  try {
    await playlist.addAggsToDb(musicAggs: musicAggs);
    musicAggrgatorsPageRefreshStreamController.add(playlist.identity);
  } catch (e) {
    LogToast.error(
        "添加失败", "添加音乐失败: $e", "[addToMusicList] Failed to add music: $e");
  }
}

/// safe
Future<Playlist?> insertPlaylistToDb(
    Playlist newPlaylist, int playlistCollectionId) async {
  try {
    int identity =
        await newPlaylist.insertToDb(collectionId: playlistCollectionId);
    Playlist? createdPlaylist = await Playlist.findInDb(id: identity);

    if (createdPlaylist != null) {
      playlistCreateStreamController
          .add((createdPlaylist, playlistCollectionId));
    }

    return createdPlaylist;
  } catch (e) {
    LogToast.error("创建歌单失败", "创建歌单失败: $e",
        "[insertPlaylistToDb] Failed to create music list: $e");
  }
  return null;
}

/// safe
Future<void> saveOnlinePlaylist(
  BuildContext context,
  Playlist playlist, {
  int? playlistCollectionId,
}) async {
  if (playlistCollectionId == null) {
    var playlistCollection =
        await showSelectCreatePlaylistCollectionDialog(context);
    if (playlistCollection == null) return;
    playlistCollectionId = playlistCollection.id;
  }
  var musics = await getOrFetchAllMusicAgrgegatorsFromPlaylist(playlist);
  if (!context.mounted || musics == null) return;
  var newPlaylist = await insertPlaylistToDb(playlist, playlistCollectionId);
  if (newPlaylist == null || !context.mounted) return;
  await addMusicsToPlayList(context, musics, playlist: newPlaylist);
}

/// safe
Future<void> saveOnlinePlaylists(
  BuildContext context,
  List<Playlist> playlists,
) async {
  var playlistCollection =
      await showSelectCreatePlaylistCollectionDialog(context);
  if (playlistCollection == null) return;

  await Future.wait(playlists.map((playlist) async {
    await saveOnlinePlaylist(
      context,
      playlist,
      playlistCollectionId: playlistCollection.id,
    );
  }));
}

/// safe
Future<Playlist?> createPlaylist(
  BuildContext context, {
  Playlist? playlist,
  PlaylistCollection? playlistCollection,
}) async {
  playlist ??= await showPlaylistDialog(context, defaultPlaylist: playlist);
  if (playlist == null || !context.mounted) return null;
  playlistCollection ??=
      await showSelectCreatePlaylistCollectionDialog(context);
  if (playlistCollection == null) return null;
  return insertPlaylistToDb(playlist, playlistCollection.id);
}

/// safe
Future<void> createPlaylistFromMusics(
    BuildContext context, List<MusicAggregator> musicAggs) async {
  if (musicAggs.isEmpty) {
    return;
  }
  var defaultMusicOfFirstAgg = getMusicAggregatorDefaultMusic(musicAggs.first);
  if (!context.mounted) return;
  // use the first music's artist name as default playlist name
  var defaultPlaylist = await Playlist.newInstance(
    name: defaultMusicOfFirstAgg?.artists.first.name ?? "",
    cover: defaultMusicOfFirstAgg?.cover ?? "",
    subscriptions: [],
  );
  if (!context.mounted) return;
  // let user edit playlist name
  var newPlaylist =
      await showPlaylistDialog(context, defaultPlaylist: defaultPlaylist);
  if (newPlaylist == null) return;
  if (!context.mounted) return;
  var playlistCollection =
      await showSelectCreatePlaylistCollectionDialog(context);
  if (playlistCollection == null) return;
  var createdPlaylist =
      await insertPlaylistToDb(newPlaylist, playlistCollection.id);
  if (!context.mounted || createdPlaylist == null) return;
  await addMusicsToPlayList(context, musicAggs, playlist: createdPlaylist);
}

/// safe
Future<void> setMusicCoverAsPlaylistCover(
    Music music, Playlist playlist) async {
  var picLink = music.cover;
  if (picLink == null || picLink.isEmpty) {
    LogToast.error("设置封面失败", "该歌曲没有封面",
        "[setAsMusicListCover] Failed to set cover: music has no cover");
    return;
  }

  try {
    playlist.cover = picLink;
    playlist = await playlist.updateToDb();

    playlistUpdateStreamController.add(playlist);

    LogToast.success(
        "设置封面成功", "成功设置为封面", "[setAsMusicListCover] Successfully set as cover");
  } catch (e) {
    LogToast.error("设置封面失败", "设置封面失败:   $e",
        "[setAsMusicListCover] Failed to set cover: $e");
  }
}

/// safe
Future<void> saveAggsOfPlayList(
  BuildContext context,
  Playlist from, {
  PlaylistCollection? toPlaylistCollection,
  Playlist? toPlaylist,
}) async {
  toPlaylistCollection ??=
      await showSelectCreatePlaylistCollectionDialog(context);
  if (toPlaylistCollection == null || !context.mounted) return;
  toPlaylist ??=
      await showSelectCratePlaylistDialog(context, toPlaylistCollection);
  if (toPlaylist == null) return;

  var musicAggs = await getOrFetchAllMusicAgrgegatorsFromPlaylist(from);
  if (musicAggs == null || !context.mounted) return;
  await addMusicsToPlayList(context, musicAggs,
      playlistCollection: toPlaylistCollection, playlist: toPlaylist);
}

/// safe
Future<void> saveAggsOfPlaylists(List<Playlist> playlists, BuildContext context,
    {PlaylistCollection? playlistCollection, Playlist? targetPlaylist}) async {
  playlistCollection ??=
      await showSelectCreatePlaylistCollectionDialog(context);
  if (playlistCollection == null || !context.mounted) return;
  targetPlaylist ??=
      await showSelectCratePlaylistDialog(context, playlistCollection);

  if (targetPlaylist == null || !context.mounted) return;

  await Future.wait(playlists.map((fromPlaylist) async {
    await saveAggsOfPlayList(context, fromPlaylist,
        toPlaylistCollection: playlistCollection, toPlaylist: targetPlaylist);
  }));

  LogToast.success(
      "保存成功", "成功保存歌曲", "[saveMusicList] Successfully saved music");
}

/// safe
Future<void> deleMusicFromPlaylist(
  MusicAggregator musicAgg,
  Playlist playlist,
) async {
  try {
    await playlist.delMusicAgg(musicAggIdentity: musicAgg.identity());
    musicAggregatorDeleteStreamController.add(musicAgg.identity());
  } catch (e) {
    LogToast.error("删除音乐", "删除音乐失败: $e",
        "[deleteMusicFromPlaylist] Failed to delete music: $e");
  }
}

/// safe
Future<void> deleteMusicAggsFromDbPlaylist(
  List<MusicAggregator> musicAggs,
  Playlist playlist,
) async {
  if (!playlist.fromDb) return;
  for (var musicAgg in musicAggs) {
    await deleMusicFromPlaylist(
      musicAgg,
      playlist,
    );
  }
}

/// safe
Future<void> delDbPlaylist(
  Playlist playlist,
  bool isDesktop,
  BuildContext context,
) async {
  if (!playlist.fromDb) return;
  try {
    await playlist.delFromDb();
    dbPlaylistPagePopStreamController.add(int.parse(playlist.identity));
    playlistDeleteStreamController.add(playlist.identity);
  } catch (e) {
    LogToast.error("删除歌单", "删除歌单失败: $e",
        "[LocalMusicListItemsPullDown] Failed to delete music list: $e");
  }
}

/// safe
Future<PlaylistCollection?> createPlaylistCollection(BuildContext context,
    {PlaylistCollection? playlistCollection}) async {
  playlistCollection ??= await showPlaylistCollectionDialog(context);
  if (playlistCollection == null) return null;
  try {
    int id = await playlistCollection.insertToDb();
    var createdPlaylistCollection = await PlaylistCollection.findInDb(id: id);
    playlistCollectionCreateStreamController.add(createdPlaylistCollection);
    return createdPlaylistCollection;
  } catch (e) {
    LogToast.error("创建歌单列表", "创建歌单列表失败: $e",
        "[createPlaylistCollection] Failed to create music list: $e");
  }
  return null;
}

/// safe
Future<void> importDatabaseJson(BuildContext context, bool isDesktop,
    {MusicDataJsonWrapper? musicDataJson}) async {
  var confirm = await showConfirmationDialog(
      context,
      "注意!\n"
      "该功能可以将数据库Json文件导入数据库, 包含所有歌单和其中的歌曲\n"
      "这将会导致当前使用的数据库下的歌单数据完全丢失!!!\n"
      "请选择要导入的数据库Json文件, 请确保Json文件是从相同版本的AppRhyme中导出的\n"
      "是否继续?");
  if (!context.mounted || confirm == null || !confirm) return;

  await showWaitDialog(context, isDesktop, "正在应用数据库Json文件, 请稍等");

  try {
    if (musicDataJson == null) {
      String? filePath = await pickFile();
      if (filePath == null) return;
      musicDataJson = await MusicDataJsonWrapper.loadFrom(path: filePath);
    }
    var type = await musicDataJson.getType();
    if (type != MusicDataType.database) {
      throw "错误的Json数据类型, 应导入'数据库'数据Json, 而非${musicDataTypeToString(type)}";
    }
    await musicDataJson.applyToDb();
    playlistCollectionsPageRefreshStreamController.add(null);
  } catch (e) {
    LogToast.error("导入数据库", "Json导入失败: $e", "[importDatabaseJson] failed: $e");
  }

  if (context.mounted) Navigator.of(context).pop();
}

/// safe
Future<void> importPlaylistJson(BuildContext context,
    {MusicDataJsonWrapper? musicDataJson,
    PlaylistCollection? playlistCollection}) async {
  try {
    if (musicDataJson == null) {
      String? filePath = await pickFile();
      if (filePath == null) return;
      musicDataJson = await MusicDataJsonWrapper.loadFrom(path: filePath);
    }

    var type = await musicDataJson.getType();
    if (type != MusicDataType.playlists) {
      throw "错误的Json数据类型, 应导入'歌单'数据Json, 而非${musicDataTypeToString(type)}";
    }
    if (!context.mounted) return;
    playlistCollection ??=
        await showSelectCreatePlaylistCollectionDialog(context);
    if (playlistCollection == null) return;
    await musicDataJson.applyToDb(playlistCollectionId: playlistCollection.id);
    playlistsPageRefreshStreamController.add(playlistCollection.id);
    playlistCollectionsPageRefreshStreamController.add(null);
  } catch (e) {
    LogToast.error("导入歌单", "Json导入失败: $e", "[importPlaylistJson] failed: $e");
  }
}

/// safe
Future<void> importMusicAggrgegatorJson(BuildContext context,
    {MusicDataJsonWrapper? musicDataJson,
    PlaylistCollection? playlistCollection,
    Playlist? targetPlaylist}) async {
  if (targetPlaylist == null) {
    playlistCollection ??=
        await showSelectCreatePlaylistCollectionDialog(context);
    if (playlistCollection == null || !context.mounted) return;
    targetPlaylist ??=
        await showSelectCratePlaylistDialog(context, playlistCollection);
  }

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
    musicAggrgatorsPageRefreshStreamController.add(targetPlaylist.identity);
  } catch (e) {
    LogToast.error(
        "导入歌曲", "Json导入失败: $e", "[importMusicAggrgegatorJson] failed: $e");
  }
}

/// safe
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
    MusicDataJsonWrapper musicDataJson =
        await MusicDataJsonWrapper.fromMusicAggregators(
            musicAggregators: musicAggs);

    await musicDataJson.saveTo(path: filePath);

    LogToast.success("导出Json文件", "导出歌曲成功",
        "[exportMusicAggregatorsJson] Successfully exported musicAggregators json file");
  } catch (e) {
    LogToast.error(
      "导出Json文件",
      "导出Json文件失败: $e",
      "[exportMusicAggregatorsJson] Failed to export musicAggregators json file: $e",
    );
  }
}

/// safe
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

Future<void> viewArtistMusicAggregators(
    BuildContext context, Music music, bool isDesktop) async {
  Artist? artist;
  if (music.artists.length == 1) {
    artist = music.artists.first;
  } else {
    artist = await showArtistSelectDialog(context, music.artists);
  }
  if (artist == null || artist.id == null || !context.mounted) return;

  navigate(
      context,
      OnlineMusicAggregatorListViewPage(
          title: artist.name,
          isDesktop: isDesktop,
          fetchMusicAggregators: (int page, int limit) async {
            return await MusicAggregator.fetchArtistMusicAggregators(
                server: music.server,
                artistId: artist!.id!,
                page: page,
                limit: limit);
          }),
      isDesktop,
      "");
}

Future<void> viewArtistAlbums(
    BuildContext context, Music music, bool isDesktop) async {
  Artist? artist;
  if (music.artists.length == 1) {
    artist = music.artists.first;
  } else {
    artist = await showArtistSelectDialog(context, music.artists);
  }
  if (artist == null || artist.id == null || !context.mounted) return;

  navigate(
      context,
      OnlinePlaylistGridViewPage(
        title: artist.name,
        isDesktop: isDesktop,
        fetchPlaylists: (int page, int limit, List<Playlist> playlists) async {
          return await Playlist.fetchArtistAlbums(
              server: music.server,
              artistId: artist!.id!,
              page: page,
              limit: limit);
        },
      ),
      isDesktop,
      "");
}

/// safe
Future<void> exportLogCompressed(BuildContext context) async {
  String? outputDir;

  if (Platform.isIOS) {
    bool? confirm = await showConfirmationDialog(
        context, "本功能可以导出日志文件为压缩文件\n在ios上, 只能保存目录到本软件的目录");
    if (confirm != true || !context.mounted) return;
    outputDir = await getApprhymeDir(documentDir: globalDocumentPath);
  } else {
    bool? confirm =
        await showConfirmationDialog(context, "本功能可以导出日志文件为压缩文件\n请选择要保存日志的目录");
    if (confirm != true || !context.mounted) return;
    outputDir = await pickDirectory();
    if (outputDir == null) return;
  }

  try {
    LogToast.info("导出日志", "正在导出日志, 请稍后",
        "[exportLogCompressed] Start to export log file");

    await saveLog(documentDir: globalDocumentPath, outputDir: outputDir);

    LogToast.success("导出日志", "导出日志成功",
        "[exportLogCompressed] Successfully exported log file");
  } catch (e) {
    LogToast.error("导出日志", "导出日志失败: $e",
        "[exportLogCompressed] Failed to export log file: $e");
  }
}

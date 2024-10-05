import 'dart:io';

import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/src/rust/api/types/playinfo.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:audio_service/audio_service.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:just_audio/just_audio.dart';

class MusicContainer {
  late MusicAggregator musicAggregator;
  late int currentMusicIndex;
  late AudioSource audioSource;

  PlayInfo? playinfo;
  String? lyric;
  List<MusicServer> usedServers = [];
  DateTime lastUpdateDateTime = DateTime(1999);

  MusicContainer(MusicAggregator musicAgg) {
    musicAggregator = musicAgg;
    currentMusicIndex = 0;
    audioSource = AudioSource.asset("assets/blank.mp3", tag: _toMediaItem());
  }

  Music get currentMusic => musicAggregator.musics[currentMusicIndex];

  /// safe
  void setUpdated() {
    lastUpdateDateTime = DateTime.now();
  }

  /// safe
  setOutdate() {
    lastUpdateDateTime = DateTime(1999);
  }

  /// safe
  bool shouldUpdate() {
    try {
      return (audioSource as ProgressiveAudioSource)
              .uri
              .path
              .contains("/assets/") ||
          DateTime.now().difference(lastUpdateDateTime).abs().inSeconds >= 1800;
    } catch (_) {
      return true;
    }
  }

  /// safe
  Future<bool> updateAll([Quality? quality]) async {
    await getUpdatePlayAndLyricInfoAutoChangeSource(quality);
    await _updateAudioSource();
    return playinfo != null;
  }

  /// safe
  Future<PlayInfo?> getUpdatePlayAndLyricInfoAutoChangeSource(
      [Quality? quality]) async {
    while (true) {
      var newPlayinfo = await getUpdatePlayInfoAndLyric(quality);
      // playInfo ??= await getUpdatePlayInfoAndLyric(quality);
      playinfo = newPlayinfo;
      if (playinfo != null) {
        return playinfo;
      } else {
        bool changed = await changeMusicServer();
        if (!changed) {
          return null;
        }
      }
    }
  }

  /// safe
  Future<PlayInfo?> getUpdatePlayInfoAndLyric(
      [Quality? selectedQuality]) async {
    if (currentMusic.qualities.isEmpty) {
      LogToast.error("获取播放信息", "获取播放信息失败: 无音质可选",
          "[getUpdateMusicPlayInfo] Failed to get play info, no qualities");
      return null;
    }

    // try to use local cache
    try {
      var musicCache = await getCacheMusic(
          name: musicAggregator.name,
          artists: musicAggregator.artist,
          documentFolder: globalDocumentPath);
      playinfo = musicCache?.$1;
      lyric = musicCache?.$2;
      try {
        lyric ??= await currentMusic.getLyric();
      } catch (e) {
        LogToast.error("在线获取歌词失败", "在线获取歌词失败: ${currentMusic.name} $e",
            "[getUpdateMusicPlayInfo] Failed to get lyric: $e");
      }
      if (playinfo != null) {
        globalTalker
            .info("[getUpdateMusicPlayInfo] 使用缓存歌曲: ${currentMusic.name}");
        setUpdated();
        return playinfo!;
      }
      // ignore: empty_catches
    } catch (e) {}

    if (globalConfig.externalApi == null) {
      LogToast.error("获取播放信息失败", "未导入第三方音乐源，无法在线获取播放信息",
          "[getUpdateMusicPlayInfo] Failed to get play info, no extern api");
      return null;
    }

    playinfo = await globalExternalApiEvaler!.getMusicPlayInfo(currentMusic,
        selectedQuality ?? autoPickQuality(currentMusic.qualities));

    if (playinfo == null) {
      globalTalker.error(
          "[getUpdateMusicPlayInfo] 第三方音乐源无法获取到playinfo: [${currentMusic.server}]${currentMusic.name}");
      return null;
    }

    globalTalker.info(
        "[getUpdateMusicPlayInfo] 使用第三方Api请求获取playinfo: [${currentMusic.server}]${currentMusic.name}");
    setUpdated();
    return playinfo;
  }

  /// safe
  MediaItem _toMediaItem() {
    Uri? artUri;
    if (currentMusic.cover != null) {
      artUri = Uri.parse(currentMusic.cover!);
    } else {
      artUri = null;
    }
    return MediaItem(
        id: currentMusic.hashCode.toString(),
        title: currentMusic.name,
        album: currentMusic.album,
        artUri: artUri,
        artist: currentMusic.artists.map((e) => e.name).join(","));
  }

  /// safe
  Future<bool> _updateAudioSource() async {
    if (playinfo != null) {
      if (playinfo!.uri.contains("http")) {
        if ((Platform.isIOS || Platform.isMacOS) &&
            ((playinfo!.quality.format != null &&
                    playinfo!.quality.format!.contains("flac")) ||
                (playinfo!.quality.summary.contains("flac")))) {
          audioSource = ProgressiveAudioSource(Uri.parse(playinfo!.uri),
              tag: _toMediaItem(),
              options: const ProgressiveAudioSourceOptions(
                  darwinAssetOptions: DarwinAssetOptions(
                      preferPreciseDurationAndTiming: true)));
        } else {
          audioSource =
              AudioSource.uri(Uri.parse(playinfo!.uri), tag: _toMediaItem());
        }
      } else {
        if ((Platform.isIOS || Platform.isMacOS) &&
            ((playinfo!.quality.format != null &&
                    playinfo!.quality.format!.contains("flac")) ||
                (playinfo!.quality.summary.contains("flac")))) {
          audioSource = ProgressiveAudioSource(Uri.file(playinfo!.uri),
              tag: _toMediaItem(),
              options: const ProgressiveAudioSourceOptions(
                  darwinAssetOptions: DarwinAssetOptions(
                      preferPreciseDurationAndTiming: true)));
        } else {
          audioSource = AudioSource.file(playinfo!.uri, tag: _toMediaItem());
        }
      }

      globalTalker.info(
          "[MusicContainer._updateAudioSource] 更新 '${musicAggregator.name}' AudioSource 成功");
      return true;
    }

    return false;
  }

  // 切换音乐源
  Future<bool> changeMusicServer([MusicServer? server]) async {
    usedServers.add(currentMusic.server);
    server ??= nextSource(usedServers);

    if (server == null) {
      LogToast.error("切换音乐源失败", "无法切换音乐源: 未指定音源或无更多音源可切换",
          "[MusicContainer] Failed to change music source: No available source");
      return false;
    }

    if (!musicAggregator.musics.any((e) => e.server == server)) {
      try {
        musicAggregator =
            await musicAggregator.fetchServerOnline(servers: [server]);
      } catch (e) {
        LogToast.error("切换音乐源失败", "'${musicAggregator.name}'切换音乐源失败: $e",
            "[MusicContainer] Failed to change music source: $e");
        return false;
      }
    }

    var index = musicAggregator.musics.indexWhere((e) {
      return e.server == server;
    });

    if (index == -1) {
      LogToast.error(
          "切换音乐源失败",
          "'${musicAggregator.name}'切换音乐源失败: 在$server查找不到'${musicAggregator.name}'歌曲.",
          "[MusicContainer] Failed to change music source: Cannot find '${musicAggregator.name}' in $server");
      return false;
    }

    currentMusicIndex = index;

    if (musicAggregator.fromDb) {
      await musicAggregator.saveToDb();
      await musicAggregator.changeDefaultServerInDb(
          server: currentMusic.server);
      musicAggregator.defaultServer = server;
    }

    audioSource = AudioSource.asset("assets/blank.mp3", tag: _toMediaItem());
    // LogToast.info("切换音乐源成功", "${musicAggregator.name}默认音源切换为$server",
    //     "[MusicContainer] Successfully changed music source to $server");
    globalTalker
        .log("[MusicContainer] 成功切换音乐源: ${musicAggregator.name}默认音源切换为$server");

    return true;
  }
}

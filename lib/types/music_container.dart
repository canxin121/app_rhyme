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
  late int currentIndex;

  PlayInfo? playInfo;
  String? lyric;
  late AudioSource audioSource;
  List<MusicServer> usedServers = [];
  DateTime lastUpdate = DateTime(1999);

  MusicContainer(MusicAggregator musicAgg) {
    musicAggregator = musicAgg;
    currentIndex = 0;
    audioSource = AudioSource.asset("assets/blank.mp3", tag: _toMediaItem());
  }

  Music get currentMusic => musicAggregator.musics[currentIndex];

  // 使上次更新时间过期
  setOutdate() {
    lastUpdate = DateTime(1999);
  }

  // 检查音乐是否需要更新
  bool shouldUpdate() {
    try {
      return (audioSource as ProgressiveAudioSource)
              .uri
              .path
              .contains("/assets/") ||
          DateTime.now().difference(lastUpdate).abs().inSeconds >= 1800;
    } catch (_) {
      return true;
    }
  }

  // 更新音乐内部的播放信息和音频资源
  // quality: 指定音质，如果不指定则使用默认音质
  // 会在 主动获取 或者 LazyLoad 时使用
  // 如果获取失败，则会尝试换源
  // 如果换源后仍失败，则会返回false
  Future<bool> updateAll([Quality? quality]) async {
    bool success = await _updateAudioSource(quality);
    if (success) {
      await _updateLyric();
    }
    return success;
  }

  Future<PlayInfo?> getUpdatePlayInfo([Quality? selectedQuality]) async {
    // 更新当前音质, 每次都更新以适配网络变化
    if (currentMusic.qualities.isEmpty) {
      LogToast.error("获取播放信息", "获取播放信息失败: 无音质可选",
          "[getCurrentMusicPlayInfo] Failed to get play info, no qualities");
      return null;
    }

    late Quality targetQuality;
    if (selectedQuality != null) {
      targetQuality = selectedQuality;
    } else {
      targetQuality = autoPickQuality(currentMusic.qualities);
    }

    // 有本地缓存直接返回
    try {
      var musicCache = await getCacheMusic(music: currentMusic);
      if (musicCache != null) {
        playInfo = musicCache.$1;
        lyric = musicCache.$2;
      }

      if (playInfo != null) {
        globalTalker
            .info("[getCurrentMusicPlayInfo] 使用缓存歌曲: ${currentMusic.name}");
        return playInfo!;
      }
      // ignore: empty_catches
    } catch (e) {}

    // 没有本地缓存，也没有第三方api，直接返回null
    if (globalConfig.externApi == null) {
      // 未导入第三方音乐源，应当toast提示用户
      LogToast.error("获取播放信息失败", "未导入第三方音乐源，无法在线获取播放信息",
          "[getCurrentMusicPlayInfo] Failed to get play info, no extern api");
      return null;
    }

    // 有第三方api，使用api进行请求
    playInfo = await globalExternApiEvaler!
        .getMusicPlayInfo(currentMusic, targetQuality);

    // 如果第三方api查找不到，直接返回null
    if (playInfo == null) {
      globalTalker.error(
          "[getCurrentMusicPlayInfo] 第三方音乐源无法获取到playinfo: [${currentMusic.server}]${currentMusic.name}");
      return null;
    } else {
      globalTalker.info(
          "[getCurrentMusicPlayInfo] 使用第三方Api请求获取playinfo: [${currentMusic.server}]${currentMusic.name}");
      return playInfo;
    }
  }

  // 将音乐信息转化为MediaItem, 用于AudioService在系统显示音频信息
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

  // 更新歌词
  Future<void> _updateLyric() async {
    if (lyric == null || lyric!.isEmpty) {
      try {
        lyric = await currentMusic.getLyric();
        globalTalker.info("[MusicContainer] 更新 '${currentMusic.name}' 歌词成功");
      } catch (e) {
        LogToast.error("更新歌词失败", "在线更新歌词失败: $e",
            "[MusicContainer] Failed to update lyric: $e");
        lyric = "[00:00.00]获取歌词失败";
      }
    }
  }

  // 更新音频资源
  Future<bool> _updateAudioSource([Quality? quality]) async {
    lastUpdate = DateTime.now();
    while (true) {
      try {
        playInfo = await getUpdatePlayInfo(quality);
      } catch (e) {
        playInfo = null;
      }
      if (playInfo != null) {
        if (playInfo!.uri.contains("http")) {
          if ((Platform.isIOS || Platform.isMacOS) &&
              ((playInfo!.quality.format != null &&
                      playInfo!.quality.format!.contains("flac")) ||
                  (playInfo!.quality.summary.contains("flac")))) {
            audioSource = ProgressiveAudioSource(Uri.parse(playInfo!.uri),
                tag: _toMediaItem(),
                options: const ProgressiveAudioSourceOptions(
                    darwinAssetOptions: DarwinAssetOptions(
                        preferPreciseDurationAndTiming: true)));
          } else {
            audioSource =
                AudioSource.uri(Uri.parse(playInfo!.uri), tag: _toMediaItem());
          }
        } else {
          if ((Platform.isIOS || Platform.isMacOS) &&
              ((playInfo!.quality.format != null &&
                      playInfo!.quality.format!.contains("flac")) ||
                  (playInfo!.quality.summary.contains("flac")))) {
            audioSource = ProgressiveAudioSource(Uri.file(playInfo!.uri),
                tag: _toMediaItem(),
                options: const ProgressiveAudioSourceOptions(
                    darwinAssetOptions: DarwinAssetOptions(
                        preferPreciseDurationAndTiming: true)));
          } else {
            audioSource = AudioSource.file(playInfo!.uri, tag: _toMediaItem());
          }
        }
        globalTalker
            .info("[MusicContainer] 更新 '${musicAggregator.name}' 音频资源成功");
        return true;
      } else {
        // LogToast.error("更新播放资源失败", "${musicAggregator.name}更新播放资源失败, 尝试换源播放",
        //     "[MusicContainer] Failed to update audio source, try to change source");
        bool changed = await _changeSource();
        if (!changed) {
          return false;
        }
      }
    }
  }

  // 切换音乐源         
  Future<bool> _changeSource([MusicServer? server]) async {
    usedServers.add(currentMusic.server);
    server ??= nextSource(usedServers);

    if (server != null) {
      try {
        var hasServer = musicAggregator.musics.where((e) {
          return e.server == server;
        }).isNotEmpty;

        if (!hasServer) {
          try {
            musicAggregator =
                await musicAggregator.fetchServerOnline(servers: [server]);
          } catch (e) {
            musicAggregator = (e as dynamic).field0;
            throw (e as dynamic).field1;
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
        currentIndex = index;

        if (musicAggregator.fromDb) {
          await musicAggregator.saveToDb();
          await musicAggregator.changeDefaultServerInDb(
              server: currentMusic.server);
          musicAggregator.defaultServer = server;
        }

        audioSource =
            AudioSource.asset("assets/blank.mp3", tag: _toMediaItem());
        // LogToast.info("切换音乐源成功", "${musicAggregator.name}默认音源切换为$server",
        //     "[MusicContainer] Successfully changed music source to $server");
      } catch (e) {
        LogToast.error(
            "'${musicAggregator.name}'切换音乐源失败",
            "${musicAggregator.name}切换音乐源失败: $e",
            "[MusicContainer] Failed to change music source: $e");

        return false;
      }
      return true;
    } else {
      return false;
    }
  }
}

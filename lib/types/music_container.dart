import 'dart:io';

import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/types/playinfo.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:audio_service/audio_service.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

// 这个结构代表了待播音乐的信息
class MusicContainer {
  late MusicAggregatorW aggregator;
  late MusicW currentMusic;
  late MusicInfo info;
  late String? extra;
  // 从Api or 本地获取的真实待播放的音质信息
  late Rx<Quality?> currentQuality;
  PlayInfo? playInfo;
  // 待播放的音频资源
  late AudioSource audioSource;
  // 已经使用过的音乐源，用于自动换源时选择下一个源
  List<String> usedSources = [];
  // 上次更新时间，用于判断是否需要更新
  DateTime lastUpdate = DateTime(1999);

  MusicContainer(MusicAggregatorW aggregator_) {
    aggregator = aggregator_;
    currentMusic = aggregator_.getDefaultMusic();
    info = currentMusic.getMusicInfo();
    _updateQuality();
    audioSource = AudioSource.asset("assets/blank.mp3", tag: _toMediaItem());
  }

  // 使上次更新时间过期
  setOutdate() {
    lastUpdate = DateTime(1999);
  }

  String toCacheFileName() {
    return "${info.name}_${info.artist.join(",")}_${currentQuality.value!.short}.${currentQuality.value!.format ?? "unknown"}";
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

  // 是否有缓存
  Future<bool> hasCache() async {
    try {
      return hasCachePlayinfo(musicInfo: info);
    } catch (e) {
      return false;
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

  Future<PlayInfo?> getCurrentMusicPlayInfo([Quality? quality_]) async {
    // 更新当前音质, 每次都更新以适配网络变化
    _updateQuality(quality_);

    late Quality finalQuality;
    if (quality_ != null) {
      finalQuality = quality_;
    } else if (currentQuality.value != null) {
      finalQuality = currentQuality.value!;
    } else {
      LogToast.error("获取播放信息失败", "未找到可用音质",
          "[getCurrentMusicPlayInfo] Failed to get play info, no quality found");
      return null;
    }
    // 更新extra信息
    extra = currentMusic.getExtraInfo(quality: finalQuality);

    // // 有本地缓存直接返回
    try {
      playInfo = await getCachePlayinfo(musicInfo: info);
      if (playInfo != null) {
        globalTalker.info("[getCurrentMusicPlayInfo] 使用缓存歌曲: ${info.name}");
        currentQuality.value = playInfo!.quality;
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
    playInfo =
        await globalExternApiEvaler!.getMusicPlayInfo(info.source, extra!);

    // 如果第三方api查找不到，直接返回null
    if (playInfo == null) {
      globalTalker.error(
          "[getCurrentMusicPlayInfo] 第三方音乐源无法获取到playinfo: [${info.source}]${info.name}");
      return null;
    } else {
      currentQuality.value = playInfo!.quality;
      globalTalker.info(
          "[getCurrentMusicPlayInfo] 使用第三方Api请求获取playinfo: [${info.source}]${info.name}");
      return playInfo;
    }
  }

  // 将音乐信息转化为MediaItem, 用于AudioService在系统显示音频信息
  MediaItem _toMediaItem() {
    Uri? artUri;
    if (info.artPic != null) {
      artUri = Uri.parse(info.artPic!);
    } else {
      artUri = null;
    }
    return MediaItem(
        id: extra.hashCode.toString(),
        title: info.name,
        album: info.album,
        artUri: artUri,
        artist: info.artist.join(","));
  }

  Future<void> _updateLyric() async {
    if (info.lyric == null || info.lyric!.isEmpty) {
      try {
        var lyric = await aggregator.fetchLyric();
        globalTalker.info("[MusicContainer] 更新 '${info.name}' 歌词成功");
        info.lyric = lyric;
      } catch (e) {
        LogToast.error("更新歌词失败", "在线更新歌词失败: $e",
            "[MusicContainer] Failed to update lyric: $e");
        info.lyric = "[00:00.00]获取歌词失败";
      }
    }
  }

  Future<bool> _updateAudioSource([Quality? quality]) async {
    lastUpdate = DateTime.now();
    if (quality != null) extra = currentMusic.getExtraInfo(quality: quality);
    while (true) {
      try {
        playInfo = await getCurrentMusicPlayInfo(quality);
      } catch (e) {
        playInfo = null;
      }
      if (playInfo != null) {
        // 更新当前音质
        currentQuality.value = playInfo!.quality;

        if (playInfo!.uri.contains("http")) {
          if ((Platform.isIOS || Platform.isMacOS) &&
              ((playInfo!.quality.format != null &&
                      playInfo!.quality.format!.contains("flac")) ||
                  (playInfo!.quality.short.contains("flac")))) {
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
                  (playInfo!.quality.short.contains("flac")))) {
            audioSource = ProgressiveAudioSource(Uri.file(playInfo!.uri),
                tag: _toMediaItem(),
                options: const ProgressiveAudioSourceOptions(
                    darwinAssetOptions: DarwinAssetOptions(
                        preferPreciseDurationAndTiming: true)));
          } else {
            audioSource = AudioSource.file(playInfo!.uri, tag: _toMediaItem());
          }
        }
        globalTalker.info("[MusicContainer] 更新 '${info.name}' 音频资源成功");
        return true;
      } else {
        LogToast.error("更新播放资源失败", "${info.name}更新播放资源失败, 尝试换源播放",
            "[MusicContainer] Failed to update audio source, try to change source");
        bool changed = await _changeSource();
        if (!changed) {
          return false;
        }
      }
    }
  }

  Future<bool> _changeSource([String? source]) async {
    // 换源表明弃用当前源，将其移到usedSource中
    usedSources.add(currentMusic.source());
    // 根据usedSource来获得下一个源
    source ??= nextSource(usedSources);

    if (source != null) {
      try {
        await aggregator.fetchMusics(sources: [source]);
        await aggregator.setDefaultSource(source: source);
        currentMusic = aggregator.getDefaultMusic();
        info = currentMusic.getMusicInfo();
        extra = currentMusic.getExtraInfo(quality: info.defaultQuality!);
        audioSource =
            AudioSource.asset("assets/blank.mp3", tag: _toMediaItem());
        LogToast.info("切换音乐源成功", "${info.name}默认音源切换为$source",
            "[MusicContainer] Successfully changed music source to $source");
      } catch (e) {
        LogToast.error("切换音乐源失败", "${info.name}切换音乐源失败: $e",
            "[MusicContainer] Failed to change music source: $e");

        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  void _updateQuality([Quality? quality]) {
    if (quality != null) {
      currentQuality.value = quality;
      extra = currentMusic.getExtraInfo(quality: quality);
    } else {
      if (info.qualities.isNotEmpty) {
        currentQuality = autoPickQuality(info.qualities).obs;
        extra = currentMusic.getExtraInfo(quality: currentQuality.value!);
      } else {
        currentQuality.value = null;
        extra = null;
      }
    }
  }
}

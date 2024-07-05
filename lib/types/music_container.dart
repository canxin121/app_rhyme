import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:app_rhyme/utils/type_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:toastification/toastification.dart';

class PlayInfo {
  late String file;
  late Quality quality;

  PlayInfo(
    this.file,
    this.quality,
  );

  factory PlayInfo.fromObject(dynamic obj) {
    return PlayInfo(obj['url'], qualityFromObject(obj["quality"]));
  }
}

// 这个结构代表了待播音乐的信息
class MusicContainer {
  late MusicAggregatorW aggregator;
  late MusicW currentMusic;
  late MusicInfo info;
  late String? extra;
  // 从Api or 本地获取的真实待播放的音质信息
  late Rx<Quality?> currentQuality;
  late PlayInfo? playInfo;
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

  // 缓存文件名
  String toCacheFileName({Quality? quality_}) {
    var quality = quality_ ?? info.defaultQuality!;
    return "${info.name}_${info.artist.join(',')}_${info.source}_${extra.hashCode}_${quality.short}.${quality.format ?? "unknown"}"
        .replaceAll("\r", "");
  }

  // 是否有缓存
  bool hasCache() {
    var cache = useCacheFile(
        file: "", cachePath: musicCacheRoot, filename: toCacheFileName());
    return cache != null;
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

  Future<PlayInfo?> getCurrentMusicPlayInfo([Quality? quality]) async {
    // 更新当前音质
    try {
      _updateQuality();
    } catch (e) {
      globalTalker.error("[getCurrentMusicPlayInfo]获取音质失败:$e");
      return null;
    }
    late Quality finalQuality;
    if (quality != null) {
      finalQuality = quality;
    } else if (currentQuality.value != null) {
      finalQuality = currentQuality.value!;
    }

    // 尝试获取本地缓存
    var cache = useCacheFile(
        file: "",
        cachePath: musicCacheRoot,
        filename: toCacheFileName(quality_: quality));

    // 有本地缓存直接返回
    if (cache != null) {
      globalTalker.info("[getCurrentMusicPlayInfo] 使用本地歌曲缓存转化歌曲: ${info.name}");
      return PlayInfo(cache, finalQuality);
    }

    // 没有本地缓存，也没有第三方api，直接返回null
    if (globalConfig.externApi == null) {
      // 未导入第三方音乐源，应当toast提示用户
      toastification.show(
          autoCloseDuration: const Duration(seconds: 2),
          type: ToastificationType.error,
          title: const Text('获取播放信息失败'),
          description:
              RichText(text: const TextSpan(text: '未导入第三方音乐源，无法在线获取播放信息')));

      globalTalker.error("[getCurrentMusicPlayInfo] 无第三方音乐源,无法获取播放信息");
      return null;
    }

    // 有第三方api，使用api进行请求
    var playinfo =
        await globalExternApiEvaler!.getMusicPlayInfo(info.source, extra!);

    // 如果第三方api查找不到，直接返回null
    if (playinfo == null) {
      globalTalker.error(
          "[getCurrentMusicPlayInfo] 第三方音乐源无法获取到playinfo: [${info.source}]${info.name}");
      return null;
    } else {
      currentQuality.value = playinfo.quality;
      globalTalker.info(
          "[getCurrentMusicPlayInfo] 使用第三方Api请求获取playinfo: [${info.source}]${info.name}");
      return PlayInfo(playinfo.file, playinfo.quality);
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
        toastification.show(
            autoCloseDuration: const Duration(seconds: 2),
            type: ToastificationType.info,
            title:
                Text("更新歌词失败", style: const TextStyle().useSystemChineseFont()),
            description: Text("在线更新 '${info.name}' 歌词失败:${e.toString()}",
                style: const TextStyle().useSystemChineseFont()));
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

        if (playInfo!.file.contains("http")) {
          if ((Platform.isIOS || Platform.isMacOS) &&
              playInfo!.quality.short.contains("flac")) {
            audioSource = ProgressiveAudioSource(Uri.parse(playInfo!.file),
                tag: _toMediaItem(),
                options: const ProgressiveAudioSourceOptions(
                    darwinAssetOptions: DarwinAssetOptions(
                        preferPreciseDurationAndTiming: true)));
          } else {
            audioSource =
                AudioSource.uri(Uri.parse(playInfo!.file), tag: _toMediaItem());
          }
        } else {
          if ((Platform.isIOS || Platform.isMacOS) &&
              playInfo!.quality.short.contains("flac")) {
            audioSource = ProgressiveAudioSource(Uri.file(playInfo!.file),
                tag: _toMediaItem(),
                options: const ProgressiveAudioSourceOptions(
                    darwinAssetOptions: DarwinAssetOptions(
                        preferPreciseDurationAndTiming: true)));
          } else {
            audioSource = AudioSource.file(playInfo!.file, tag: _toMediaItem());
          }
        }
        globalTalker.info("[MusicContainer] 更新 '${info.name}' 音频资源成功");
        return true;
      } else {
        toastification.show(
            autoCloseDuration: const Duration(seconds: 2),
            type: ToastificationType.info,
            title: Text("获取播放资源失败",
                style: const TextStyle().useSystemChineseFont()),
            description: Text("${info.name}获取播放资源失败, 尝试换源播放",
                style: const TextStyle().useSystemChineseFont()));
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
        currentQuality = info.defaultQuality!.obs;
        toastification.show(
            autoCloseDuration: const Duration(seconds: 2),
            type: ToastificationType.success,
            title: Text("切换音乐源成功",
                style: const TextStyle().useSystemChineseFont()),
            description: Text("${info.name}默认音源切换为$source",
                style: const TextStyle().useSystemChineseFont()));
      } catch (e) {
        globalTalker.error("[PlayMusic] 切换音乐源失败: $e");
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  void _updateQuality() {
    if (info.qualities.isNotEmpty) {
      currentQuality = autoPickQuality(info.qualities).obs;
      extra = currentMusic.getExtraInfo(quality: currentQuality.value!);
    } else {
      throw "没有可选音质";
    }
  }
}

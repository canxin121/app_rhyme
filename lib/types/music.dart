import 'dart:io';

import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayInfo {
  late String file;
  late Quality quality;
  PlayInfo(
    String file_,
    Quality quality_,
  ) {
    file = file_;
    quality = quality_;
  }
  factory PlayInfo.fromObject(dynamic obj) {
    return PlayInfo(
      obj['url'],
      Quality.fromObject(obj['quality']),
    );
  }
}

// 这个结构代表了待播音乐的信息
class Music {
  late MusicW ref;
  late MusicInfo info;
  late String extra;
  Quality? useQuality;
  late AudioSource audioSource;
  bool empty = true;
  DateTime lastUpdate = DateTime(1999);
  Music(MusicW musicRef_) {
    ref = musicRef_;
    info = musicRef_.getMusicInfo();
    extra = musicRef_.getExtraInto(quality: info.defaultQuality!);
    audioSource = AudioSource.asset("assets/nature.mp3", tag: toMediaItem());
  }

  bool shouldUpdate() {
    return empty ||
        DateTime.now().difference(lastUpdate).abs().inSeconds >= 1800;
  }

  String toCacheFileName({Quality? quality_}) {
    var quality = quality_ ?? info.defaultQuality!;
    return "${info.name}_${info.artist.join(',')}_${info.source}_${extra.hashCode}_${quality.short}.${quality.format ?? "unknown"}";
  }

  Future<bool> hasCache() async {
    var cache = await useCacheFile(
        file: "", cachePath: musicCachePath, filename: toCacheFileName());
    return cache != null;
  }

  MediaItem toMediaItem() {
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

  // 主动获取 或者 LazyLoad时使用
  // 如果获取失败，将返回false
  Future<bool> updateAudioSource([Quality? quality]) async {
    empty = false;
    lastUpdate = DateTime.now();
    var playInfo = await getPlayInfo(quality);
    if (playInfo == null) return false;
    useQuality = playInfo.quality;
    if (playInfo.file.contains("http")) {
      if ((Platform.isIOS || Platform.isMacOS) &&
          playInfo.quality.short.contains("flac")) {
        audioSource = ProgressiveAudioSource(Uri.parse(playInfo.file),
            tag: toMediaItem(),
            options: const ProgressiveAudioSourceOptions(
                darwinAssetOptions:
                    DarwinAssetOptions(preferPreciseDurationAndTiming: true)));
      } else {
        audioSource =
            AudioSource.uri(Uri.parse(playInfo.file), tag: toMediaItem());
      }
    } else {
      if ((Platform.isIOS || Platform.isMacOS) &&
          playInfo.quality.short.contains("flac")) {
        audioSource = ProgressiveAudioSource(Uri.file(playInfo.file),
            tag: toMediaItem(),
            options: const ProgressiveAudioSourceOptions(
                darwinAssetOptions:
                    DarwinAssetOptions(preferPreciseDurationAndTiming: true)));
      } else {
        audioSource = AudioSource.file(playInfo.file, tag: toMediaItem());
      }
    }
    return true;
  }

  Future<PlayInfo?> getPlayInfo([Quality? quality]) async {
    late Quality finalQuality;
    if (quality != null) {
      finalQuality = quality;
    } else {
      if (info.defaultQuality != null) {
        finalQuality = info.defaultQuality!;
      } else if (info.qualities.isNotEmpty) {
        finalQuality = info.qualities[0];
        talker.info("[Display2Music] 音乐无默认音质,选择音质中第一个进行播放:$finalQuality");
      } else {
        talker.error("[Display2Music] 音乐没有可供播放的音质");
        return null;
      }
    }

    // 尝试获取本地缓存
    var cache = await useCacheFile(
        file: "",
        cachePath: musicCachePath,
        filename: toCacheFileName(quality_: quality));

    // 有本地缓存直接返回
    if (cache != null) {
      talker.info("[Display2Music] 使用本地歌曲缓存转化歌曲: ${info.name}");
      return PlayInfo(cache, finalQuality);
    }

    // 没有本地缓存，也没有第三方api，直接返回null
    if (globalExternApi == null) {
      talker.error("[Display2Music] 无第三方音乐源,无法获取播放信息");
    }

    // 有第三方api，使用api进行请求
    var playinfo = await globalExternApi!.getMusicPlayInfo(info.source, extra);

    // 如果第三方api查找不到，直接返回null
    if (playinfo == null) {
      talker.error("[Display2Music] 第三方音乐源无法获取到playinfo: ${info.name}");
      return null;
    } else {
      talker.info("[Display2Music] 使用第三方Api请求转化歌曲: ${info.name}");
      return PlayInfo(playinfo.file, playinfo.quality);
    }
  }
}

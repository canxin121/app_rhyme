import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:audio_service/audio_service.dart';

// 是一个原本只具有展示功能的DisplayMusicTuple通过请求第三方api变成可以播放的音乐
// 这个过程已经决定了一个音乐是否可以播放，因此本函数应该可能throw Exception
Future<PlayMusic?> display2PlayMusic(DisplayMusic music,
    [Quality? quality]) async {
  late Quality finalQuality;
  if (quality != null) {
    finalQuality = quality;
  } else {
    if (music.info.defaultQuality != null) {
      finalQuality = music.info.defaultQuality!;
    } else if (music.info.qualities.isNotEmpty) {
      finalQuality = music.info.qualities[0];
      talker.log("[Display2PlayMusic] 音乐无默认音质,选择音质中第一个进行播放:$finalQuality");
    } else {
      talker.error("[Display2PlayMusic] 音乐没有可供播放的音质");
      return null;
    }
  }

  // 音乐缓存获取的逻辑
  var result = music.toCacheFileNameAndExtra();
  if (result == null) {
    return null;
  }
  var (cacheFileName, extra) = result;
  // 尝试获取本地缓存
  var cache = await useCacheFile(
      file: "", cachePath: musicCachePath, filename: cacheFileName);
  // 有本地缓存直接返回
  if (cache != null) {
    return PlayMusic(music.ref, music.info, PlayInfo(cache, finalQuality),
        music.ref.getExtraInto(quality: finalQuality));
  }
  // 没有本地缓存，也没有第三方api，直接返回null
  if (globalExternApi == null) {
    talker.error("[Display2PlayMusic] 无第三方音乐源,无法获取播放信息");
  }

  var playinfo =
      await globalExternApi!.getMusicPlayInfo(music.info.source, extra);

  // 如果第三方api夜叉找不到，直接返回null
  if (playinfo == null) {
    talker.error("[Display2PlayMusic] 第三方音乐源无法获取到playinfo: ${music.info.name}");
    return null;
  }
  var playMusic = PlayMusic(music.ref, music.info, playinfo, extra);

  return playMusic;
}

class DisplayMusic {
  late MusicW ref;
  late MusicInfo info;
  DisplayMusic(MusicW musicRef_) {
    ref = musicRef_;
    info = ref.getMusicInfo();
  }
  DisplayMusic.fromPlayMusic(PlayMusic music) {
    DisplayMusic(music.ref);
  }
  (String, String)? toCacheFileNameAndExtra() {
    if (info.defaultQuality == null) {
      return null;
    }
    var extra = ref.getExtraInto(quality: info.defaultQuality!);
    var cacheFileName =
        "${info.name}_${info.artist.join(',')}_${info.source}_${extra.hashCode}.${info.defaultQuality!.format ?? "unknown"}";
    return (cacheFileName, extra);
  }

  Future<bool> hasCache() async {
    var result = toCacheFileNameAndExtra();
    if (result == null) {
      return false;
    }
    var cache = await useCacheFile(
        file: "", cachePath: musicCachePath, filename: result.$1);
    if (cache != null) {
      return true;
    } else {
      return false;
    }
  }
}

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
class PlayMusic {
  late MusicW ref;
  late MusicInfo info;
  late MediaItem item;
  late PlayInfo playInfo;
  late String extra;
  bool hasCache = false;
  PlayMusic(
      MusicW musicRef_, MusicInfo info_, PlayInfo playinfo_, String extra_) {
    ref = musicRef_;
    info = info_;
    playInfo = playinfo_;
    extra = extra_;
    item = MediaItem(
        id: info.name + info.source + info.artist.join(","),
        title: info.name,
        album: info.album,
        artUri: () {
          if (info.artPic != null) {
            return Uri.parse(info.artPic!);
          } else {
            return null;
          }
        }(),
        displayTitle: info.name,
        displaySubtitle: info.artist.join(","));
  }
  String toCacheFileName() {
    return "${info.name}_${info.artist.join(',')}_${info.source}_${extra.hashCode}.${playInfo.quality.format ?? "unknown"}";
  }

  MediaItem toMediaItem() {
    Uri? artUri;
    if (info.artPic != null) {
      artUri = Uri.parse(info.artPic!);
    } else {
      artUri = null;
    }
    return MediaItem(
        id: playInfo.file,
        title: info.name,
        album: info.album,
        artUri: artUri,
        artist: info.artist.join(","));
  }
}

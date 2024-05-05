import 'dart:io';

// import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:flutter/cupertino.dart';

Future<String> fileCacheHelper(String file, String cachePath) async {
  late String toUseSource;

  var localSource = await useCacheFile(
    file: file,
    cachePath: cachePath,
  );
  if (localSource != null) {
    // talker.debug("[fileCacheHelper] 使用已缓存source: ($file)->($localSource)");
    toUseSource = localSource;
  } else {
    // talker.debug("[fileCacheHelper] 不缓存,直接使用 $file");
    toUseSource = file;
  }

  return toUseSource;
}

Future<Hero> playingMusicImage() async {
  late Image image;
  var playingMusic = globalAudioHandler.playingMusic.value;
  if (playingMusic != null && playingMusic.info.artPic != null) {
    String url = playingMusic.info.artPic!;
    String toUseSource = await fileCacheHelper(url, picCachePath);
    if (toUseSource.contains("http")) {
      image = Image.network(toUseSource);
    } else {
      image = Image.file(File(toUseSource));
    }
  } else {
    image = defaultArtPic;
  }
  return Hero(
    tag: "PlayingMusicArtPic",
    child: image,
  );
}

String get playingMusicQualityShort {
  late Quality quality;
  var playingMusic = globalAudioHandler.playingMusic.value;
  if (playingMusic != null) {
    quality = playingMusic.playInfo.quality;
  } else {
    quality = const Quality(short: "Quality");
  }
  return quality.short;
}

String get playingMusicName {
  late String name;
  var playingMusic = globalAudioHandler.playingMusic.value;
  if (playingMusic != null) {
    name = playingMusic.info.name;
  } else {
    name = "Music";
  }
  return name;
}

String get playingMusicArtist {
  late String artist;
  var playingMusic = globalAudioHandler.playingMusic.value;
  if (playingMusic != null) {
    artist = playingMusic.info.artist.join(",");
  } else {
    artist = "Artist";
  }
  return artist;
}

Future<Image> useCacheImage(String? file_) async {
  if (file_ != null && file_.isNotEmpty) {
    var file = await fileCacheHelper(file_, picCachePath);
    if (file.contains("http")) {
      return Image.network(file);
    } else {
      return Image.file(File(file));
    }
  } else {
    return defaultArtPic;
  }
}

import 'dart:developer';
import 'dart:io';

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
    log("fileCacheHelper: 使用已缓存source: ($file)->($localSource)");
    toUseSource = localSource;
  } else {
    log("fileCacheHelper: 不缓存,直接使用 $file");

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

Future<ImageProvider> getMusicListImageProvider(
    MusicList musicList, bool useCache) async {
  late ImageProvider image;
  if (musicList.artPic.isNotEmpty) {
    String url = musicList.artPic;
    String source = await fileCacheHelper(url, picCachePath);
    if (source.contains("http")) {
      image = NetworkImage(source);
    } else {
      image = FileImage(File(source));
    }
  } else {
    image = defaultArtPicProvider;
  }
  return image;
}

Future<Image> getMusicListImage(MusicList musicList, bool useCache) async {
  late Image image;
  if (musicList.artPic.isNotEmpty) {
    String url = musicList.artPic;
    String source = await fileCacheHelper(url, picCachePath);
    if (source.contains("http")) {
      image = Image.network(source);
    } else {
      image = Image.file(File(source));
    }
  } else {
    image = defaultArtPic;
  }
  return image;
}

Future<ImageProvider> getMusicImageProvider(
    MusicList musicList, bool useCache) async {
  late ImageProvider image;
  if (musicList.artPic.isNotEmpty) {
    String url = musicList.artPic;
    String source = await fileCacheHelper(url, picCachePath);
    if (source.contains("http")) {
      image = NetworkImage(source);
    } else {
      image = FileImage(File(source));
    }
  } else {
    image = defaultArtPicProvider;
  }
  return image;
}

Future<Image> useCacheImage(String file) async {
  var cache = await useCacheFile(file: file, cachePath: picCachePath);
  if (cache != null) {
    return Image.file(File(cache));
  } else {
    if (file.contains("http")) {
      return Image.network(file);
    } else {
      return Image.file(File(file));
    }
  }
}

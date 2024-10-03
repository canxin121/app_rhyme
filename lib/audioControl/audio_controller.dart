// 涉及非常多bug的bypass, 很难run, 需要谨慎修改

import 'dart:io';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:audio_session/audio_session.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/time_parser.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:synchronized/synchronized.dart';

Future<void> initGlobalAudioHandler() async {
  if (Platform.isLinux) {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: false,
      android: false,
      iOS: false,
      macOS: false,
    );
  }

  // 测试后windows上，just_audio_background会导致播放异常，不使用表现反而更加正常
  if (!Platform.isWindows && !Platform.isLinux) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  // 将AudioSession配置为音乐模式
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  globalAudioHandler = AudioHandler();
  globalAudioHandler.pause();
}

bool isFirstPlay = true;

class AudioHandler {
  final AudioPlayer player = AudioPlayer();
  final RxList<MusicContainer> musicContainerList = RxList<MusicContainer>([]);
  final Rx<MusicContainer?> playingMusic = Rx<MusicContainer?>(null);
  final ConcatenatingAudioSource audioSourceList =
      ConcatenatingAudioSource(children: []);
  final listLock = Lock();
  int allowFailedTimes = 3;

  AudioHandler() {
    player.setLoopMode(LoopMode.all);
    player.setShuffleModeEnabled(false);

    // use globalTalker to record all error logs
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      globalTalker.error('[PlaybackEventStream Error] $e');
    });

    // LazyLoad Music when index changed
    player.currentIndexStream.listen((index) async {
      MusicContainer? targetMusicContainer;
      await listLock.synchronized(() async {
        if (index != null &&
            index >= 0 &&
            index < musicContainerList.length &&
            musicContainerList.isNotEmpty) {
          targetMusicContainer = musicContainerList[index];
        }
      });

      globalTalker.info(
        "[AudioHandler.indexStream] Music Index Changed: [$index](${targetMusicContainer?.musicAggregator.name})",
      );

      if (targetMusicContainer == null) {
        pause();
        return;
      }

      playingMusic.value = targetMusicContainer;
      playingMusic.refresh();
      await _lazyLoadMusic(index!);

      if (targetMusicContainer!.shouldUpdate()) {
        allowFailedTimes--;
        if (allowFailedTimes == 0) {
          allowFailedTimes = 3;
          if (isPlaying) await pause();
          LogToast.error("播放失败!", "播放失败次数过多，暂停播放!",
              "[tryLazyLoadMusic] Failed to lazy load music '${targetMusicContainer!.musicAggregator.name}' to many times, stop playing.");
          return;
        } else {
          allowFailedTimes = 3;
          if (isPlaying) await pause();
          await seekToNext();
          return;
        }
      }
    });
  }

  /// safe;
  /// lock;
  /// load to ui, query music playinfo, seek and play
  Future<void> _lazyLoadMusic(int index,
      {Quality? quality, bool force = false}) async {
    MusicContainer? targetMusicContainer;

    await listLock.synchronized(() async {
      if (musicContainerList.isNotEmpty &&
          index >= 0 &&
          index < musicContainerList.length) {
        targetMusicContainer = musicContainerList[index];

        if (force == false &&
            quality == null &&
            !targetMusicContainer!.shouldUpdate()) {
          targetMusicContainer = null;
        }
      }
    });
    if (targetMusicContainer == null) return;

    playingMusic.value = targetMusicContainer;

    try {
      if (!await targetMusicContainer!.updateAll(quality)) {
        globalTalker.info(
            "[AudioHandler.lazyLoadMusic] LazyLoad Music Failed to updateAudioSource: ${targetMusicContainer!.musicAggregator.name}");
        return;
      }

      if (player.playing) await pause();

      await listLock.synchronized(() async {
        await audioSourceList.clear();
        await audioSourceList
            .addAll(musicContainerList.map((e) => e.audioSource).toList());
      });

      await seek(Duration.zero, index: index);

      play();
      globalTalker.info(
          "[AudioHanlder.lazyLoadMusic] LazyLoad Music Succeed: ${targetMusicContainer!.musicAggregator.name}");
    } catch (e) {
      playingMusic.value = null;
      globalTalker.error("[AudioHandler.tryLazyLoadMusic] Unknown Error: $e");
    }
  }

  /// safe
  Future<void> addMusicPlay(MusicContainer musicContainer) async {
    if (player.playing) await pause();

    try {
      await listLock.synchronized(() async {
        var existIndex = musicContainerList.indexWhere((element) =>
            element.musicAggregator.name ==
                musicContainer.musicAggregator.name &&
            element.musicAggregator.artist ==
                musicContainer.musicAggregator.artist);
        if (existIndex != -1) {
          musicContainerList.removeAt(existIndex);
        }
        musicContainerList.add(musicContainer);
        await audioSourceList.clear();
        await audioSourceList
            .addAll(musicContainerList.map((e) => e.audioSource).toList());
      });
    } catch (e) {
      LogToast.error(
          "播放音乐失败",
          "添加音乐 '${musicContainer.musicAggregator.name}' 到播放列表失败.",
          "[AudioHandler.addMusicPlay] $e");
    }

    if (isFirstPlay) {
      await listLock.synchronized(() async {
        await player.setAudioSource(audioSourceList);
      });
      isFirstPlay = false;
    }

    if (player.playing) await pause();

    int lastIndex = -1;
    await listLock.synchronized(() async {
      lastIndex = musicContainerList.length - 1;
    });

    await _lazyLoadMusic(lastIndex);
  }

  /// safe
  Future<void> changePlayingMusicQuality(Quality quality) async {
    if (playingMusic.value == null) return;

    try {
      if (player.currentIndex != null && player.currentIndex != -1) {
        var position = player.position;

        await _lazyLoadMusic(player.currentIndex!,
            quality: quality, force: true);

        await seek(position);
      }
    } catch (e) {
      globalTalker.error("[AudioHandler.replacePlayingMusic] $e");
    }
  }

  /// safe
  Future<void> clearReplaceMusicAll(List<MusicContainer> musics) async {
    if (musics.isEmpty) {
      return;
    }

    if (player.playing) {
      await pause();
    }
    await clear();

    await listLock.synchronized(() async {
      musicContainerList.addAll(musics);
      await audioSourceList.addAll(musics.map((e) => e.audioSource).toList());
    });

    if (isFirstPlay) {
      await listLock.synchronized(() async {
        await player.setAudioSource(audioSourceList);
      });
      isFirstPlay = false;
    }
    await _lazyLoadMusic(0);
  }

  /// safe
  Future<void> clear() async {
    if (player.playing) {
      await pause();
    }
    await listLock.synchronized(() async {
      musicContainerList.clear();

      await audioSourceList.clear();
    });

    playingMusic.value = null;
  }

  /// safe
  Future<void> removeAt(int index) async {
    bool shouldChange = player.playing && player.currentIndex == index;
    if (shouldChange) {
      await pause();
    }

    await listLock.synchronized(() async {
      musicContainerList.removeAt(index);
      await audioSourceList.removeAt(index);
    });

    if (shouldChange && index >= 0 && index < musicContainerList.length) {
      await _lazyLoadMusic(index);
      await seek(Duration.zero, index: index);
    }
  }

  /// safe
  Future<void> seekToNext() async {
    if (player.playing) {
      await pause();
    }

    try {
      if (player.nextIndex == null) {
        return;
      }

      await player.seekToNext();
    } catch (e) {
      globalTalker.error("[AudioHandler.seekToNext] $e");
    }

    play();
  }

  /// safe
  Future<void> seekToPrevious() async {
    if (player.playing) {
      await pause();
    }

    try {
      if (player.previousIndex == null) {
        LogToast.error("播放下一首", "下一首的index为null, 播放失败",
            "[AudioHandler.seekToPrevious] player.previousIndex == null");
      }
      await player.seekToPrevious();
    } catch (e) {
      globalTalker.error("[AudioHandler.seekToPrevious] $e");
    }

    play();
  }

  /// safe
  Future<void> pause() async {
    try {
      await player.pause();
      Future.delayed(const Duration(milliseconds: 100), () {
        player.pause();
      });
    } catch (e) {
      globalTalker.error("[AudioHandler] In pause, error occur: $e");
    }
  }

  /// safe
  void play() async {
    try {
      Future.microtask(() => player.play());
      Future.delayed(const Duration(milliseconds: 100), () {
        Future.microtask(() => player.play());
      });
    } catch (e) {
      LogToast.error("播放歌曲", "播放失败: $e", "[AudioHandler.play] $e");
    }
  }

  /// safe
  Future<void> seek(Duration position, {int? index}) async {
    if (player.playing) {
      await pause();
    }

    try {
      if (index != null) await _lazyLoadMusic(index);

      await player.seek(position, index: index);

      play();

      globalTalker.info(
          "[AudioHandler.seek] Seek to [$index] ${formatDuration(position.inSeconds)}");
    } catch (e) {
      LogToast.error("跳转播放歌曲", "播放失败: $e", "[AudioHandler.seek] $e");
    }
  }

  bool get isPlaying {
    return player.playing;
  }
}

Future<void> initGlobalAudioUiController() async {
  globalAudioUiController = AudioUiController();
}

class AudioUiController extends GetxController {
  late Rx<PlayerState> playerState;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  Rx<double> playProgress = 0.0.obs;
  AudioUiController() {
    playerState = globalAudioHandler.player.playerState.obs;

    globalAudioHandler.player.playerStateStream.listen((event) {
      playerState.value = event;
      update();
    });

    globalAudioHandler.player.playbackEventStream.listen((event) {
      position.value = event.updatePosition;
      if (event.duration != null) {
        duration.value = event.duration!;
      }
      update();
    });

    globalAudioHandler.player.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration.value = newDuration;
        playProgress.value =
            position.value.inMicroseconds / duration.value.inMicroseconds;
        update();
      }
    });

    globalAudioHandler.player.positionDiscontinuityStream.listen((event) {
      position.value = event.event.updatePosition;
      playProgress.value =
          position.value.inMicroseconds / duration.value.inMicroseconds;
      update();
    });

    globalAudioHandler.player.positionStream.listen((event) {
      position.value = event;
      playProgress.value =
          position.value.inMicroseconds / duration.value.inMicroseconds;
      update();
    });
  }

  Duration seekDurationFromPercent(double percent) {
    return Duration(
        microseconds: (percent * duration.value.inMicroseconds).toInt());
  }
}

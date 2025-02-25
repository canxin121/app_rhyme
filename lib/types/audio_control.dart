// 涉及非常多bug的bypass, 很难run, 需要谨慎修改

import 'dart:async';
import 'dart:io';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/log_toast.dart';
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
  // 在linux和windows上使用JustAudioMediaKit
  if (Platform.isLinux || Platform.isWindows) {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
      android: false,
      iOS: false,
      macOS: false,
    );
  }

  // 在linux和windows上不需要使用JustAudioBackground
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

  // 用于保护musicContainerList和audioSourceList的异步读写
  final listLock = Lock();
  int allowFailedTimes = 3;

  AudioHandler() {
    player.setLoopMode(LoopMode.all);
    player.setShuffleModeEnabled(false);

    // 监听播放器的索引变化
    // 当索引变化时, 对音乐进行惰性加载
    // 当惰性加载失败次数过多时, 暂停播放
    player.currentIndexStream.listen((index) async {
      // 索引无效的情况, 直接暂停播放
      if (index == null ||
          index < 0 ||
          musicContainerList.isEmpty ||
          index >= musicContainerList.length) {
        globalLogger
            .info("[AudioHandler.indexStream] Music Index Invalid: $index");
        pause();
        playingMusic.value = null; // 确保UI也更新
        return;
      }

      // 获取目标音乐容器
      final targetMusicContainer = musicContainerList[index];

      // 惰性加载音乐
      await _lazyLoadMusic(index);

      // 检查是否需要更新，如果需要则进行处理
      if (targetMusicContainer.shouldUpdate()) {
        allowFailedTimes--;
        if (allowFailedTimes <= 0) {
          // 失败次数过多，停止播放
          allowFailedTimes = 3;
          pause();
          LogToast.error("加载失败!", "音乐惰性加载失败次数过多，暂停播放!",
              "[tryLazyLoadMusic] Failed to lazy load music to many times, stop playing.");
          return;
        } else {
          // 尝试播放下一首
          pause();
          await seekToNext();
          return;
        }
      }
    });
  }

  /// safe;
  /// lock;
  /// 惰性加载音乐, 每次切换音乐时调用, 这会加载对应index的音乐, 并且从头开始播放
  Future<void> _lazyLoadMusic(int index,
      {Quality? selectedQuality, bool force = false}) async {
    // 检查索引是否有效
    if (musicContainerList.isEmpty ||
        index < 0 ||
        index >= musicContainerList.length) {
      return;
    }

    MusicContainer targetMusicContainer = musicContainerList[index];

    // 如果不是强制更新, 且不需要更新, 则直接返回
    if (!force &&
        selectedQuality == null &&
        !targetMusicContainer.shouldUpdate()) {
      return;
    }

    // 先设置当前播放音乐, 用于ui立刻显示, 但是这时播放的是本地空音频
    playingMusic.value = targetMusicContainer;
    playingMusic.refresh();

    // 更新 MusicContainer
    if (!await targetMusicContainer.updateSelf(selectedQuality)) {
      globalLogger.info(
          "[AudioHandler.lazyLoadMusic] LazyLoad Music Failed to updateAudioSource: ${targetMusicContainer.musicAggregator.name}");
      return;
    }
    playingMusic.refresh();

    // 暂停播放器
    if (player.playing) await pause();

    // 更新 audioSourceList
    await listLock.synchronized(() async {
      await audioSourceList.clear();
      await audioSourceList
          .addAll(musicContainerList.map((e) => e.audioSource).toList());
    });

    // 跳转到播放音乐
    await seek(Duration.zero, index: index);

    globalLogger.info(
        "[AudioHanlder.lazyLoadMusic] LazyLoad Music Succeed: ${targetMusicContainer.musicAggregator.name}");
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
            selectedQuality: quality, force: true);
        playingMusic.refresh();
        await seek(position);
      }
    } catch (e) {
      globalLogger.error("[AudioHandler.replacePlayingMusic] $e");
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
      globalLogger.error("[AudioHandler.seekToNext] $e");
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
      globalLogger.error("[AudioHandler.seekToPrevious] $e");
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
      globalLogger.error("[AudioHandler] In pause, error occur: $e");
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

      globalLogger.info(
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
  int shouldSkip = 0;

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

    _startNotSkippintToNextFixMonitoring();
  }

  Duration seekDurationFromPercent(double percent) {
    return Duration(
        microseconds: (percent * duration.value.inMicroseconds).toInt());
  }

  // 用于修复播放器在播放结束后未自动切换到下一曲的问题
  void _startNotSkippintToNextFixMonitoring() {
    int consecutiveBugCount = 0;
    int lastPositionSeconds = position.value.inSeconds;

    Timer.periodic(Duration(seconds: 1), (timer) {
      int currentPosSec = position.value.inSeconds;
      int totalDurationSec = duration.value.inSeconds;

      // 忽略尚未开始播放的情况
      if (currentPosSec == 0) {
        lastPositionSeconds = currentPosSec;
        consecutiveBugCount = 0;
        return;
      }

      // Bug 情况1：当前位置超过或等于总时长。
      bool bugCase1 = currentPosSec >= totalDurationSec;

      // Bug 情况2：当曲目接近结束（剩余10秒内）且位置没有进展。
      bool bugCase2 = (totalDurationSec > 0 &&
          currentPosSec >= (totalDurationSec - 10) &&
          currentPosSec == lastPositionSeconds);

      if (bugCase1 || bugCase2) {
        consecutiveBugCount++;
        globalLogger.error(
            "[AudioUiController._startNotSkippintToNextFixMonitoring] 检测到Bug条件："
            "${bugCase1 ? "当前播放位置（${currentPosSec}s）已达到或超过曲目总时长（${totalDurationSec}s），可能播放已结束但未自动切换到下一曲" : "当前播放位置（${currentPosSec}s）接近曲目末尾（剩余不足10s）且未更新，可能是播放进度卡顿"}，连续出现 $consecutiveBugCount 次.");
        if (consecutiveBugCount >= 3) {
          consecutiveBugCount = 0;
          globalAudioHandler.seekToNext();
          globalLogger.error(
              "[AudioUiController._startNotSkippintToNextFixMonitoring] 连续3次检测到 Bug，触发 seekToNext().");
        }
      } else {
        consecutiveBugCount = 0;
      }

      lastPositionSeconds = currentPosSec;
    });
  }
}

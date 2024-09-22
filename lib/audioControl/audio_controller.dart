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

// 初始化所有和Audio相关的内容
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
}

// Windows 平台的just_audio实现存在bug
// 不能传入空的ConcatenatingAudioSource
// 因此使用
bool isWindowsFirstPlay = true;

class AudioHandler extends GetxController {
  final AudioPlayer player = AudioPlayer();
  final RxList<MusicContainer> musicList = RxList<MusicContainer>([]);
  final Rx<MusicContainer?> playingMusic = Rx<MusicContainer?>(null);
  final ConcatenatingAudioSource audioSourceList =
      ConcatenatingAudioSource(children: []);
  final audioSourceListLock = Lock();

  // 记录播放失败的次数，超过3次则暂停播放
  int allowFailedTimes = 3;
  AudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 先默认开启所有的循环
    player.setLoopMode(LoopMode.all);
    // 关闭随机播放
    player.setShuffleModeEnabled(false);
    // 监听错误事件并用talker来log
    player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      globalTalker.error('[PlaybackEventStream Error] $e');
    });

    // 将playSourceList交给player作为列表，不过目前是空的
    // 在windows平台无法提供一个空白的列表，会造成崩溃，故见后续特殊处理
    if (!Platform.isWindows) {
      player.setAudioSource(audioSourceList);
    }

    // 监听播放变化，当获取到一个index时(如歌曲播放下一首时，这里的index将是下一首的index
    player.currentIndexStream.listen((index) async {
      if (index == null || musicList.isEmpty) return;
      var shouldUpdate = true;
      if (index == 0 && lazyLoadLock.locked) shouldUpdate = false;
      // 先尝试LazyLoad这首歌
      await tryLazyLoadMusic(index);
      // 如果这首即将播放的音乐并仍没有正常LazyLoad，直接尝试播放下一首
      if (musicList[index].shouldUpdate()) {
        // 播放失败次数超过3次，暂停播放
        allowFailedTimes--;
        if (allowFailedTimes == 0) {
          // 重置失败次数
          allowFailedTimes = 3;
          if (isPlaying) await pause();
          LogToast.error("播放失败!", "播放失败次数过多，暂停播放!",
              "[LazyLoadMusic] Failed to lazy load music '${musicList[index].musicAggregator.name}' to many times, stop playing.");

          return;
        } else {
          if (isPlaying) await pause();
          await seekToNext();
          return;
        }
      }
      if (shouldUpdate) {
        updatePlayingMusic(music: musicList[index]);
      }
    });
  }

  var lazyLoadLock = Lock();
  // 用于lazyLoad audioSourceList中的音乐文件
  // 这个函数运行前后必须确保结束后歌曲仍播放正确的index
  // 这个函数只会在歌曲需要更新连接时更新，这取决于歌曲是否是一个空白状态抑或超出30分钟
  Future<void> tryLazyLoadMusic(int index,
      {Quality? quality, bool force = false}) async {
    if (musicList.isEmpty || index > musicList.length - 1) return;
    if (force == false && quality == null && !musicList[index].shouldUpdate()) {
      return;
    }
    try {
      // 确保同时只有一个LazyLoad运行
      await lazyLoadLock.synchronized(() async {
        var current = player.currentIndex;
        if (!await musicList[index].updateAll(quality)) {
          globalTalker.info(
              "[Music Handler] LazyLoad Music Failed to updateAudioSource: ${musicList[index].musicAggregator.name}");
          return;
        }
        // 先将播放器暂停下来
        if (player.playing) await pause();
        // 确保音频资源不会被两个并发函数同时使用
        await audioSourceListLock.synchronized(() async {
          if (audioSourceListLock.inLock) {
            await audioSourceList.clear();
            await audioSourceList
                .addAll(musicList.map((e) => e.audioSource).toList());
          } else {
            await audioSourceListLock.synchronized(() async {
              await audioSourceList.clear();
              await audioSourceList
                  .addAll(musicList.map((e) => e.audioSource).toList());
            });
          }
          // 更新音频资源后恢复原来的播放状态
          await player.seek(Duration.zero, index: current);
          play();
          globalTalker.info(
              "[Music Hanlder] LazyLoad Music Succeed: ${musicList[index].musicAggregator.name}");
        });
      });
    } catch (e) {
      globalTalker.error("[Music Handler] In LazyLoadMusic, Unknown Error: $e");
    }
  }

  // App内的手动执行的函数,可能出现首次播放不触发index流,故选择直接获取播放信息
  Future<void> addMusicPlay(MusicContainer musicContainer) async {
    try {
      // 由于是手动添加新的音乐，我们直接获取音乐链接并且添加到系统播放资源即可(直接添加到最后面)
      // 添加新的音乐到待播列表(直接添加到最后面)
      if (!await musicContainer.updateAll()) {
        return;
      }
      // 先暂停播放
      if (player.playing) await pause();
      await audioSourceListLock.synchronized(() async {
        // 删去原来的相同音乐并添加新的音乐到最后
        var index = musicList.indexWhere(
            (element) => element.hashCode == musicContainer.hashCode);
        if (index != -1) {
          musicList.removeAt(index);
          await audioSourceList.removeAt(index);
        }
        musicList.add(musicContainer);
        await audioSourceList.add(musicContainer.audioSource);
      });
      updatePlayingMusic(music: musicContainer);

      // windows平台的bug，不能添加空的audioSourceList
      if (Platform.isWindows && isWindowsFirstPlay) {
        await player.setAudioSource(audioSourceList);
        isWindowsFirstPlay = false;
      }

      // 播放新的音乐
      await seek(Duration.zero, index: audioSourceList.length - 1);
    } catch (e) {
      LogToast.error(
          "添加音乐播放失败",
          "添加音乐 '${musicContainer.musicAggregator.name}' 播放失败!",
          "[Music Handler] In addMusicPlay, error occur: $e");
    }
  }

  // App内手动触发，切换音质，主动更新播放资源
  Future<void> replacePlayingMusic(Quality quality_) async {
    try {
      if (playingMusic.value == null) return;
      int index = musicList.indexWhere(
          (element) => element.hashCode == playingMusic.value!.hashCode);

      if (index != -1) {
        await tryLazyLoadMusic(index, quality: quality_, force: true);
        update();
      }
    } catch (e) {
      globalTalker
          .error("[Music Handler]  In replacePlayingMusic, error occur: $e");
    }
  }

  // App内手动触发, 但选择使用index流来LazyLoad
  // 此函数用在下载/删除缓存时，对应替换musicList中的歌曲，因此出现不会首次播放的情况
  Future<void> replaceMusic(MusicContainer music) async {
    try {
      int index =
          musicList.indexWhere((element) => element.hashCode == music.hashCode);
      if (index != -1) {
        if (index == player.currentIndex) {
          await replacePlayingMusic(musicList[index].playInfo!.quality);
          // await tryLazyLoadMusic(index, force: true);
        } else {
          musicList[index].setOutdate();
        }
      }
    } catch (e) {
      globalTalker.error("[Music Handler]  In replaceMusic, error occur: $e");
    }
  }

  // App内手动触发，必定出现首次播放不触发index流的情况，故手动更新播放资源
  Future<void> clearReplaceMusicAll(List<MusicContainer> musics) async {
    if (musics.isEmpty) {
      return;
    }
    // 先暂停
    if (player.playing) {
      await pause();
    }
    // 清空已有的列表
    await clear();

    // 对于第一首音乐，主动获取其播放信息(因为无法触发index流)
    bool shouldSeekNext = !await musics[0].updateAll();
    // windows bug bypass
    if (Platform.isWindows && isWindowsFirstPlay) {
      await player.setAudioSource(audioSourceList);
      isWindowsFirstPlay = false;
    }
    musicList.addAll(musics);
    await audioSourceList.addAll(musics.map((e) => e.audioSource).toList());
    await seek(Duration.zero, index: 0);
    updatePlayingMusic(music: musics[0]);
    if (shouldSeekNext) await seekToNext();
  }

  Future<void> clear() async {
    if (player.playing) {
      await player.pause();
    }
    if (musicList.isNotEmpty) {
      musicList.clear();
    }
    if (audioSourceList.length > 0) {
      await audioSourceListLock.synchronized(() async {
        await audioSourceList.clear();
      });
    }
    if (playingMusic.value != null) {
      playingMusic.value = null;
      update();
    }
  }

  final _removeLock = Lock();
  Future<void> removeAt(int index) async {
    await _removeLock.synchronized(() async {
      if (player.playing &&
          player.currentIndex != null &&
          player.currentIndex! == index) {
        await player.pause();
      }
      musicList.removeAt(index);
      await audioSourceList.removeAt(index);
    });
  }

  final _seekToNextLock = Lock();
  Future<void> seekToNext() async {
    try {
      if (player.nextIndex == null) return;
      await _seekToNextLock.synchronized(() async {
        await player.seekToNext();
      });
    } catch (e) {
      globalTalker.error("[Music Handler] In seekToNext, error occur: $e");
    }
    play();
  }

  final _seekToPreviousLock = Lock();
  Future<void> seekToPrevious() async {
    try {
      if (player.previousIndex == null) return;
      await _seekToPreviousLock.synchronized(() async {
        await player.seekToPrevious();
      });
    } catch (e) {
      globalTalker.error("[Music Handler] In seekToPrevious, error occur: $e");
    }
    play();
  }

  Future<void> pause() async {
    try {
      await player.pause();
    } catch (e) {
      globalTalker.error("[Music Handler] In pause, error occur: $e");
    }
  }

  void play() async {
    try {
      // 直接运行在某些平台会导致完全无理由的中断后续代码执行，甚至没有任何报错或者返回(当然也不是阻塞)
      Future.microtask(() => player.play());
      // globalTalker.info("[Music Handler] In play, succeed");
    } catch (e) {
      globalTalker.error("[Music Handler] In play. error occur: $e");
    }
  }

  final _seekLock = Lock();
  Future<void> seek(Duration position, {int? index}) async {
    try {
      await _seekLock.synchronized(() async {
        if (player.playing) {
          await pause();
        }
        String name;
        if (index != null) {
          name = musicList[index].musicAggregator.name;
          await tryLazyLoadMusic(index);
        } else {
          name = playingMusic.value?.musicAggregator.name ?? "No Music";
        }
        await player.seek(position, index: index);
        play();
        globalTalker.info(
            "[Music Handler] In seek, Succeed; Seek to ${formatDuration(position.inSeconds)} of $name");
      });
    } catch (e) {
      globalTalker.error("[Music Handler] In seek, error occur: $e");
    }
  }

  void updatePlayingMusic({MusicContainer? music}) {
    // 再LazyLoad中触发的是不可信的，因为可能是在clear后触发的
    if (lazyLoadLock.locked ||
        (musicList.length > 1 && player.nextIndex == null)) return;
    if (music != null && !music.shouldUpdate()) {
      playingMusic.value = music;
    } else if (musicList.isNotEmpty &&
        player.currentIndex != null &&
        player.currentIndex! >= 0) {
      try {
        if (musicList[player.currentIndex!].shouldUpdate()) return;
        playingMusic.value = musicList[player.currentIndex!];
      } catch (e) {
        globalTalker
            .error("[Music Handler] Failed to updatePlayingMusic,set null");
        playingMusic.value = null;
      }
    } else {
      playingMusic.value = null;
    }
    globalTalker.info(
        "[Music Handler] Succeed to updatePlayingMusic:  [${playingMusic.value?.musicAggregator.defaultServer ?? "No music"}]${playingMusic.value?.musicAggregator.defaultServer ?? "No music"}");
    update();
  }

  bool get isPlaying {
    return player.playing;
  }
}

Future<void> initGlobalAudioUiController() async {
  globalAudioUiController = AudioUiController();
}

// 对接ui和播放设置,这些数据确实不得不全局记录，否则由于just audio的可能bug无法得知歌曲结束事件
// 这里的所有内容都只是为了保证ui随实际状态实时变化，而不应该对状态做变化
class AudioUiController extends GetxController {
  late Rx<PlayerState> playerState;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  Rx<double> playProgress = 0.0.obs;
  AudioUiController() {
    // 初始化late
    playerState = globalAudioHandler.player.playerState.obs;

    globalAudioHandler.player.playerStateStream.listen((event) {
      playerState.value = event;
      update();
    });

    // 在这里触发playbackevent状态变化
    globalAudioHandler.player.playbackEventStream.listen((event) {
      position.value = event.updatePosition;
      if (event.duration != null) {
        duration.value = event.duration!;
      }
      update();
    });

    // 在这里触发音乐总时长变化
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

  Duration getToSeek(double toSeek) {
    return Duration(
        microseconds: (toSeek * duration.value.inMicroseconds).toInt());
  }
}

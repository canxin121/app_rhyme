import 'dart:io';

import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/time_parse.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:synchronized/synchronized.dart';

// Windows 平台的just_audio实现存在bug
bool isWindowsFirstPlay = true;

late AudioHandler globalAudioHandler;
late AudioUiController globalAudioUiController;

// 初始化所有和Audio相关的内容
Future<void> initGlobalAudioHandler() async {
  if (!Platform.isWindows) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  globalAudioHandler = AudioHandler();
}

class AudioHandler extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  final RxList<Music> musicList = RxList<Music>([]);
  final Rx<Music?> playingMusic = Rx<Music?>(null);
  final ConcatenatingAudioSource audioSourceList =
      ConcatenatingAudioSource(children: []);
  final audioSourceListLock = Lock();

  AudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 先默认开启所有的循环
    _player.setLoopMode(LoopMode.all);
    // 关闭随机播放
    _player.setShuffleModeEnabled(false);
    // 监听错误事件并用talker来log
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      talker.error('[PlaybackEventStream Error] $e');
    });

    // 将playSourceList交给player作为列表，不过目前是空的
    // 在windows平台无法提供一个空白的列表，会造成崩溃，故见后续特殊处理
    if (!Platform.isWindows) {
      _player.setAudioSource(audioSourceList);
    }

    // 监听播放变化，当获取到一个index时(如歌曲播放下一首时，这里的index将是下一首的index
    _player.currentIndexStream.listen((index) async {
      if (index == null || musicList.isEmpty) return;
      var shouldUpdate = true;
      if (index == 0 && lazyLoadLock.locked) shouldUpdate = false;
      // 先尝试LazyLoad这首歌
      await tryLazyLoadMusic(index);
      // 如果这首即将播放的音乐并仍没有正常LazyLoad，直接尝试播放下一首
      if (musicList[index].shouldUpdate()) {
        if (isPlaying) await pause();
        await seekToNext();
        return;
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
        var current = _player.currentIndex;
        if (!await musicList[index].updateAudioSource(quality)) {
          talker.info(
              "[Music Handler] LazyLoad Music Failed to updateAudioSource: ${musicList[index].info.name}");
          return;
        }
        // 先将播放器暂停下来
        if (_player.playing) await pause();
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
          await _player.seek(Duration.zero, index: current);
          play();
          talker.info(
              "[Music Hanlder] LazyLoad Music Succeed: ${musicList[index].info.name}");
        });
      });
    } catch (e) {
      talker.error("[Music Handler] In LazyLoadMusic, Unknown Error: $e");
    }
  }

  // App内的手动执行的函数,可能出现首次播放不触发index流,故选择直接获取播放信息
  Future<void> addMusicPlay(Music music) async {
    try {
      // 由于是手动添加新的音乐，我们直接获取音乐链接并且添加到系统播放资源即可(直接添加到最后面)
      // 添加新的音乐到待播列表(直接添加到最后面)
      if (!await music.updateAudioSource()) {
        talker.info(
            "[Music Handler] In addMusicPlay, Failed to updateAudioSource: ${music.info.name}");
        return;
      }
      // 先暂停播放
      if (_player.playing) await pause();
      // 删去原来的相同音乐并添加新的音乐到最后
      await audioSourceListLock.synchronized(() async {
        var index = musicList.indexWhere((element) =>
            element.extra ==
            music.ref.getExtraInto(quality: music.info.defaultQuality!));
        if (index != -1) {
          musicList.removeAt(index);
          await audioSourceList.removeAt(index);
        }
        musicList.add(music);
        await audioSourceList.add(music.audioSource);
      });
      updatePlayingMusic(music: music);

      // windows平台的bug，不能添加空的audioSourceList
      if (Platform.isWindows && isWindowsFirstPlay) {
        await _player.setAudioSource(audioSourceList);
        isWindowsFirstPlay = false;
      }

      // 播放新的音乐
      await seek(Duration.zero, index: audioSourceList.length - 1);
    } catch (e) {
      talker.error("[Music Handler] In addMusicPlay, Error occur: $e");
    }
  }

  // App内手动触发，切换音质，主动更新播放资源
  Future<void> replacePlayingMusic(Quality quality_) async {
    try {
      if (playingMusic.value == null) return;
      int index = musicList
          .indexWhere((element) => element.extra == playingMusic.value!.extra);

      if (index != -1) {
        await tryLazyLoadMusic(index, quality: quality_, force: true);
        update();
      }
    } catch (e) {
      talker.error("[Music Handler]  In replacePlayingMusic, error occur: $e");
    }
  }

  // App内手动触发, 但选择使用index流来LazyLoad
  // 此函数用在下载/删除缓存时，对应替换musicList中的歌曲，因此出现不会首次播放的情况
  Future<void> replaceMusic(Music music) async {
    try {
      int index =
          musicList.indexWhere((element) => element.extra == music.extra);
      if (index != -1) {
        if (index == _player.currentIndex) {
          await replacePlayingMusic(musicList[index].info.defaultQuality!);
          // await tryLazyLoadMusic(index, force: true);
        } else {
          musicList[index].empty = true;
        }
      }
    } catch (e) {
      talker.error("[Music Handler]  In replaceMusic, error occur: $e");
    }
  }

  final Lock _clearReplaceMusicAllock = Lock();
  // App内手动触发，必定出现首次播放不触发index流的情况，故手动更新播放资源
  Future<void> clearReplaceMusicAll(
      BuildContext context, List<Music> musics) async {
    if (musics.isEmpty) {
      return;
    }
    await _clearReplaceMusicAllock.synchronized(() async {
      // 先暂停
      if (_player.playing) {
        await pause();
      }
      // 清空已有的列表
      await clear();

      // 对于第一首音乐，主动获取其播放信息(因为无法触发index流)
      bool shouldSeekNext = !await musics[0].updateAudioSource();
      musicList.add(musics[0]);
      await audioSourceListLock.synchronized(() async {
        await audioSourceList.add(musics[0].audioSource);
      });
      updatePlayingMusic(music: musics[0]);
      // windows bug bypass
      if (Platform.isWindows && isWindowsFirstPlay) {
        await _player.setAudioSource(audioSourceList);
        isWindowsFirstPlay = false;
      }

      play();
      // 接下来将剩下的所有的音乐添加进去，但是先不获取链接，使用lazy load
      musicList.addAll(musics.sublist(1));

      try {
        await audioSourceListLock.synchronized(() async {
          await audioSourceList
              .addAll(musics.sublist(1).map((e) => e.audioSource).toList());
        });
      } catch (e) {
        talker
            .error("[Music Handler] In clearReplaceMusicAll, Error occur: $e");
      }
      if (shouldSeekNext) await seekToNext();
      log2List("In clearReplaceMusicAll, After add all");
    });
  }

  Future<void> clear() async {
    // talker.info("[Music Handler] Request to clear all musics");
    if (musicList.isNotEmpty) {
      musicList.clear();
    }
    if (audioSourceList.length > 0) {
      await audioSourceListLock.synchronized(() async {
        talker.info("[Music Handler] clear获取锁");
        await audioSourceList.clear();
        talker.info("[Music Handler] clear释放锁");
      });
    }
    log2List("Afer Clear all musics");
  }

  final _removeLock = Lock();
  Future<void> removeAt(int index) async {
    await _removeLock.synchronized(() async {
      if (_player.playing &&
          _player.currentIndex != null &&
          _player.currentIndex! == index) {
        await _player.pause();
      }
      musicList.removeAt(index);
      await audioSourceList.removeAt(index);
    });
  }

  final _seekToNextLock = Lock();
  Future<void> seekToNext() async {
    try {
      if (_player.nextIndex == null) return;
      await _seekToNextLock.synchronized(() async {
        await _player.seekToNext();
      });
    } catch (e) {
      talker.error("[Music Handler] In seekToNext, error occur: $e");
    }
    play();
  }

  final _seekToPreviousLock = Lock();
  Future<void> seekToPrevious() async {
    try {
      if (_player.previousIndex == null) return;
      await _seekToPreviousLock.synchronized(() async {
        await _player.seekToPrevious();
      });
    } catch (e) {
      talker.error("[Music Handler] In seekToPrevious, error occur: $e");
    }
    play();
  }

  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      talker.error("[Music Handler] In pause, error occur: $e");
    }
  }

  void play() async {
    try {
      // 直接运行在某些平台会导致完全无理由的中断后续代码执行，甚至没有任何报错或者返回(当然也不是阻塞)
      Future.microtask(() => _player.play());
      // talker.info("[Music Handler] In play, succeed");
    } catch (e) {
      talker.error("[Music Handler] In play. error occur: $e");
    }
  }

  final _seekLock = Lock();
  Future<void> seek(Duration position, {int? index}) async {
    try {
      await _seekLock.synchronized(() async {
        if (_player.playing) {
          await pause();
        }
        String name;
        if (index != null) {
          name = musicList[index].info.name;
          await tryLazyLoadMusic(index);
        } else {
          name = playingMusic.value?.info.name ?? "No Music";
        }
        await _player.seek(position, index: index);
        play();
        talker.info(
            "[Music Handler] In seek, Succeed; Seek to ${formatDuration(position.inSeconds)} of $name");
      });
    } catch (e) {
      talker.error("[Music Handler] In seek, error occur: $e");
    }
  }

  void updatePlayingMusic({Music? music}) {
    // 再LazyLoad中触发的是不可信的，因为可能是在clear后触发的
    if (lazyLoadLock.locked ||
        (musicList.length > 1 && _player.nextIndex == null)) return;
    if (music != null && !music.shouldUpdate()) {
      playingMusic.value = music;
    } else if (musicList.isNotEmpty &&
        _player.currentIndex != null &&
        _player.currentIndex! >= 0) {
      try {
        if (musicList[_player.currentIndex!].shouldUpdate()) return;
        playingMusic.value = musicList[_player.currentIndex!];
      } catch (e) {
        talker.error("[Music Handler] Failed to updateRx,set null");
        playingMusic.value = null;
      }
    } else {
      playingMusic.value = null;
    }
    talker.info(
        "[Music Handler] Called updateRx: playingMusic: ${playingMusic.value?.info.name ?? "No music"}");
    update();
  }

  void log2List(String prefix) {
    String playListStr =
        musicList.map((element) => element.info.name).join(",");
    String sourceListStr =
        audioSourceList.sequence.map((e) => e.tag.title).join(",");
    if (playListStr == sourceListStr) {
      talker.log(
          "[Music Handler] $prefix: PlayList = PlaySourceList, length = ${musicList.length}, content = [$playListStr]");
    } else {
      talker.error(
          "[Music Handler] $prefix: PlayList != PlaySourceList\nPlayList = length: ${musicList.length}, content = [$playListStr]\nPlaySourceList: length = ${audioSourceList.length},content = [$audioSourceList]");
    }
  }

  bool get isPlaying {
    return _player.playing;
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
    playerState = globalAudioHandler._player.playerState.obs;

    globalAudioHandler._player.playerStateStream.listen((event) {
      playerState.value = event;
      update();
    });

    // 在这里触发playbackevent状态变化
    globalAudioHandler._player.playbackEventStream.listen((event) {
      position.value = event.updatePosition;
      if (event.duration != null) {
        duration.value = event.duration!;
      }
      update();
    });

    // 在这里触发音乐总时长变化
    globalAudioHandler._player.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration.value = newDuration;
        playProgress.value =
            position.value.inMicroseconds / duration.value.inMicroseconds;
        update();
      }
    });
    globalAudioHandler._player.positionDiscontinuityStream.listen((event) {
      position.value = event.event.updatePosition;
      playProgress.value =
          position.value.inMicroseconds / duration.value.inMicroseconds;
      update();
    });
    globalAudioHandler._player.positionStream.listen((event) {
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

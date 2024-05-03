import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

DateTime lastComplete = DateTime(1999);

late AudioHandler globalAudioHandler;
late AudioUiController globalAudioUiController;

// 初始化所有和Audio相关的内容
Future<void> initGlobalAudioHandler() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());

  globalAudioHandler = AudioHandler();
}

class AudioHandler extends GetxController {
  final AudioPlayer _player = AudioPlayer();
  // 这两个本质都是list，但是我们需要确保其同步变化
  final RxList<PlayMusic> playMusicList = RxList<PlayMusic>([]);
  final Rx<PlayMusic?> playingMusic = Rx<PlayMusic?>(null);
  final ConcatenatingAudioSource playSourceList =
      ConcatenatingAudioSource(children: []);

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
    _player.setAudioSource(playSourceList);

    _player.currentIndexStream.listen((event) {
      talker.info("[Music Handler] currentIndexStream updated");
      updateRx();
    });
  }

  AudioHandler() {
    _init();
  }

  Future<void> addMusicPlay(DisplayMusic music) async {
    try {
      PlayMusic? playMusic;
      var index = -1;
      if (music.info.defaultQuality != null) {
        index = playMusicList.indexWhere((element) =>
            element.extra ==
            music.ref.getExtraInto(quality: music.info.defaultQuality!));
      }
      if (index != -1) {
        playMusic = playMusicList.removeAt(index);
        playSourceList.removeAt(index);
      } else {
        playMusic = await display2PlayMusic(music);
      }

      if (playMusic == null) return;

      // 添加新的音乐
      playMusicList.add(playMusic);
      if (playMusic.playInfo.file.contains("http")) {
        await playSourceList.add(AudioSource.uri(
            Uri.parse(playMusic.playInfo.file),
            tag: playMusic.toMediaItem()));
      } else {
        await playSourceList.add(AudioSource.file(playMusic.playInfo.file,
            tag: playMusic.toMediaItem()));
      }

      // 播放新的音乐
      await seek(Duration.zero, index: playSourceList.length - 1);

      updateRx();
      await play();
    } catch (e) {
      talker.error("[Music Handler] In addMusicPlay, Error occur: $e");
    }
  }

  Future<void> replaceMusic(PlayMusic playMusic) async {
    try {
      int index = playMusicList
          .indexWhere((element) => element.extra == playMusic.extra);
      bool shouldPlay = index == _player.currentIndex;
      if (index != -1) {
        // 删除对应位置的音乐
        await removeAt(index);
        // 插入新音乐到对应位置
        await _insert(index, playMusic);
        if (shouldPlay) {
          // 重新播放这个位置的音乐
          await seek(Duration.zero, index: index);
          updateRx();
          await play();
        }
      }
    } catch (e) {
      talker.error(
          "[Music Handler]  In replaceMusic, Failed to display2PlayMusic: $e");
    }
  }

  Future<void> clearReplaceMusicAll(List<DisplayMusic> musics) async {
    talker.info(
        "[Music Handler] Request to add all musics of length: ${musics.length}");
    List<PlayMusic> newPlayMusics = [];
    List<AudioSource> newAudioSources = [];
    List<Future<PlayMusic?>> futures = [];

    // 首先创建所有的future，但不等待它们
    for (var music in musics) {
      futures.add(display2PlayMusic(music));
    }

    // 然后等待所有future完成，并按顺序处理结果
    List<PlayMusic?> playMusicsResults = await Future.wait(futures);
    for (var playMusic in playMusicsResults) {
      if (playMusic == null) continue;
      newPlayMusics.add(playMusic);

      if (playMusic.playInfo.file.contains("http")) {
        newAudioSources.add(AudioSource.uri(Uri.parse(playMusic.playInfo.file),
            tag: playMusic.toMediaItem()));
      } else {
        newAudioSources.add(AudioSource.file(playMusic.playInfo.file,
            tag: playMusic.toMediaItem()));
      }
    }

    await clear();

    playMusicList.addAll(newPlayMusics);
    try {
      await playSourceList.addAll(newAudioSources);
    } catch (e) {
      talker.error(
          "[Music Handler] In clearReplaceMusicAll, Failed to diaplayMusic2PlayMusic: $e");
    }

    await seek(Duration.zero, index: 0);

    updateRx();
    log2List("After add all");
    await play();
  }

  Future<void> _insert(int index, PlayMusic music) async {
    playMusicList.insert(index, music);
    await playSourceList.insert(
        index,
        AudioSource.uri(Uri.parse(music.playInfo.file),
            tag: music.toMediaItem()));
  }

  Future<void> clear() async {
    talker.info("[Music Handler] Request to clear all musics");
    if (playMusicList.isNotEmpty) {
      playMusicList.clear();
    }
    if (playSourceList.length > 0) {
      await playSourceList.clear();
      update();
    }
    updateRx();
    log2List("Afer Clear all musics");
  }

  Future<void> removeAt(int index) async {
    talker.info("[Music Handler] Request to remove music of index:$index");
    if (_player.currentIndex != null && _player.currentIndex! == index) {
      await _player.pause();
    }
    playMusicList.removeAt(index);
    await playSourceList.removeAt(index);
    updateRx();
  }

  Future<void> seekToNext() async {
    try {
      await _player.seekToNext();
      talker.info("[Music Handler] In seekToNext, Succeed");
    } catch (e) {
      talker.error("[Music Handler] In seekToNext, error occur: $e");
    }
    updateRx();
    await play();
  }

  Future<void> seekToPrevious() async {
    try {
      await _player.seekToPrevious();
      talker.info("[Music Handler] In seekToPrevious, Succeed");
    } catch (e) {
      talker.error("[Music Handler] In seekToPrevious, error occur: $e");
    }
    updateRx();
    await play();
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      talker.info("[Music Handler] In pause, succeed");
    } catch (e) {
      talker.error("[Music Handler] In pause, error occur: $e");
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
      talker.info("[Music Handler] In play, succeed");
    } catch (e) {
      talker.error("[Music Handler] In play. error occur: $e");
    }
  }

  Future<void> seek(Duration position, {int? index}) async {
    try {
      await _player.seek(position, index: index);
      talker.info("[Music Handler] In seek, Succeed");
    } catch (e) {
      talker.error("[Music Handler] In seek, error occur: $e");
    }
  }

  Stream<Duration> createPositionStream({
    int steps = 800,
    Duration minPeriod = const Duration(milliseconds: 200),
    Duration maxPeriod = const Duration(milliseconds: 200),
  }) {
    return _player.createPositionStream(
        steps: steps, minPeriod: minPeriod, maxPeriod: maxPeriod);
  }

  void updateRx() {
    if (playMusicList.isNotEmpty && _player.currentIndex != null) {
      try {
        playingMusic.value = playMusicList[_player.currentIndex!];
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
        playMusicList.map((element) => element.info.name).join(",");
    String sourceListStr =
        playSourceList.sequence.map((e) => e.tag.title).join(",");
    String msg;
    if (playListStr == sourceListStr) {
      talker.log(
          "[Music Handler] $prefix: PlayList = PlaySourceList, length = ${playMusicList.length}, content = [$playListStr]");
    } else {
      talker.error(
          "[Music Handler] $prefix: PlayList != PlaySourceList\nPlayList = length: ${playMusicList.length}, content = [$playListStr]\nPlaySourceList: length = ${playSourceList.length},content = [$playSourceList]");
    }
  }

  bool isPlaying() {
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
    globalAudioHandler._player
        .createPositionStream(
            maxPeriod: const Duration(milliseconds: 100),
            minPeriod: const Duration(milliseconds: 1))
        .listen((newPosition) {
      position.value = newPosition;
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

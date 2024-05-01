import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/types/music.dart';
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
    // 监听错误事件并用talker来log
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      talker.error('[PlaybackEventStream Error] $e');
    });
    // 将playSourceList交给player作为列表，不过目前是空的
    _player.setAudioSource(playSourceList);
  }

  AudioHandler() {
    _init();
  }

  Future<void> addMusicPlay(DisplayMusic music) async {
    try {
      PlayMusic playMusic;
      try {
        playMusic = await display2PlayMusic(music);
      } catch (e) {
        talker.error(
            "[Error Music Handler] In addMusicPlay, Failed to diaplayMusic2PlayMusic: $e");
        return;
      }

      var index = playMusicList
          .indexWhere((element) => element.extra == playMusic.extra);
      if (index != -1) {
        playMusicList.removeAt(index);
        playSourceList.removeAt(index);
      }

      // 添加新的音乐
      playMusicList.add(playMusic);
      await playSourceList.add(AudioSource.uri(
          Uri.parse(playMusic.playInfo.file),
          tag: playMusic.toMediaItem()));

      playingMusic.value = playMusic;
      update();

      // 播放新的音乐
      await _player.seek(Duration.zero, index: playSourceList.length - 1);

      await _player.play();
    } catch (e) {
      talker.error("[Error Music Handler] In addMusicPlay, Error occur: $e");
    }
    // 先检查是否已有这个音乐，如果已有，删除掉原有的
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
          await _player.seek(Duration.zero, index: index);
          await _player.play();
          playingMusic.value = playMusic;
          update();
        }
      }
    } catch (e) {
      talker.error(
          "[Error Music Handler]  In replaceMusic, Failed to display2PlayMusic: $e");
    }
  }

  Future<void> clearReplaceMusicAll(List<DisplayMusic> musics) async {
    talker.log(
        "[Log Music Handler] Request to add all musics of length: ${musics.length}");
    List<PlayMusic> newPlayMusics = [];
    List<AudioSource> newAudioSources = [];
    for (var music in musics) {
      try {
        var playMusic = await display2PlayMusic(music);
        newPlayMusics.add(playMusic);
        newAudioSources.add(AudioSource.uri(Uri.parse(playMusic.playInfo.file),
            tag: playMusic.toMediaItem()));
      } catch (e) {
        talker.error(
            "[Error Music Handler] In clearReplaceMusicAll, Failed to diaplayMusic2PlayMusic: $e");
      }
    }

    await clear();

    playMusicList.addAll(newPlayMusics);
    try {
      // await player
      //     .setAudioSource(ConcatenatingAudioSource(children: newAudioSources));
      await playSourceList.addAll(newAudioSources);
    } catch (e) {
      talker.error(
          "[Error Music Handler] In clearReplaceMusicAll, Failed to diaplayMusic2PlayMusic: $e");
    }
    talker.log(
        "[Log Music Handler] After add all: crt playMusicList length:${playMusicList.length},crt playSourceList length:${playSourceList.length}");
    await _player.seek(Duration.zero, index: playSourceList.length - 1);

    await _player.play();

    playingMusic.value = playMusicList[playMusicList.length - 1];
    update();
  }

  Future<void> _insert(int index, PlayMusic music) async {
    playMusicList.insert(index, music);
    await playSourceList.insert(
        index,
        AudioSource.uri(Uri.parse(music.playInfo.file),
            tag: music.toMediaItem()));
  }

  Future<void> clear() async {
    talker.log("[Log Music Handler] Request to clear all musics");
    if (playMusicList.isNotEmpty) {
      playMusicList.clear();
    }
    if (playSourceList.length > 0) {
      await playSourceList.clear();
      update();
    }
    playingMusic.value = null;
  }

  Future<void> removeAt(int index) async {
    talker.log("[Log Music Handler] Request to remove music of index:$index");
    // 如果正在播放，先暂停
    if (_player.currentIndex != null && _player.currentIndex! == index) {
      await _player.pause();
      playingMusic.value = null;
      update();
    }
    playMusicList.removeAt(index);
    await playSourceList.removeAt(index);
  }

  // PlayMusic? playingMusic.value {
  //   if (player.currentIndex != null &&
  //       player.currentIndex != -1 &&
  //       playMusicList.isNotEmpty) {
  //     try {
  //       return playMusicList[player.currentIndex!];
  //     } catch (e) {
  //       talker.error(
  //           "[Error Music Handler] Failed to get playingMusic when index is not null: $e");
  //     }
  //   }
  //   return null;
  // }
  Future<void> seekToNext() async {
    await _player.seekToNext();
    if (_player.currentIndex != null) {
      playingMusic.value = playMusicList[_player.currentIndex!];
      update();
    }
  }

  Future<void> seekToPrevious() async {
    await _player.seekToPrevious();
    if (_player.currentIndex != null) {
      playingMusic.value = playMusicList[_player.currentIndex!];
      update();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> seek(Duration position, [int? index]) async {
    await _player.seek(position, index: index);
  }

  Stream<Duration> createPositionStream({
    int steps = 800,
    Duration minPeriod = const Duration(milliseconds: 200),
    Duration maxPeriod = const Duration(milliseconds: 200),
  }) {
    return _player.createPositionStream(
        steps: steps, minPeriod: minPeriod, maxPeriod: maxPeriod);
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

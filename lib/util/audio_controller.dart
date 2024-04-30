import 'dart:async';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/types/play_music_queue.dart';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

DateTime lastComplete = DateTime(1999);

late AudioServiceHandler globalAudioServiceHandler;
late AudioUiController globalAudioUiController;
Future<void> initGlobalAudioServiceHandler() async {
  globalAudioServiceHandler = await AudioService.init(
    builder: () => AudioServiceHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
}

// 应该实现所有的播放和控制，但是完全不关心ui如何
class AudioServiceHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer player = AudioPlayer();
  final PlayMusicQueue musicQueue = PlayMusicQueue();
  int playingMusicIndex = 0;

  AudioServiceHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // 这里受制于需要两个变量做判断，所以流移动到 UiController中去了
  Future<void> actionWhenComplete() async {
    await skipToNext();
  }

  // 处理播放逻辑
  Future<bool> _trySetSourcePlay(PlayMusic? music) async {
    // 先确保播放状态重置
    if (player.playing) {
      await pause();
    }
    // 开始设置新歌曲
    if (music != null) {
      String toPlaySource = music.playInfo.file;
      var tag = music.item;
      // 设置播放资源
      await player.setAudioSource(AudioSource.uri(Uri.parse(toPlaySource)));
      // 设置系统显示
      // 这里的mediaItem是AudioService内部的
      mediaItem.add(tag);
      // 开始播放
      await play();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> replaceAllMusic(List<DisplayMusic> musics) async {
    if (player.playing) {
      await pause();
    }
    var music = await musicQueue.replaceAllMusics(musics);
    return _trySetSourcePlay(music);
  }

  Future<bool> replaceMusic(PlayMusic music) async {
    var music_ = await musicQueue.replaceMusic(music);
    if (music_ != null) {
      return _trySetSourcePlay(music_);
    } else {
      return true;
    }
  }

  Future<bool> delMusic(int index) async {
    PlayMusic? music = musicQueue.delIndex(index);
    return await _trySetSourcePlay(music);
  }

  Future<bool> skipToMusic(int index) async {
    PlayMusic? music = musicQueue.skipToMusic(index);
    return await _trySetSourcePlay(music);
  }

  Future<bool> addMusicPlay(
    DisplayMusic music,
  ) async {
    PlayMusic? music_ = await musicQueue.addMusic(
      music,
    );
    return await _trySetSourcePlay(music_);
  }

  Future<bool> tryChangePlayingMusicQuality(Quality quality) async {
    PlayMusic? music = await musicQueue.changeCurrentPlayingQuality(quality);
    return await _trySetSourcePlay(music);
  }

  // 以下实际上是为 系统控制提供调用
  @override
  Future<bool> skipToNext() async {
    PlayMusic? music = musicQueue.skipToNext();
    return await _trySetSourcePlay(music);
  }

  @override
  Future<bool> skipToPrevious() async {
    PlayMusic? music = musicQueue.skipToPrevious();
    return await _trySetSourcePlay(music);
  }

  @override
  Future<bool> skipToQueueItem(int index) async {
    PlayMusic? music = musicQueue.skipToMusic(index);
    return await _trySetSourcePlay(music);
  }

  @override
  Future<void> play() async {
    await player.play();
    Future.delayed(const Duration(microseconds: 500)).then((value) {
      if (!player.playing) {
        play();
      }
    });
  }

  @override
  Future<void> pause() async {
    try {
      await player.pause();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.seek
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
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
    playerState = globalAudioServiceHandler.player.playerState.obs;
    // 在这里触发playbackevent状态变化
    globalAudioServiceHandler.player.playbackEventStream.listen((event) {
      position.value = event.updatePosition;
      if (event.duration != null) {
        duration.value = event.duration!;
      }
      update();
    });

    // 在这里触发播放状态变化
    globalAudioServiceHandler.player.playerStateStream.listen((state) {
      playerState.value = state;
      // 检测播放结束的逻辑,这里实际上的执行者还是AudioServiceHandler
      if (state.processingState == ProcessingState.completed) {
        if (DateTime.now().difference(lastComplete).inSeconds > 3) {
          lastComplete = DateTime.now();
          globalAudioServiceHandler.actionWhenComplete();
        }
      } else if (position.value.inSeconds > 1 &&
          (position.value > duration.value ||
              (duration.value - position.value).abs().inMicroseconds < 1000)) {
        if (DateTime.now().difference(lastComplete).inSeconds > 3) {
          lastComplete = DateTime.now();
          globalAudioServiceHandler.actionWhenComplete();
        }
      }
    });

    // 在这里触发音乐总时长变化
    globalAudioServiceHandler.player.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration.value = newDuration;
        playProgress.value =
            position.value.inMicroseconds / duration.value.inMicroseconds;
        update();
      }
    });
    globalAudioServiceHandler.player
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

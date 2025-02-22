import 'dart:io';
import 'package:app_rhyme/src/rust/api/cache/music_cache.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/src/rust/api/types/playinfo.dart';
import 'package:app_rhyme/types/log_toast.dart';
import 'package:audio_service/audio_service.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:just_audio/just_audio.dart';

// 音乐容器, 初始audioSource指向本地空白音频, 在需要播放时更新播放链接以及歌词
// 这里需要考虑 音乐和歌词是否已经缓存, 如果已经缓存, 则更新为本地缓存的地址
class MusicContainer {
  late MusicAggregator musicAggregator;
  late int currentMusicIndex;
  late AudioSource audioSource;

  PlayInfo? playinfo;
  String? lyric;
  // 记录已经使用的音乐源, 以自动切换到下一个可用的音乐源
  List<MusicServer> usedServers = [];
  DateTime lastUpdateDateTime = DateTime(1999);

  MusicContainer(MusicAggregator musicAgg) {
    musicAggregator = musicAgg;
    currentMusicIndex = 0;
    audioSource = AudioSource.asset("assets/blank.mp3", tag: _genMediaItem());
  }

  Music get currentMusic => musicAggregator.musics[currentMusicIndex];

  /// safe
  /// 将音频资源的最后更新时间设置为当前时间
  void _updateLastUpdateTime() {
    lastUpdateDateTime = DateTime.now();
  }

  /// safe
  /// 标记音频资源过期
  /// 使得下次播放时会重新获取音频资源
  void setOutdate() {
    lastUpdateDateTime = DateTime(1999);
  }

  /// safe
  // 以下情况需要更新音频资源
  // 1. 音频资源为本地空白音频
  // 2. 上次更新时间超过30分钟
  bool shouldUpdate() {
    try {
      return (audioSource as ProgressiveAudioSource)
              .uri
              .path
              .contains("/assets/") ||
          DateTime.now().difference(lastUpdateDateTime).inSeconds.abs() >= 1800;
    } catch (_) {
      return true;
    }
  }

  /// safe
  /// 更新音频资源
  Future<bool> updateSelf([Quality? selectedQuality]) async {
    await _updatePlayAndLyricInfoAutoChangeSource(selectedQuality);
    await _updateAudioSource();
    return playinfo != null;
  }

  /// safe
  Future<PlayInfo?> _updatePlayAndLyricInfoAutoChangeSource(
      [Quality? quality]) async {
    while (true) {
      var newPlayinfo = await _getUpdatePlayInfoAndLyric(quality);
      // playInfo ??= await getUpdatePlayInfoAndLyric(quality);
      playinfo = newPlayinfo;
      if (playinfo != null) {
        return playinfo;
      } else {
        bool changed = await changeMusicServer();
        if (!changed) {
          return null;
        }
      }
    }
  }

  /// safe
  /// 更新音频资源+歌词
  Future<PlayInfo?> _getUpdatePlayInfoAndLyric(
      [Quality? selectedQuality]) async {
    // 如果音乐没有音质, 则无法获取播放信息
    if (currentMusic.qualities.isEmpty) {
      LogToast.error("获取播放信息", "获取播放信息失败: 无音质可选",
          "[getUpdateMusicPlayInfo] Failed to get play info, no qualities");
      return null;
    }

    // 如果音乐已经缓存, 则直接使用缓存
    var musicCache = await getCacheMusic(
        name: musicAggregator.name,
        artists: musicAggregator.artist,
        documentFolder: globalDocumentPath);
    playinfo = musicCache.$1;
    lyric = musicCache.$2;

    if (globalConfig.externalApi == null) {
      LogToast.error("获取播放信息失败", "未导入第三方音乐源，无法在线获取播放信息",
          "[getUpdateMusicPlayInfo] Failed to get play info, no extern api");
      return null;
    }

    final playinfoFuture = playinfo == null
        ? globalExternalApiEvaler!.getMusicPlayInfo(currentMusic,
            selectedQuality ?? autoPickQuality(currentMusic.qualities))
        : Future.value(playinfo);
    final lyricFuture = lyric == null
        ? currentMusic.getLyric().catchError((e) {
            return "[00:00.00]在线获取歌词失败";
          })
        : Future.value(lyric);

    final results = await Future.wait([lyricFuture, playinfoFuture]);
    lyric = results[0] as String?;
    playinfo = results[1] as PlayInfo?;

    if (playinfo == null) {
      globalLogger.error(
              "[getUpdateMusicPlayInfo] 第三方音乐源无法获取到playinfo: [${currentMusic.server}]${currentMusic.name}");
      return null;
    }

    _updateLastUpdateTime();
    return playinfo;
  }

  /// safe
  MediaItem _genMediaItem() {
    final artUri =
        currentMusic.cover != null ? Uri.parse(currentMusic.cover!) : null;
    return MediaItem(
        id: currentMusic.hashCode.toString(),
        title: currentMusic.name,
        album: currentMusic.album,
        artUri: artUri,
        artist: currentMusic.artists.map((e) => e.name).join(","));
  }

  /// safe
  Future<void> _updateAudioSource() async {
    final isHttpSource = playinfo!.uri.contains("http");
    final isMacIosAndFlac = (Platform.isIOS || Platform.isMacOS) &&
        ((playinfo!.quality.format != null &&
                playinfo!.quality.format!.contains("flac")) ||
            (playinfo!.quality.summary.contains("flac")));

    final uri =
        isHttpSource ? Uri.parse(playinfo!.uri) : Uri.file(playinfo!.uri);

    final audioSourceOptions = isMacIosAndFlac
        ? const ProgressiveAudioSourceOptions(
            darwinAssetOptions:
                DarwinAssetOptions(preferPreciseDurationAndTiming: true))
        : null;

    audioSource = ProgressiveAudioSource(
      uri,
      tag: _genMediaItem(),
      options: audioSourceOptions,
    );

    globalLogger.info(
        "[MusicContainer._updateAudioSource] 更新 '${musicAggregator.name}' AudioSource 成功, isHttpSource: $isHttpSource, isMacIosAndFlac: $isMacIosAndFlac");
  }

  /// 切换音乐源
  /// 这会改变db中的默认音源
  Future<bool> changeMusicServer([MusicServer? server]) async {
    usedServers.add(currentMusic.server);
    server ??= nextSource(usedServers);

    if (server == null) {
      LogToast.error("切换音乐源失败", "无法切换音乐源: 未指定音源或无更多音源可切换",
          "[MusicContainer] Failed to change music source: No available source");
      return false;
    }

    if (!musicAggregator.musics.any((e) => e.server == server)) {
      try {
        musicAggregator =
            await musicAggregator.fetchServerOnline(servers: [server]);
      } catch (e) {
        LogToast.error("切换音乐源失败", "'${musicAggregator.name}'切换音乐源失败: $e",
            "[MusicContainer] Failed to change music source: $e");
        return false;
      }
    }

    final index = musicAggregator.musics.indexWhere((e) => e.server == server);
    if (index == -1) {
      LogToast.error(
        "切换音乐源失败",
        "'${musicAggregator.name}'在$server中找不到对应歌曲.",
        "[MusicContainer] Failed to change music source: Cannot find '${musicAggregator.name}' in $server",
      );
      return false;
    }

    currentMusicIndex = index;

    if (musicAggregator.fromDb) {
      await musicAggregator.saveToDb();
      await musicAggregator.changeDefaultServerInDb(
          server: currentMusic.server);
      musicAggregator.defaultServer = server;
    }

    // 切换音源之后需要 初始化audioSource为本地空白音频
    // 以便在下次播放时更新音频资源
    audioSource = AudioSource.asset("assets/blank.mp3", tag: _genMediaItem());

    return true;
  }
}

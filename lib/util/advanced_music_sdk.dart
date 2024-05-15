import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/types/music.dart';

Future<List<Music>> getAllMusicFromMusicList(
    String payload, String source) async {
  List<Music> musics = [];
  int currentPage = 1;
  bool isEmptyPage = false;

  while (!isEmptyPage) {
    // 创建一个列表来保存所有的Future
    List<Future<List<MusicW>>> pageRequests = List.generate(5, (index) {
      return getMusicsFromMusicList(
          payload: payload, page: currentPage + index, source: source);
    });

    // 更新currentPage以确保下一轮循环请求新的页面
    currentPage += 5;

    // 等待所有请求完成
    List<List<MusicW>> results = await Future.wait(pageRequests);
    List<Music> newMusics = [];
    for (var result in results) {
      for (var music in result) {
        bool exist = false;
        var newMusic = Music(music);
        for (var existMusic in musics) {
          if (newMusic.info.name == existMusic.info.name &&
              newMusic.info.artist.join(",") ==
                  existMusic.info.artist.join(",")) {
            exist = true;
          }
        }
        if (!exist) {
          newMusics.add(newMusic);
        }
      }
    }
    // 检查结果并更新musics列表
    if (newMusics.isEmpty) {
      isEmptyPage = true;
      break;
    } else {
      musics.addAll(newMusics);
    }
  }

  return musics;
}

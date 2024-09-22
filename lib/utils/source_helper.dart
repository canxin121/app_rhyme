import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';

MusicServer? nextSource(List<MusicServer> availableSources) {
  // 传入已经使用过的源，返回下一个可用的源，如果没有下一个源了，返回 null
  // 顺序：酷我 => 网易

  if (availableSources.length >= 2) {
    return null;
  }

  if (availableSources.contains(MusicServer.kuwo)) {
    return MusicServer.netease;
  } else {
    return MusicServer.kuwo;
  }
}

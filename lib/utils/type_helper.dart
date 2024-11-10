import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/src/rust/api/types/playinfo.dart';

Quality qualityFromObject(dynamic obj) {
  return Quality(
    summary: obj['summary'],
    bitrate: obj['bitrate'],
    format: obj['format'],
    size: obj['size'],
  );
}

PlayInfo? playInfoFromObject(dynamic obj) {
  if (obj == null) return null;
  try {
    String uri = obj["uri"];
    Quality quality = qualityFromObject(obj["quality"]);
    return PlayInfo(uri: uri, quality: quality);
  } catch (e) {
    return null;
  }
}

String musicDataTypeToString(MusicDataType type) {
  switch (type) {
    case MusicDataType.database:
      return "数据库";
    case MusicDataType.playlists:
      return "歌单";
    case MusicDataType.musicAggregators:
      return "音乐";
  }
}

import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/types/playinfo.dart';

Quality qualityFromObject(dynamic obj) {
  return Quality(
    short: obj['short'],
    level: obj['level'],
    bitrate: obj['bitrate'],
    format: obj['format'],
    size: obj['size'],
  );
}

PlayInfo? playInfoFromObject(dynamic obj) {
  if (obj == null) return null;
  try {
    String uri = obj["url"];
    Quality quality = qualityFromObject(obj["quality"]);
    return PlayInfo(uri: uri, quality: quality);
  } catch (e) {
    return null;
  }
}

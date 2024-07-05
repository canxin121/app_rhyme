import 'package:app_rhyme/src/rust/api/mirrors.dart';

Quality qualityFromObject(dynamic obj) {
  return Quality(
    short: obj['short'],
    level: obj['level'],
    bitrate: obj['bitrate'],
    format: obj['format'],
    size: obj['size'],
  );
}

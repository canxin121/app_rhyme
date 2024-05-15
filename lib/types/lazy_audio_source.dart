import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

typedef ResolveSoundUrl = Future<Uri?> Function(String uniquidId);

class ResolvingAudioSource extends StreamAudioSource {
  final String uniqueId;
  final ResolveSoundUrl resolveSoundUrl;
  final Map<String, String>? headers;

  var _hasRequestedSoundUrl = false;
  final _soundUrlCompleter = Completer<Uri?>();

  Future<Uri?> get _soundUrl => _soundUrlCompleter.future;

  HttpClient? _httpClient;

  HttpClient get httpClient => _httpClient ?? (_httpClient = HttpClient());

  ResolvingAudioSource(
      {required this.uniqueId,
      required this.resolveSoundUrl,
      this.headers,
      super.tag});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    if (!_hasRequestedSoundUrl) {
      _hasRequestedSoundUrl = true;
      final soundUrl = await resolveSoundUrl(uniqueId);
      _soundUrlCompleter.complete(soundUrl);
    }
    final soundUrl = await _soundUrl;
    if (soundUrl == null) {
      return StreamAudioResponse(
          sourceLength: null,
          contentLength: null,
          offset: null,
          stream: const Stream.empty(),
          contentType: '');
    }
    final request = await httpClient.getUrl(soundUrl);
    for (var entry in headers?.entries ?? <MapEntry<String, String>>[]) {
      request.headers.set(entry.key, entry.value);
    }
    if (start != null || end != null) {
      request.headers
          .set(HttpHeaders.rangeHeader, 'bytes=${start ?? ""}-${end ?? ""}');
    }
    final response = await request.close();
    final acceptRangesHeader =
        response.headers.value(HttpHeaders.acceptRangesHeader);
    final contentRange = response.headers.value(HttpHeaders.contentRangeHeader);
    int? offset;
    if (contentRange != null) {
      int offsetEnd = contentRange.indexOf('-');
      if (offsetEnd >= 6) {
        offset = int.tryParse(contentRange.substring(6, offsetEnd));
      }
    }
    final contentLength =
        response.headers.value(HttpHeaders.contentLengthHeader);
    final contentType = response.headers.value(HttpHeaders.contentTypeHeader);
    return StreamAudioResponse(
        rangeRequestsSupported:
            acceptRangesHeader != null && acceptRangesHeader != 'none',
        sourceLength: null,
        contentLength:
            contentLength == null ? null : int.tryParse(contentLength),
        offset: offset,
        stream: response.asBroadcastStream(),
        contentType: contentType ?? "");
  }
}

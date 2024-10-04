import 'dart:async';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';

final StreamController<(bool, String)> musicAggregatorCacheController =
    StreamController.broadcast();

final StreamController<Music> musicAggregatorInfoUpdateStreamController =
    StreamController.broadcast();

final StreamController<List<MusicAggregator>>
    musicAggregatorListUpdateStreamController = StreamController.broadcast();

final StreamController<List<Playlist>> playlistGridUpdateStreamController =
    StreamController.broadcast();

final StreamController<Playlist> playlistUpdateStreamController =
    StreamController.broadcast();

final StreamController<void> dbPlaylistPagePopStreamController =
    StreamController.broadcast();

import 'dart:async';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';

/// page refresh
// String: playlist id
final StreamController<String> musicAggrgatorsPageRefreshStreamController =
    StreamController.broadcast();
// int: playlistCollection id
final StreamController<int> playlistsPageRefreshStreamController =
    StreamController.broadcast();
// void
final StreamController<void> playlistCollectionsPageRefreshStreamController =
    StreamController.broadcast();

/// page pop
// int: playlist id
final StreamController<int> dbPlaylistPagePopStreamController =
    StreamController.broadcast();

/// MusicAggregator
// bool: isCache, String: musicAggregator Identity
final StreamController<(bool, String)> musicAggregatorCacheController =
    StreamController.broadcast();
// Music: music info
final StreamController<Music> musicAggregatorUpdateStreamController =
    StreamController.broadcast();
// String: MusicAggregator identity
final StreamController<String> musicAggregatorDeleteStreamController =
    StreamController.broadcast();

/// playlist
// String: playlist identity
final StreamController<String> playlistDeleteStreamController =
    StreamController.broadcast();
// Playlist: new crearted playlist
final StreamController<(Playlist, int)> playlistCreateStreamController =
    StreamController.broadcast();
// Playlist: updated playlist info
final StreamController<Playlist> playlistUpdateStreamController =
    StreamController.broadcast();

/// playlist Collection
// int: playlistCollection id
final StreamController<int> playlistCollectionDeleteStreamController =
    StreamController.broadcast();
// PlaylistCollection: new created playlistCollection
final StreamController<PlaylistCollection>
    playlistCollectionCreateStreamController = StreamController.broadcast();
// PlaylistCollection: updated playlistCollection info
final StreamController<PlaylistCollection>
    playlistCollectionUpdateStreamController = StreamController.broadcast();

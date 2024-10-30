// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.5.1.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These types are ignored because they are not used by any `pub` functions: `ArtistVec`, `MusicAggregatorJsonVec`, `PlayListSubscriptionVec`, `PlaylistJsonVec`, `PlaylistJson`, `QualityVec`

class Artist {
  String name;
  String? id;

  Artist({
    required this.name,
    this.id,
  });

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;
}

class Music {
  final bool fromDb;
  final MusicServer server;
  final String identity;
  String name;
  PlatformInt64? duration;
  List<Artist> artists;
  String? album;
  String? albumId;
  List<Quality> qualities;
  String? cover;

  Music({
    required this.fromDb,
    required this.server,
    required this.identity,
    required this.name,
    this.duration,
    required this.artists,
    this.album,
    this.albumId,
    required this.qualities,
    this.cover,
  });

  /// return the album playlist on first page, and musics on each page
  /// on some music server, the page and limit has no effect, they just return the all musics.
  Future<(Playlist?, List<MusicAggregator>)> getAlbum(
          {required int page, required int limit}) =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicGetAlbum(
          that: this, page: page, limit: limit);

  /// get music cover of specific size
  String? getCover({required int size}) => RustLib.instance.api
      .crateApiMusicApiMirrorMusicGetCover(that: this, size: size);

  Future<String> getLyric() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicGetLyric(
        that: this,
      );

  Future<void> insertToDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicInsertToDb(
        that: this,
      );

  /// Search music online
  static Future<List<Music>> searchOnline(
          {required List<MusicServer> servers,
          required String content,
          required int page,
          required int size}) =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicSearchOnline(
          servers: servers, content: content, page: page, size: size);

  /// 允许外部调用更新音乐的功能
  Future<Music> updateToDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicUpdateToDb(
        that: this,
      );

  @override
  int get hashCode =>
      fromDb.hashCode ^
      server.hashCode ^
      identity.hashCode ^
      name.hashCode ^
      duration.hashCode ^
      artists.hashCode ^
      album.hashCode ^
      albumId.hashCode ^
      qualities.hashCode ^
      cover.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Music &&
          runtimeType == other.runtimeType &&
          fromDb == other.fromDb &&
          server == other.server &&
          identity == other.identity &&
          name == other.name &&
          duration == other.duration &&
          artists == other.artists &&
          album == other.album &&
          albumId == other.albumId &&
          qualities == other.qualities &&
          cover == other.cover;
}

class MusicAggregator {
  final String name;
  final String artist;
  final bool fromDb;
  PlatformInt64? order;
  List<Music> musics;
  MusicServer defaultServer;

  MusicAggregator({
    required this.name,
    required this.artist,
    required this.fromDb,
    this.order,
    required this.musics,
    required this.defaultServer,
  });

  Future<void> changeDefaultServerInDb({required MusicServer server}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorMusicAggregatorChangeDefaultServerInDb(
              that: this, server: server);

  static Future<void> clearUnused() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicAggregatorClearUnused();

  Future<void> delFromDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicAggregatorDelFromDb(
        that: this,
      );

  static Future<List<MusicAggregator>> fetchArtistMusicAggregators(
          {required MusicServer server,
          required String artistId,
          required int page,
          required int limit}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorMusicAggregatorFetchArtistMusicAggregators(
              server: server, artistId: artistId, page: page, limit: limit);

  Future<MusicAggregator> fetchServerOnline(
          {required List<MusicServer> servers}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorMusicAggregatorFetchServerOnline(
              that: this, servers: servers);

  static Future<MusicAggregator> fromMusic({required Music music}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorMusicAggregatorFromMusic(music: music);

  String identity() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicAggregatorIdentity(
        that: this,
      );

  Future<void> saveToDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicAggregatorSaveToDb(
        that: this,
      );

  static Future<List<MusicAggregator>> searchOnline(
          {required List<MusicAggregator> aggs,
          required List<MusicServer> servers,
          required String content,
          required int page,
          required int size}) =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicAggregatorSearchOnline(
          aggs: aggs,
          servers: servers,
          content: content,
          page: page,
          size: size);

  Future<void> updateOrderToDb({required PlatformInt64 playlistId}) =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicAggregatorUpdateOrderToDb(
          that: this, playlistId: playlistId);

  @override
  int get hashCode =>
      name.hashCode ^
      artist.hashCode ^
      fromDb.hashCode ^
      order.hashCode ^
      musics.hashCode ^
      defaultServer.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicAggregator &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          artist == other.artist &&
          fromDb == other.fromDb &&
          order == other.order &&
          musics == other.musics &&
          defaultServer == other.defaultServer;
}

class MusicChart {
  final String name;
  final String? summary;
  final String? cover;
  final String id;

  const MusicChart({
    required this.name,
    this.summary,
    this.cover,
    required this.id,
  });

  @override
  int get hashCode =>
      name.hashCode ^ summary.hashCode ^ cover.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicChart &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          summary == other.summary &&
          cover == other.cover &&
          id == other.id;
}

class MusicChartCollection {
  final String name;
  final String? summary;
  final List<MusicChart> charts;

  const MusicChartCollection({
    required this.name,
    this.summary,
    required this.charts,
  });

  @override
  int get hashCode => name.hashCode ^ summary.hashCode ^ charts.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicChartCollection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          summary == other.summary &&
          charts == other.charts;
}

enum MusicDataType {
  database,
  playlists,
  musicAggregators,
  ;
}

enum MusicServer {
  kuwo,
  netease,
  ;

  static List<MusicServer> all() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicServerAll();

  static BigInt length() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicServerLength();

  @override
  String toString() =>
      RustLib.instance.api.crateApiMusicApiMirrorMusicServerToString(
        that: this,
      );
}

class PlayListSubscription {
  String name;
  String share;

  PlayListSubscription({
    required this.name,
    required this.share,
  });

  @override
  int get hashCode => name.hashCode ^ share.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayListSubscription &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          share == other.share;
}

class Playlist {
  final bool fromDb;
  final MusicServer? server;
  final PlaylistType typeField;
  final String identity;
  final PlatformInt64? collectionId;
  String name;
  PlatformInt64? order;
  String? summary;
  String? cover;
  final String? creator;
  final String? creatorId;
  final PlatformInt64? playTime;
  final PlatformInt64? musicNum;
  List<PlayListSubscription>? subscription;

  Playlist({
    required this.fromDb,
    this.server,
    required this.typeField,
    required this.identity,
    this.collectionId,
    required this.name,
    this.order,
    this.summary,
    this.cover,
    this.creator,
    this.creatorId,
    this.playTime,
    this.musicNum,
    this.subscription,
  });

  /// add playlist music aggregator junction to db
  /// this will also add the music and music aggregators to the db
  Future<void> addAggsToDb({required List<MusicAggregator> musicAggs}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistAddAggsToDb(
          that: this, musicAggs: musicAggs);

  /// delete a playlist from db
  /// this will also delete all junctions between the playlist and music
  Future<void> delFromDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistDelFromDb(
        that: this,
      );

  Future<void> delMusicAgg({required String musicAggIdentity}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistDelMusicAgg(
          that: this, musicAggIdentity: musicAggIdentity);

  static Future<List<Playlist>> fetchArtistAlbums(
          {required MusicServer server,
          required String artistId,
          required int page,
          required int limit}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistFetchArtistAlbums(
          server: server, artistId: artistId, page: page, limit: limit);

  /// Fetch musics from playlist
  Future<List<MusicAggregator>> fetchMusicsOnline(
          {required int page, required int limit}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistFetchMusicsOnline(
          that: this, page: page, limit: limit);

  /// find db playlist by primary key `id`
  static Future<Playlist?> findInDb({required PlatformInt64 id}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistFindInDb(id: id);

  /// get playlist cover of specific size
  String? getCover({required int size}) => RustLib.instance.api
      .crateApiMusicApiMirrorPlaylistGetCover(that: this, size: size);

  /// get playlists from db
  static Future<List<Playlist>> getFromDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistGetFromDb();

  /// get a playlist from share link
  static Future<Playlist> getFromShare({required String share}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorPlaylistGetFromShare(share: share);

  /// get all music aggregators from db
  Future<List<MusicAggregator>> getMusicsFromDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistGetMusicsFromDb(
        that: this,
      );

  Future<PlatformInt64> insertToDb({required PlatformInt64 collectionId}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistInsertToDb(
          that: this, collectionId: collectionId);

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<Playlist> newInstance(
          {required String name,
          String? summary,
          String? cover,
          required List<PlayListSubscription> subscriptions}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistNew(
          name: name,
          summary: summary,
          cover: cover,
          subscriptions: subscriptions);

  /// Search playlist online
  static Future<List<Playlist>> searchOnline(
          {required List<MusicServer> servers,
          required String content,
          required int page,
          required int size}) =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistSearchOnline(
          servers: servers, content: content, page: page, size: size);

  /// update playlist music aggregator of subscribed playlist into db playlist
  Future<PlaylistUpdateSubscriptionResult> updateSubscription() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistUpdateSubscription(
        that: this,
      );

  /// update db playlist info
  Future<Playlist> updateToDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistUpdateToDb(
        that: this,
      );

  @override
  int get hashCode =>
      fromDb.hashCode ^
      server.hashCode ^
      typeField.hashCode ^
      identity.hashCode ^
      collectionId.hashCode ^
      name.hashCode ^
      order.hashCode ^
      summary.hashCode ^
      cover.hashCode ^
      creator.hashCode ^
      creatorId.hashCode ^
      playTime.hashCode ^
      musicNum.hashCode ^
      subscription.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist &&
          runtimeType == other.runtimeType &&
          fromDb == other.fromDb &&
          server == other.server &&
          typeField == other.typeField &&
          identity == other.identity &&
          collectionId == other.collectionId &&
          name == other.name &&
          order == other.order &&
          summary == other.summary &&
          cover == other.cover &&
          creator == other.creator &&
          creatorId == other.creatorId &&
          playTime == other.playTime &&
          musicNum == other.musicNum &&
          subscription == other.subscription;
}

class PlaylistCollection {
  final PlatformInt64 id;
  PlatformInt64 order;
  String name;

  PlaylistCollection({
    required this.id,
    required this.order,
    required this.name,
  });

  Future<void> deleteFromDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistCollectionDeleteFromDb(
        that: this,
      );

  static Future<PlaylistCollection> findInDb({required PlatformInt64 id}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorPlaylistCollectionFindInDb(id: id);

  static Future<List<PlaylistCollection>> getFormDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistCollectionGetFormDb();

  Future<List<Playlist>> getPlaylistsFromDb() => RustLib.instance.api
          .crateApiMusicApiMirrorPlaylistCollectionGetPlaylistsFromDb(
        that: this,
      );

  Future<PlatformInt64> insertToDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistCollectionInsertToDb(
        that: this,
      );

  // HINT: Make it `#[frb(sync)]` to let it become the default constructor of Dart class.
  static Future<PlaylistCollection> newInstance({required String name}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorPlaylistCollectionNew(name: name);

  Future<PlaylistCollection> updateToDb() =>
      RustLib.instance.api.crateApiMusicApiMirrorPlaylistCollectionUpdateToDb(
        that: this,
      );

  @override
  int get hashCode => id.hashCode ^ order.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          order == other.order &&
          name == other.name;
}

class PlaylistTag {
  final String name;
  final String id;

  const PlaylistTag({
    required this.name,
    required this.id,
  });

  @override
  int get hashCode => name.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistTag &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id;
}

class PlaylistTagCollection {
  final String name;
  final List<PlaylistTag> tags;

  const PlaylistTagCollection({
    required this.name,
    required this.tags,
  });

  @override
  int get hashCode => name.hashCode ^ tags.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistTagCollection &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          tags == other.tags;
}

enum PlaylistType {
  userPlaylist,
  album,
  ;
}

class PlaylistUpdateSubscriptionResult {
  final List<(String, String)> errors;

  const PlaylistUpdateSubscriptionResult({
    required this.errors,
  });

  @override
  int get hashCode => errors.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistUpdateSubscriptionResult &&
          runtimeType == other.runtimeType &&
          errors == other.errors;
}

class Quality {
  final String summary;
  final String? bitrate;
  final String? format;
  final String? size;

  const Quality({
    required this.summary,
    this.bitrate,
    this.format,
    this.size,
  });

  @override
  int get hashCode =>
      summary.hashCode ^ bitrate.hashCode ^ format.hashCode ^ size.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quality &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          bitrate == other.bitrate &&
          format == other.format &&
          size == other.size;
}

class ServerMusicChartCollection {
  final MusicServer server;
  final List<MusicChartCollection> collections;

  const ServerMusicChartCollection({
    required this.server,
    required this.collections,
  });

  static Future<
      List<
          ServerMusicChartCollection>> getMusicChartCollection() => RustLib
      .instance.api
      .crateApiMusicApiMirrorServerMusicChartCollectionGetMusicChartCollection();

  static Future<List<MusicAggregator>> getMusicsFromChart(
          {required MusicServer server,
          required String id,
          required int page,
          required int limit}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorServerMusicChartCollectionGetMusicsFromChart(
              server: server, id: id, page: page, limit: limit);

  @override
  int get hashCode => server.hashCode ^ collections.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerMusicChartCollection &&
          runtimeType == other.runtimeType &&
          server == other.server &&
          collections == other.collections;
}

class ServerPlaylistTagCollection {
  final MusicServer server;
  final List<PlaylistTagCollection> collections;

  const ServerPlaylistTagCollection({
    required this.server,
    required this.collections,
  });

  static Future<List<ServerPlaylistTagCollection>> getPlaylistTags() =>
      RustLib.instance.api
          .crateApiMusicApiMirrorServerPlaylistTagCollectionGetPlaylistTags();

  static Future<List<Playlist>> getPlaylistsFromTag(
          {required MusicServer server,
          required String tagId,
          required TagPlaylistOrder order,
          required int page,
          required int limit}) =>
      RustLib.instance.api
          .crateApiMusicApiMirrorServerPlaylistTagCollectionGetPlaylistsFromTag(
              server: server,
              tagId: tagId,
              order: order,
              page: page,
              limit: limit);

  @override
  int get hashCode => server.hashCode ^ collections.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerPlaylistTagCollection &&
          runtimeType == other.runtimeType &&
          server == other.server &&
          collections == other.collections;
}

enum TagPlaylistOrder {
  hot,
  new_,
  ;
}

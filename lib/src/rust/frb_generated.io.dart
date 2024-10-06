// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.4.0.

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'api/cache/cache_op.dart';
import 'api/cache/file_cache.dart';
import 'api/cache/music_cache.dart';
import 'api/init.dart';
import 'api/music_api/fns.dart';
import 'api/music_api/mirror.dart';
import 'api/music_api/plugin_fn.dart';
import 'api/music_api/wrapper.dart';
import 'api/types/config.dart';
import 'api/types/external_api.dart';
import 'api/types/playinfo.dart';
import 'api/types/version.dart';
import 'api/utils/crypto.dart';
import 'api/utils/database.dart';
import 'api/utils/http_helper.dart';
import 'api/utils/path_util.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_io.dart';

abstract class RustLibApiImplPlatform extends BaseApiImpl<RustLibWire> {
  RustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  CrossPlatformFinalizerArg
      get rust_arc_decrement_strong_count_MusicDataJsonWrapperPtr => wire
          ._rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapperPtr;

  @protected
  AnyhowException dco_decode_AnyhowException(dynamic raw);

  @protected
  MusicDataJsonWrapper
      dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          dynamic raw);

  @protected
  MusicDataJsonWrapper
      dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          dynamic raw);

  @protected
  Map<String, String> dco_decode_Map_String_String(dynamic raw);

  @protected
  MusicDataJsonWrapper
      dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          dynamic raw);

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  Artist dco_decode_artist(dynamic raw);

  @protected
  Asset dco_decode_asset(dynamic raw);

  @protected
  Author dco_decode_author(dynamic raw);

  @protected
  bool dco_decode_bool(dynamic raw);

  @protected
  Config dco_decode_box_autoadd_config(dynamic raw);

  @protected
  ExternalApiConfig dco_decode_box_autoadd_external_api_config(dynamic raw);

  @protected
  PlatformInt64 dco_decode_box_autoadd_i_64(dynamic raw);

  @protected
  Music dco_decode_box_autoadd_music(dynamic raw);

  @protected
  MusicAggregator dco_decode_box_autoadd_music_aggregator(dynamic raw);

  @protected
  MusicServer dco_decode_box_autoadd_music_server(dynamic raw);

  @protected
  PlayInfo dco_decode_box_autoadd_play_info(dynamic raw);

  @protected
  Playlist dco_decode_box_autoadd_playlist(dynamic raw);

  @protected
  Quality dco_decode_box_autoadd_quality(dynamic raw);

  @protected
  (PlayInfo, String) dco_decode_box_autoadd_record_play_info_string(
      dynamic raw);

  @protected
  Release dco_decode_box_autoadd_release(dynamic raw);

  @protected
  WindowConfig dco_decode_box_autoadd_window_config(dynamic raw);

  @protected
  Config dco_decode_config(dynamic raw);

  @protected
  ExternalApiConfig dco_decode_external_api_config(dynamic raw);

  @protected
  int dco_decode_i_32(dynamic raw);

  @protected
  PlatformInt64 dco_decode_i_64(dynamic raw);

  @protected
  List<Artist> dco_decode_list_artist(dynamic raw);

  @protected
  List<Asset> dco_decode_list_asset(dynamic raw);

  @protected
  List<Music> dco_decode_list_music(dynamic raw);

  @protected
  List<MusicAggregator> dco_decode_list_music_aggregator(dynamic raw);

  @protected
  List<MusicChart> dco_decode_list_music_chart(dynamic raw);

  @protected
  List<MusicChartCollection> dco_decode_list_music_chart_collection(
      dynamic raw);

  @protected
  List<MusicServer> dco_decode_list_music_server(dynamic raw);

  @protected
  List<PlayListSubscription> dco_decode_list_play_list_subscription(
      dynamic raw);

  @protected
  List<Playlist> dco_decode_list_playlist(dynamic raw);

  @protected
  List<PlaylistTag> dco_decode_list_playlist_tag(dynamic raw);

  @protected
  List<PlaylistTagCollection> dco_decode_list_playlist_tag_collection(
      dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  List<Quality> dco_decode_list_quality(dynamic raw);

  @protected
  List<(String, String)> dco_decode_list_record_string_string(dynamic raw);

  @protected
  List<ServerMusicChartCollection>
      dco_decode_list_server_music_chart_collection(dynamic raw);

  @protected
  List<ServerPlaylistTagCollection>
      dco_decode_list_server_playlist_tag_collection(dynamic raw);

  @protected
  Music dco_decode_music(dynamic raw);

  @protected
  MusicAggregator dco_decode_music_aggregator(dynamic raw);

  @protected
  MusicChart dco_decode_music_chart(dynamic raw);

  @protected
  MusicChartCollection dco_decode_music_chart_collection(dynamic raw);

  @protected
  MusicDataType dco_decode_music_data_type(dynamic raw);

  @protected
  MusicServer dco_decode_music_server(dynamic raw);

  @protected
  String? dco_decode_opt_String(dynamic raw);

  @protected
  ExternalApiConfig? dco_decode_opt_box_autoadd_external_api_config(
      dynamic raw);

  @protected
  PlatformInt64? dco_decode_opt_box_autoadd_i_64(dynamic raw);

  @protected
  MusicServer? dco_decode_opt_box_autoadd_music_server(dynamic raw);

  @protected
  Playlist? dco_decode_opt_box_autoadd_playlist(dynamic raw);

  @protected
  (PlayInfo, String)? dco_decode_opt_box_autoadd_record_play_info_string(
      dynamic raw);

  @protected
  Release? dco_decode_opt_box_autoadd_release(dynamic raw);

  @protected
  WindowConfig? dco_decode_opt_box_autoadd_window_config(dynamic raw);

  @protected
  List<PlayListSubscription>? dco_decode_opt_list_play_list_subscription(
      dynamic raw);

  @protected
  PlayInfo dco_decode_play_info(dynamic raw);

  @protected
  PlayListSubscription dco_decode_play_list_subscription(dynamic raw);

  @protected
  Playlist dco_decode_playlist(dynamic raw);

  @protected
  PlaylistTag dco_decode_playlist_tag(dynamic raw);

  @protected
  PlaylistTagCollection dco_decode_playlist_tag_collection(dynamic raw);

  @protected
  PlaylistType dco_decode_playlist_type(dynamic raw);

  @protected
  PlaylistUpdateSubscriptionResult
      dco_decode_playlist_update_subscription_result(dynamic raw);

  @protected
  Quality dco_decode_quality(dynamic raw);

  @protected
  QualityConfig dco_decode_quality_config(dynamic raw);

  @protected
  QualityOption dco_decode_quality_option(dynamic raw);

  @protected
  (Playlist?, List<MusicAggregator>)
      dco_decode_record_opt_box_autoadd_playlist_list_music_aggregator(
          dynamic raw);

  @protected
  (PlayInfo, String) dco_decode_record_play_info_string(dynamic raw);

  @protected
  (String, String) dco_decode_record_string_string(dynamic raw);

  @protected
  Release dco_decode_release(dynamic raw);

  @protected
  ServerMusicChartCollection dco_decode_server_music_chart_collection(
      dynamic raw);

  @protected
  ServerPlaylistTagCollection dco_decode_server_playlist_tag_collection(
      dynamic raw);

  @protected
  StorageConfig dco_decode_storage_config(dynamic raw);

  @protected
  TagPlaylistOrder dco_decode_tag_playlist_order(dynamic raw);

  @protected
  int dco_decode_u_16(dynamic raw);

  @protected
  BigInt dco_decode_u_64(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  UpdateConfig dco_decode_update_config(dynamic raw);

  @protected
  BigInt dco_decode_usize(dynamic raw);

  @protected
  WindowConfig dco_decode_window_config(dynamic raw);

  @protected
  AnyhowException sse_decode_AnyhowException(SseDeserializer deserializer);

  @protected
  MusicDataJsonWrapper
      sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          SseDeserializer deserializer);

  @protected
  MusicDataJsonWrapper
      sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          SseDeserializer deserializer);

  @protected
  Map<String, String> sse_decode_Map_String_String(
      SseDeserializer deserializer);

  @protected
  MusicDataJsonWrapper
      sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          SseDeserializer deserializer);

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  Artist sse_decode_artist(SseDeserializer deserializer);

  @protected
  Asset sse_decode_asset(SseDeserializer deserializer);

  @protected
  Author sse_decode_author(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  Config sse_decode_box_autoadd_config(SseDeserializer deserializer);

  @protected
  ExternalApiConfig sse_decode_box_autoadd_external_api_config(
      SseDeserializer deserializer);

  @protected
  PlatformInt64 sse_decode_box_autoadd_i_64(SseDeserializer deserializer);

  @protected
  Music sse_decode_box_autoadd_music(SseDeserializer deserializer);

  @protected
  MusicAggregator sse_decode_box_autoadd_music_aggregator(
      SseDeserializer deserializer);

  @protected
  MusicServer sse_decode_box_autoadd_music_server(SseDeserializer deserializer);

  @protected
  PlayInfo sse_decode_box_autoadd_play_info(SseDeserializer deserializer);

  @protected
  Playlist sse_decode_box_autoadd_playlist(SseDeserializer deserializer);

  @protected
  Quality sse_decode_box_autoadd_quality(SseDeserializer deserializer);

  @protected
  (PlayInfo, String) sse_decode_box_autoadd_record_play_info_string(
      SseDeserializer deserializer);

  @protected
  Release sse_decode_box_autoadd_release(SseDeserializer deserializer);

  @protected
  WindowConfig sse_decode_box_autoadd_window_config(
      SseDeserializer deserializer);

  @protected
  Config sse_decode_config(SseDeserializer deserializer);

  @protected
  ExternalApiConfig sse_decode_external_api_config(
      SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  PlatformInt64 sse_decode_i_64(SseDeserializer deserializer);

  @protected
  List<Artist> sse_decode_list_artist(SseDeserializer deserializer);

  @protected
  List<Asset> sse_decode_list_asset(SseDeserializer deserializer);

  @protected
  List<Music> sse_decode_list_music(SseDeserializer deserializer);

  @protected
  List<MusicAggregator> sse_decode_list_music_aggregator(
      SseDeserializer deserializer);

  @protected
  List<MusicChart> sse_decode_list_music_chart(SseDeserializer deserializer);

  @protected
  List<MusicChartCollection> sse_decode_list_music_chart_collection(
      SseDeserializer deserializer);

  @protected
  List<MusicServer> sse_decode_list_music_server(SseDeserializer deserializer);

  @protected
  List<PlayListSubscription> sse_decode_list_play_list_subscription(
      SseDeserializer deserializer);

  @protected
  List<Playlist> sse_decode_list_playlist(SseDeserializer deserializer);

  @protected
  List<PlaylistTag> sse_decode_list_playlist_tag(SseDeserializer deserializer);

  @protected
  List<PlaylistTagCollection> sse_decode_list_playlist_tag_collection(
      SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  List<Quality> sse_decode_list_quality(SseDeserializer deserializer);

  @protected
  List<(String, String)> sse_decode_list_record_string_string(
      SseDeserializer deserializer);

  @protected
  List<ServerMusicChartCollection>
      sse_decode_list_server_music_chart_collection(
          SseDeserializer deserializer);

  @protected
  List<ServerPlaylistTagCollection>
      sse_decode_list_server_playlist_tag_collection(
          SseDeserializer deserializer);

  @protected
  Music sse_decode_music(SseDeserializer deserializer);

  @protected
  MusicAggregator sse_decode_music_aggregator(SseDeserializer deserializer);

  @protected
  MusicChart sse_decode_music_chart(SseDeserializer deserializer);

  @protected
  MusicChartCollection sse_decode_music_chart_collection(
      SseDeserializer deserializer);

  @protected
  MusicDataType sse_decode_music_data_type(SseDeserializer deserializer);

  @protected
  MusicServer sse_decode_music_server(SseDeserializer deserializer);

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer);

  @protected
  ExternalApiConfig? sse_decode_opt_box_autoadd_external_api_config(
      SseDeserializer deserializer);

  @protected
  PlatformInt64? sse_decode_opt_box_autoadd_i_64(SseDeserializer deserializer);

  @protected
  MusicServer? sse_decode_opt_box_autoadd_music_server(
      SseDeserializer deserializer);

  @protected
  Playlist? sse_decode_opt_box_autoadd_playlist(SseDeserializer deserializer);

  @protected
  (PlayInfo, String)? sse_decode_opt_box_autoadd_record_play_info_string(
      SseDeserializer deserializer);

  @protected
  Release? sse_decode_opt_box_autoadd_release(SseDeserializer deserializer);

  @protected
  WindowConfig? sse_decode_opt_box_autoadd_window_config(
      SseDeserializer deserializer);

  @protected
  List<PlayListSubscription>? sse_decode_opt_list_play_list_subscription(
      SseDeserializer deserializer);

  @protected
  PlayInfo sse_decode_play_info(SseDeserializer deserializer);

  @protected
  PlayListSubscription sse_decode_play_list_subscription(
      SseDeserializer deserializer);

  @protected
  Playlist sse_decode_playlist(SseDeserializer deserializer);

  @protected
  PlaylistTag sse_decode_playlist_tag(SseDeserializer deserializer);

  @protected
  PlaylistTagCollection sse_decode_playlist_tag_collection(
      SseDeserializer deserializer);

  @protected
  PlaylistType sse_decode_playlist_type(SseDeserializer deserializer);

  @protected
  PlaylistUpdateSubscriptionResult
      sse_decode_playlist_update_subscription_result(
          SseDeserializer deserializer);

  @protected
  Quality sse_decode_quality(SseDeserializer deserializer);

  @protected
  QualityConfig sse_decode_quality_config(SseDeserializer deserializer);

  @protected
  QualityOption sse_decode_quality_option(SseDeserializer deserializer);

  @protected
  (Playlist?, List<MusicAggregator>)
      sse_decode_record_opt_box_autoadd_playlist_list_music_aggregator(
          SseDeserializer deserializer);

  @protected
  (PlayInfo, String) sse_decode_record_play_info_string(
      SseDeserializer deserializer);

  @protected
  (String, String) sse_decode_record_string_string(
      SseDeserializer deserializer);

  @protected
  Release sse_decode_release(SseDeserializer deserializer);

  @protected
  ServerMusicChartCollection sse_decode_server_music_chart_collection(
      SseDeserializer deserializer);

  @protected
  ServerPlaylistTagCollection sse_decode_server_playlist_tag_collection(
      SseDeserializer deserializer);

  @protected
  StorageConfig sse_decode_storage_config(SseDeserializer deserializer);

  @protected
  TagPlaylistOrder sse_decode_tag_playlist_order(SseDeserializer deserializer);

  @protected
  int sse_decode_u_16(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_u_64(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  UpdateConfig sse_decode_update_config(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer);

  @protected
  WindowConfig sse_decode_window_config(SseDeserializer deserializer);

  @protected
  void sse_encode_AnyhowException(
      AnyhowException self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          MusicDataJsonWrapper self, SseSerializer serializer);

  @protected
  void
      sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          MusicDataJsonWrapper self, SseSerializer serializer);

  @protected
  void sse_encode_Map_String_String(
      Map<String, String> self, SseSerializer serializer);

  @protected
  void
      sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
          MusicDataJsonWrapper self, SseSerializer serializer);

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_artist(Artist self, SseSerializer serializer);

  @protected
  void sse_encode_asset(Asset self, SseSerializer serializer);

  @protected
  void sse_encode_author(Author self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_config(Config self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_external_api_config(
      ExternalApiConfig self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_i_64(
      PlatformInt64 self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_music(Music self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_music_aggregator(
      MusicAggregator self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_music_server(
      MusicServer self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_play_info(
      PlayInfo self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_playlist(Playlist self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_quality(Quality self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_record_play_info_string(
      (PlayInfo, String) self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_release(Release self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_window_config(
      WindowConfig self, SseSerializer serializer);

  @protected
  void sse_encode_config(Config self, SseSerializer serializer);

  @protected
  void sse_encode_external_api_config(
      ExternalApiConfig self, SseSerializer serializer);

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_i_64(PlatformInt64 self, SseSerializer serializer);

  @protected
  void sse_encode_list_artist(List<Artist> self, SseSerializer serializer);

  @protected
  void sse_encode_list_asset(List<Asset> self, SseSerializer serializer);

  @protected
  void sse_encode_list_music(List<Music> self, SseSerializer serializer);

  @protected
  void sse_encode_list_music_aggregator(
      List<MusicAggregator> self, SseSerializer serializer);

  @protected
  void sse_encode_list_music_chart(
      List<MusicChart> self, SseSerializer serializer);

  @protected
  void sse_encode_list_music_chart_collection(
      List<MusicChartCollection> self, SseSerializer serializer);

  @protected
  void sse_encode_list_music_server(
      List<MusicServer> self, SseSerializer serializer);

  @protected
  void sse_encode_list_play_list_subscription(
      List<PlayListSubscription> self, SseSerializer serializer);

  @protected
  void sse_encode_list_playlist(List<Playlist> self, SseSerializer serializer);

  @protected
  void sse_encode_list_playlist_tag(
      List<PlaylistTag> self, SseSerializer serializer);

  @protected
  void sse_encode_list_playlist_tag_collection(
      List<PlaylistTagCollection> self, SseSerializer serializer);

  @protected
  void sse_encode_list_prim_u_8_strict(
      Uint8List self, SseSerializer serializer);

  @protected
  void sse_encode_list_quality(List<Quality> self, SseSerializer serializer);

  @protected
  void sse_encode_list_record_string_string(
      List<(String, String)> self, SseSerializer serializer);

  @protected
  void sse_encode_list_server_music_chart_collection(
      List<ServerMusicChartCollection> self, SseSerializer serializer);

  @protected
  void sse_encode_list_server_playlist_tag_collection(
      List<ServerPlaylistTagCollection> self, SseSerializer serializer);

  @protected
  void sse_encode_music(Music self, SseSerializer serializer);

  @protected
  void sse_encode_music_aggregator(
      MusicAggregator self, SseSerializer serializer);

  @protected
  void sse_encode_music_chart(MusicChart self, SseSerializer serializer);

  @protected
  void sse_encode_music_chart_collection(
      MusicChartCollection self, SseSerializer serializer);

  @protected
  void sse_encode_music_data_type(MusicDataType self, SseSerializer serializer);

  @protected
  void sse_encode_music_server(MusicServer self, SseSerializer serializer);

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_external_api_config(
      ExternalApiConfig? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_i_64(
      PlatformInt64? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_music_server(
      MusicServer? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_playlist(
      Playlist? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_record_play_info_string(
      (PlayInfo, String)? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_release(
      Release? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_window_config(
      WindowConfig? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_list_play_list_subscription(
      List<PlayListSubscription>? self, SseSerializer serializer);

  @protected
  void sse_encode_play_info(PlayInfo self, SseSerializer serializer);

  @protected
  void sse_encode_play_list_subscription(
      PlayListSubscription self, SseSerializer serializer);

  @protected
  void sse_encode_playlist(Playlist self, SseSerializer serializer);

  @protected
  void sse_encode_playlist_tag(PlaylistTag self, SseSerializer serializer);

  @protected
  void sse_encode_playlist_tag_collection(
      PlaylistTagCollection self, SseSerializer serializer);

  @protected
  void sse_encode_playlist_type(PlaylistType self, SseSerializer serializer);

  @protected
  void sse_encode_playlist_update_subscription_result(
      PlaylistUpdateSubscriptionResult self, SseSerializer serializer);

  @protected
  void sse_encode_quality(Quality self, SseSerializer serializer);

  @protected
  void sse_encode_quality_config(QualityConfig self, SseSerializer serializer);

  @protected
  void sse_encode_quality_option(QualityOption self, SseSerializer serializer);

  @protected
  void sse_encode_record_opt_box_autoadd_playlist_list_music_aggregator(
      (Playlist?, List<MusicAggregator>) self, SseSerializer serializer);

  @protected
  void sse_encode_record_play_info_string(
      (PlayInfo, String) self, SseSerializer serializer);

  @protected
  void sse_encode_record_string_string(
      (String, String) self, SseSerializer serializer);

  @protected
  void sse_encode_release(Release self, SseSerializer serializer);

  @protected
  void sse_encode_server_music_chart_collection(
      ServerMusicChartCollection self, SseSerializer serializer);

  @protected
  void sse_encode_server_playlist_tag_collection(
      ServerPlaylistTagCollection self, SseSerializer serializer);

  @protected
  void sse_encode_storage_config(StorageConfig self, SseSerializer serializer);

  @protected
  void sse_encode_tag_playlist_order(
      TagPlaylistOrder self, SseSerializer serializer);

  @protected
  void sse_encode_u_16(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_64(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_update_config(UpdateConfig self, SseSerializer serializer);

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_window_config(WindowConfig self, SseSerializer serializer);
}

// Section: wire_class

class RustLibWire implements BaseWire {
  factory RustLibWire.fromExternalLibrary(ExternalLibrary lib) =>
      RustLibWire(lib.ffiDynamicLibrary);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  RustLibWire(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  void
      rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
      ptr,
    );
  }

  late final _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapperPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'frbgen_app_rhyme_rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper');
  late final _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper =
      _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapperPtr
          .asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  void
      rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper(
      ptr,
    );
  }

  late final _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapperPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'frbgen_app_rhyme_rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper');
  late final _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapper =
      _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerMusicDataJsonWrapperPtr
          .asFunction<void Function(ffi.Pointer<ffi.Void>)>();
}

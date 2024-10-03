// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.4.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../frb_generated.dart';
import 'external_api.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `default_false`, `default_true`, `from_string`, `mobile_auto_quality`, `to_string`, `wifi_auto_quality`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `clone`, `clone`, `clone`, `clone`, `fmt`

class Config {
  /// 用户是否同意使用协议
  bool userAgreement;

  /// 音质相关设置
  QualityConfig qualityConfig;

  /// 音源设置
  ExternalApiConfig? externalApi;

  /// 更新设置
  UpdateConfig updateConfig;

  /// 储存设置
  StorageConfig storageConfig;

  /// 窗口设置(桌面系统only)
  WindowConfig? windowConfig;

  Config({
    required this.userAgreement,
    required this.qualityConfig,
    this.externalApi,
    required this.updateConfig,
    required this.storageConfig,
    this.windowConfig,
  });

  static Future<Config> default_() =>
      RustLib.instance.api.crateApiTypesConfigConfigDefault();

  String getSqlUrl({required String documentFolder}) =>
      RustLib.instance.api.crateApiTypesConfigConfigGetSqlUrl(
          that: this, documentFolder: documentFolder);

  String getStorageFolder({required String documentFolder}) =>
      RustLib.instance.api.crateApiTypesConfigConfigGetStorageFolder(
          that: this, documentFolder: documentFolder);

  static Future<Config> load({required String documentFolder}) =>
      RustLib.instance.api
          .crateApiTypesConfigConfigLoad(documentFolder: documentFolder);

  Future<void> save({required String documentFolder}) =>
      RustLib.instance.api.crateApiTypesConfigConfigSave(
          that: this, documentFolder: documentFolder);

  Future<Config> update() =>
      RustLib.instance.api.crateApiTypesConfigConfigUpdate(
        that: this,
      );

  @override
  int get hashCode =>
      userAgreement.hashCode ^
      qualityConfig.hashCode ^
      externalApi.hashCode ^
      updateConfig.hashCode ^
      storageConfig.hashCode ^
      windowConfig.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Config &&
          runtimeType == other.runtimeType &&
          userAgreement == other.userAgreement &&
          qualityConfig == other.qualityConfig &&
          externalApi == other.externalApi &&
          updateConfig == other.updateConfig &&
          storageConfig == other.storageConfig &&
          windowConfig == other.windowConfig;
}

class QualityConfig {
  QualityOption wifiAutoQuality;
  QualityOption mobileAutoQuality;

  QualityConfig({
    required this.wifiAutoQuality,
    required this.mobileAutoQuality,
  });

  static Future<QualityConfig> default_() =>
      RustLib.instance.api.crateApiTypesConfigQualityConfigDefault();

  @override
  int get hashCode => wifiAutoQuality.hashCode ^ mobileAutoQuality.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QualityConfig &&
          runtimeType == other.runtimeType &&
          wifiAutoQuality == other.wifiAutoQuality &&
          mobileAutoQuality == other.mobileAutoQuality;
}

enum QualityOption {
  highest,
  high,
  medium,
  low,
  ;
}

class StorageConfig {
  bool saveCover;
  String? customCacheRoot;
  String? customDb;

  StorageConfig({
    required this.saveCover,
    this.customCacheRoot,
    this.customDb,
  });

  static Future<StorageConfig> default_() =>
      RustLib.instance.api.crateApiTypesConfigStorageConfigDefault();

  @override
  int get hashCode =>
      saveCover.hashCode ^ customCacheRoot.hashCode ^ customDb.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageConfig &&
          runtimeType == other.runtimeType &&
          saveCover == other.saveCover &&
          customCacheRoot == other.customCacheRoot &&
          customDb == other.customDb;
}

class UpdateConfig {
  bool versionAutoUpdate;
  bool externalApiAutoUpdate;

  UpdateConfig({
    required this.versionAutoUpdate,
    required this.externalApiAutoUpdate,
  });

  static Future<UpdateConfig> default_() =>
      RustLib.instance.api.crateApiTypesConfigUpdateConfigDefault();

  @override
  int get hashCode =>
      versionAutoUpdate.hashCode ^ externalApiAutoUpdate.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateConfig &&
          runtimeType == other.runtimeType &&
          versionAutoUpdate == other.versionAutoUpdate &&
          externalApiAutoUpdate == other.externalApiAutoUpdate;
}

class WindowConfig {
  /// 启动时窗口的宽度
  int width;

  /// 启动时窗口的高度
  int height;

  /// 窗口的最小宽度
  int minWidth;

  /// 窗口的最小高度
  int minHeight;

  /// 窗口的最大宽度
  bool fullscreen;

  WindowConfig({
    required this.width,
    required this.height,
    required this.minWidth,
    required this.minHeight,
    required this.fullscreen,
  });

  static WindowConfig default_() =>
      RustLib.instance.api.crateApiTypesConfigWindowConfigDefault();

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      minWidth.hashCode ^
      minHeight.hashCode ^
      fullscreen.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowConfig &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          minWidth == other.minWidth &&
          minHeight == other.minHeight &&
          fullscreen == other.fullscreen;
}

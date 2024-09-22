import 'dart:io';

import 'package:app_rhyme/src/rust/api/cache/file_cache.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// 将url转换为本地缓存路径
// 如果本地缓存存在，则返回本地缓存路径
// 如果本地缓存不存在，则返回原始url
// 如果cacheNow为true，则立即后台缓存文件, 并返回原始url
String _getFileCacheWithUriWrapper(String uri, String cacheFolder,
    {String? filename, bool cacheNow = false}) {
  var localSource = getCacheFileFromUri(
      uri: uri,
      cacheFolder: cacheFolder,
      filename: filename,
      customRoot: globalConfig.exportCacheRoot,
      root: globalDocumentPath);

  if (localSource != null) {
    return localSource;
  } else {
    if (cacheNow) {
      cacheFileFromUriWrapper(uri, cacheFolder, filename: filename);
    }
    return uri;
  }
}

Future<String> cacheFileFromUriWrapper(String uri, String cacheFolder,
    {String? filename}) async {
  return await cacheFileFromUri(
    uri: uri,
    cacheFolder: cacheFolder,
    filename: filename,
    customRoot: globalConfig.exportCacheRoot,
  );
}

Future<void> deleteFileCacheWithUriWrapper(String uri, String cacheFolder,
    {String? filename}) async {
  await deleteCacheFileWithUri(
    uri: uri,
    cacheFolder: cacheFolder,
    filename: filename,
    customRoot: globalConfig.exportCacheRoot,
  );
}

ExtendedImage imageWithCache(
  String? url, {
  bool cacheNow = false,
  double? width,
  double? height,
  BoxFit? fit,
  double? scale = 0.1,
  BorderRadius? borderRadius,
}) {
  // 先判断url是否为空
  if (url == null || url.isEmpty) {
    return ExtendedImage.asset(
      defaultCoverPath,
      width: width,
      height: height,
      fit: fit,
      scale: scale,
      borderRadius: borderRadius,
      clearMemoryCacheIfFailed: true,
      clearMemoryCacheWhenDispose: true,
      enableMemoryCache: false,
    );
  }

  String? uri =
      _getFileCacheWithUriWrapper(url, picCacheFolder, cacheNow: cacheNow);

  if (uri.startsWith("http")) {
    return ExtendedImage.network(
      uri,
      width: width,
      height: height,
      fit: fit,
      scale: scale ?? 1.0,
      borderRadius: borderRadius,
      clearMemoryCacheIfFailed: true,
      clearMemoryCacheWhenDispose: true,
      enableMemoryCache: false,
    );
  } else {
    return ExtendedImage.file(
      File(uri),
      width: width,
      height: height,
      fit: fit,
      scale: scale ?? 1.0,
      borderRadius: borderRadius,
      clearMemoryCacheIfFailed: true,
      clearMemoryCacheWhenDispose: true,
      enableMemoryCache: false,
    );
  }
}

import 'dart:io';

import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// 将url转换为本地缓存路径
// 如果本地缓存存在，则返回本地缓存路径
// 如果本地缓存不存在，则返回原始url
// 如果cacheNow为true，则立即缓存文件, 并返回原始url
String _useFileCacheHelper(String url, String cacheRoot,
    {String? filename, bool cacheNow = false}) {
  var localSource = useCacheFile(
      file: url,
      cachePath: cacheRoot,
      filename: filename,
      exportRoot: globalConfig.exportCacheRoot);

  if (localSource != null) {
    return localSource;
  } else {
    if (cacheNow) {
      cacheFileHelper(url, cacheRoot, filename: filename);
    }
    return url;
  }
}

Future<String> cacheFileHelper(String url, String cacheRoot,
    {String? filename}) async {
  return await cacheFile(
    file: url,
    cachePath: cacheRoot,
    filename: filename,
    exportRoot: globalConfig.exportCacheRoot,
  );
}

Future<void> deleteFileCacheHelper(String url, String cacheRoot,
    {String? filename}) async {
  await deleteCacheFile(
    file: url,
    cachePath: cacheRoot,
    filename: filename,
    exportRoot: globalConfig.exportCacheRoot,
  );
}

ExtendedImage imageCacheHelper(
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
      defaultArtPicPath,
      width: width,
      height: height,
      fit: fit,
      scale: scale,
      borderRadius: borderRadius,
    );
  }

  String? uri = _useFileCacheHelper(url, picCacheRoot, cacheNow: cacheNow);

  if (uri.startsWith("http")) {
    return ExtendedImage.network(
      uri,
      width: width,
      height: height,
      fit: fit,
      scale: scale ?? 1.0,
      enableMemoryCache: true,
      borderRadius: borderRadius,
    );
  } else {
    return ExtendedImage.file(
      File(uri),
      width: width,
      height: height,
      fit: fit,
      scale: scale ?? 1.0,
      borderRadius: borderRadius,
    );
  }
}

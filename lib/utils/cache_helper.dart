import 'dart:io';

import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

// 将url转换为本地缓存路径
String fileCacheHelper(String url, String cacheRoot, [bool cacheNow = false]) {
  var localSource = useCacheFile(
    file: url,
    cachePath: cacheRoot,
  );

  if (localSource != null) {
    return localSource;
  } else {
    if (cacheNow) {
      cacheFile(file: url, cachePath: cacheRoot);
    }
    return url;
  }
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

  String? uri = fileCacheHelper(url, picCacheRoot, cacheNow);

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

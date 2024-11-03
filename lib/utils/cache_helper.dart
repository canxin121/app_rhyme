import 'dart:io';
import 'package:app_rhyme/src/rust/api/cache/file_cache.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';

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
      customCacheRoot: globalConfig.storageConfig.customCacheRoot,
      documentFolder: globalDocumentPath);

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
      customCacheRoot: globalConfig.storageConfig.customCacheRoot,
      documentFolder: globalDocumentPath);
}

Future<void> deleteFileCacheWithUriWrapper(String uri, String cacheFolder,
    {String? filename}) async {
  await deleteCacheFileWithUri(
    uri: uri,
    cacheFolder: cacheFolder,
    filename: filename,
    customCacheRoot: globalConfig.storageConfig.customCacheRoot,
    documentFolder: globalDocumentPath,
  );
}

ExtendedImage imageWithCache(
  String? url, {
  bool enableCache = false,
  double? width,
  double? height,
  double? cacheWidth,
  double? cacheHeight,
  double? scale = 0.1,
  BorderRadius? borderRadius,
}) {
  // 先判断url是否为空
  if (url == null || url.isEmpty) {
    return ExtendedImage.asset(
      defaultCoverPath,
      width: width,
      height: height,
      cacheWidth: cacheWidth?.toInt() ?? width?.toInt(),
      cacheHeight: cacheHeight?.toInt() ?? height?.toInt(),
      fit: BoxFit.cover,
      scale: scale,
      borderRadius: borderRadius,
      enableMemoryCache: true,
    );
  }

  String? uri =
      _getFileCacheWithUriWrapper(url, picCacheFolder, cacheNow: enableCache);

  if (uri.startsWith("http")) {
    return ExtendedImage.network(
      uri,
      width: width,
      height: height,
      cacheWidth: cacheWidth?.toInt() ?? width?.toInt(),
      cacheHeight: cacheHeight?.toInt() ?? height?.toInt(),
      fit: BoxFit.cover,
      scale: scale ?? 1.0,
      borderRadius: borderRadius,
      enableMemoryCache: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return SizedBox(
                height: width ?? 200,
                width: width ?? 200,
                child: Center(child: CupertinoActivityIndicator()));
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return ExtendedImage.asset(
              defaultCoverPath,
              width: width,
              height: height,
              cacheWidth: cacheWidth?.toInt() ?? width?.toInt(),
              cacheHeight: cacheHeight?.toInt() ?? height?.toInt(),
              fit: BoxFit.cover,
              scale: scale,
              borderRadius: borderRadius,
              clearMemoryCacheIfFailed: true,
              clearMemoryCacheWhenDispose: true,
              enableMemoryCache: true,
            );
        }
      },
    );
  } else {
    return ExtendedImage.file(
      File(uri),
      width: width,
      height: height,
      cacheWidth: cacheWidth?.toInt() ?? width?.toInt(),
      cacheHeight: cacheHeight?.toInt() ?? height?.toInt(),
      fit: BoxFit.cover,
      scale: scale ?? 1.0,
      borderRadius: borderRadius,
      enableMemoryCache: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return const CupertinoActivityIndicator();
          case LoadState.completed:
            return state.completedWidget;
          case LoadState.failed:
            return ExtendedImage.asset(
              defaultCoverPath,
              width: width,
              height: height,
              cacheWidth: cacheWidth?.toInt() ?? width?.toInt(),
              cacheHeight: cacheHeight?.toInt() ?? height?.toInt(),
              fit: BoxFit.cover,
              scale: scale,
              borderRadius: borderRadius,
              clearMemoryCacheIfFailed: true,
              clearMemoryCacheWhenDispose: true,
              enableMemoryCache: true,
            );
        }
      },
    );
  }
}

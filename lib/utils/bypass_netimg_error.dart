import 'dart:io';

import 'package:extended_image/extended_image.dart';

/// 防止tls问题导致图片无法加载
Future<void> initBypassNetImgError() async {
  HttpClient client = ExtendedNetworkImageProvider.httpClient;
  client.userAgent = null;
  client.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
}

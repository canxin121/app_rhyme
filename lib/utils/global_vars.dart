import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_rhyme/types/audio_controller.dart';
import 'package:app_rhyme/src/rust/api/init.dart';
import 'package:app_rhyme/src/rust/api/types/config.dart';
import 'package:app_rhyme/types/chore.dart';
import 'package:app_rhyme/types/extern_api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

Talker globalTalker = Talker();

late Config globalConfig;
late ExternalApiEvaler? globalExternalApiEvaler;
late AudioHandler globalAudioHandler;
late AudioUiController globalAudioUiController;
late PackageInfo globalPackageInfo;
late String globalDocumentPath;
late Connectivity globalConnectivity;
ConnectivityStateSimple globalConnectivityStateSimple =
    ConnectivityStateSimple.none;

// 初始化全局变量
// 即可用于在App启动时也可用于配置更新时
Future<void> initGlobalVars() async {
  // 初始化rust全局配置，将documentPath设置为应用程序文档目录
  globalDocumentPath = (await getApplicationDocumentsDirectory()).path;
  // 初始化全局变量globalConfig
  globalConfig = await initBackend(documentFolder: globalDocumentPath);

  // 如果没有配置外部API或API文件不存在,则加载内置API
  if (globalConfig.externalApi == null || 
      !File(globalConfig.externalApi?.filePath ?? "").existsSync()) {
        
    // 从assets中读取内置API文件
    ByteData data = await rootBundle.load('lib/assets/api/custom_api_2.0.evc');
    List<int> bytes = data.buffer.asUint8List();
    
    // 将文件写入应用文档目录
    String apiPath = '$globalDocumentPath/builtin_api_2.0.evc';
    await File(apiPath).writeAsBytes(bytes);
    
    // 更新配置
    globalConfig.externalApi = ExternalApi(
      filePath: apiPath,
      url: "", // 留空表示使用内置API
    );
    await globalConfig.save(documentFolder: globalDocumentPath);
  }

  // 初始化全局变量globalExternalApi
  if (globalConfig.externalApi != null) {
    globalExternalApiEvaler = 
        ExternalApiEvaler(globalConfig.externalApi!.filePath);
  } else {
    globalExternalApiEvaler = null;
  }

  // 初始化应用包信息
  globalPackageInfo = await PackageInfo.fromPlatform();
  // 监听网络状态变化
  globalConnectivity = Connectivity();
  globalConnectivity.onConnectivityChanged
      .listen((List<ConnectivityResult> connectivityResult) {
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      globalConnectivityStateSimple = ConnectivityStateSimple.wifi;
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      globalConnectivityStateSimple = ConnectivityStateSimple.mobile;
    } else {
      globalConnectivityStateSimple = ConnectivityStateSimple.none;
    }
  });
}

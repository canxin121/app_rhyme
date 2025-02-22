import 'package:app_rhyme/types/audio_control.dart';
import 'package:app_rhyme/src/rust/api/init.dart';
import 'package:app_rhyme/src/rust/api/types/config.dart';
import 'package:app_rhyme/types/chore.dart';
import 'package:app_rhyme/types/fr_logger.dart';
import 'package:app_rhyme/types/plugin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

late FRLogger globalLogger;
late Config globalConfig;
late PluginEvaler? globalExternalApiEvaler;
late AudioHandler globalAudioHandler;
late AudioUiController globalAudioUiController;
late PackageInfo globalPackageInfo;
late String globalDocumentPath;
late Connectivity globalConnectivity;
ConnectivityStateSimple globalConnectivityStateSimple =
    ConnectivityStateSimple.none;

/// 初始化全局变量
// 即可用于在App启动时也可用于配置更新时
Future<void> initGlobalVars() async {
  // 初始化rust全局配置，将documentPath设置为应用程序文档目录
  globalDocumentPath = (await getApplicationDocumentsDirectory()).path;
  // 初始化全局变量globalConfig
  globalConfig = await initBackend(documentFolder: globalDocumentPath);
  // 初始化全局变量globalExternalApi
  if (globalConfig.externalApi != null) {
    globalExternalApiEvaler = PluginEvaler(globalConfig.externalApi!.filePath);
  } else {
    globalExternalApiEvaler = null;
  }

  globalLogger = await createFRLogger();

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

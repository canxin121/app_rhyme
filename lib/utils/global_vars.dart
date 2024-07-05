import 'package:app_rhyme/audioControl/audio_controller.dart';
import 'package:app_rhyme/src/rust/api/config.dart';
import 'package:app_rhyme/src/rust/api/init.dart';
import 'package:app_rhyme/types/chore.dart';
import 'package:app_rhyme/utils/extern_api.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

Talker globalTalker = Talker();

// 在`init_backend.dart` 中被初始化
late Config globalConfig;

late ExternApiEvaler? globalExternApiEvaler;
late AudioHandler globalAudioHandler;
late AudioUiController globalAudioUiController;
late PackageInfo globalPackageInfo;

late Connectivity globalConnectivity;
ConnectivityStateSimple globalConnectivityStateSimple =
    ConnectivityStateSimple.none;

// 初始化全局变量
// 即可用于在App启动时也可用于配置更新时
Future<void> initGlobalVars() async {
  // 初始化rust全局配置，将documentPath设置为应用程序文档目录
  String documentPath = (await getApplicationDocumentsDirectory()).path;
  // 初始化全局变量globalConfig
  globalConfig = await initBackend(storeRoot: documentPath);
  // 初始化全局变量globalExternApi
  if (globalConfig.externApi != null) {
    globalExternApiEvaler = ExternApiEvaler(globalConfig.externApi!.localPath);
  } else {
    globalExternApiEvaler = null;
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

import 'dart:ui';

import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/src/rust/api/config.dart';
import 'package:app_rhyme/src/rust/api/init.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/types/extern_api.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/window.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';

Talker talker = Talker();

late SqlMusicFactoryW globalSqlMusicFactory;
late Config globalConfig;
ExternApi? globalExternApi;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindow();

  await RustLib.init();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    talker.error("[Flutter Error] $details");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    talker.error("[PlatForm Error] Error: $error\nStackTrace: $stack");
    return true;
  };
  String rootPath = (await getApplicationDocumentsDirectory()).path;
  var stores = await initStore(storeRoot: rootPath);
  globalSqlMusicFactory = stores.$1;
  globalConfig = stores.$2;
  if (globalConfig.externApiPath != null) {
    try {
      globalExternApi = ExternApi(globalConfig.externApiPath!);
    } catch (e) {
      talker.error("[Main] 加载第三方音乐源失败: $e");
    }
  }

  await initGlobalAudioHandler();
  await initGlobalAudioUiController();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      title: 'AppRhyme',
      theme: CupertinoThemeData(
          primaryColor: CupertinoColors.black,
          textTheme: CupertinoTextThemeData(
              textStyle: const TextStyle(color: CupertinoColors.black)
                  .useSystemChineseFont())),
      home: const HomePage(),
    );
  }
}

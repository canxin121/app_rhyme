import 'package:app_rhyme/desktop/home.dart';
import 'package:app_rhyme/mobile/home.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/types/audio_control.dart';
import 'package:app_rhyme/src/rust/frb_generated.dart';
import 'package:app_rhyme/utils/device_set.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  await initGlobalVars();
  await initBypassNetImgError();
  initFlutterLogger();

  await initGlobalAudioHandler();
  await initGlobalAudioUiController();
  runApp(const MyApp());
  await initDesktopWindowSetting();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isWidthGreaterThanHeight = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initMobileDevice(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _isWidthGreaterThanHeight = isWidthGreaterThanHeight(context);
        return ToastificationWrapper(
            child: CupertinoApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          theme: CupertinoThemeData(
            applyThemeToAll: true,
            textTheme: CupertinoTextThemeData(
              textStyle: const TextStyle(color: CupertinoColors.black)
                  .useSystemChineseFont(),
            ),
          ),
          home: _isWidthGreaterThanHeight || isDesktopDevice()
              ? const DesktopHome()
              : const MobileHome(),
        ));
      },
    );
  }
}

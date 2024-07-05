import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/audioControl/audio_controller.dart';
import 'package:app_rhyme/comps/play_display_comp/music_control_bar.dart';
import 'package:app_rhyme/pages/local_music_list_grid_page.dart';
import 'package:app_rhyme/pages/more_page.dart';
import 'package:app_rhyme/pages/search_page.dart';
import 'package:app_rhyme/src/rust/frb_generated.dart';
import 'package:app_rhyme/utils/bypass_netimg_error.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/desktop_window_manager.dart';
import 'package:app_rhyme/utils/global_vars.dart';
// import 'package:app_rhyme/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  await initGlobalVars();
  await initDesktopWindowSetting();
  await initBypassNetImgError();
  // initFlutterLogger();

  await initGlobalAudioHandler();
  await initGlobalAudioUiController();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
        child: CupertinoApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: const TextStyle(color: CupertinoColors.black)
              .useSystemChineseFont(),
        ),
      ),
      home: const Home(),
    ));
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const LocalMusicListGridPage(),
    const CombinedSearchPage(),
    const MorePage(),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoCheckUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MusicControlBar(maxHeight: 60),
                CupertinoTabBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Icon(
                          CupertinoIcons.music_albums_fill,
                        ),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Icon(CupertinoIcons.search),
                      ),
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Icon(CupertinoIcons.settings),
                      ),
                    ),
                  ],
                  activeColor: activeIconRed, // Set the active color here
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

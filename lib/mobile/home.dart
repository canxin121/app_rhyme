import 'package:app_rhyme/dialogs/user_aggrement_dialog.dart';
import 'package:app_rhyme/mobile/pages/search_page/combined_search_page.dart';
import 'package:app_rhyme/mobile/comps/play_display_comp/music_control_bar.dart';
import 'package:app_rhyme/mobile/pages/db_playlist_gridview_page.dart';
import 'package:app_rhyme/common_pages/setting_page.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({super.key});

  @override
  MobileHomeState createState() => MobileHomeState();
}

class MobileHomeState extends State<MobileHome> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _pages = [
    const LocalMusicListGridPage(),
    const CombinedSearchPage(),
    const SettingPage(
      isDesktop: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showUserAgreement(context);
      if (mounted) {
        await autoCheckUpdate(context);
      }
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeAll();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!mounted) return true;

    if (_navigatorKeys[_selectedIndex].currentState!.canPop()) {
      _navigatorKeys[_selectedIndex].currentState!.pop();
      return true;
    } else if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 56, 56, 57)
        : const Color.fromARGB(255, 209, 209, 209);
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages.asMap().entries.map((entry) {
                int idx = entry.key;
                Widget page = entry.value;
                return Navigator(
                  key: _navigatorKeys[idx],
                  onGenerateRoute: (RouteSettings settings) {
                    return CupertinoPageRoute(
                      builder: (context) => page,
                    );
                  },
                );
              }).toList(),
            ),
          ),
          // 页面底部的音乐控制栏和底部导航栏
          KeyboardVisibilityBuilder(
            builder: (p0, isKeyboardVisible) => isKeyboardVisible
                ? const SizedBox(
                    width: 0,
                    height: 0,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MusicControlBar(maxHeight: 60),
                      Center(
                        child: Divider(
                          color: dividerColor,
                          height: 0.5,
                        ),
                      ),
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
                        activeColor: activeIconRed,
                      ),
                    ],
                  ),
          )
        ],
      ),
    );
  }
}

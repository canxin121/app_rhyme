import 'dart:math';

import 'package:app_rhyme/comp/music_bar/bar.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/out_music_list_grid.dart';
import 'package:app_rhyme/page/search_page.dart';
import 'package:app_rhyme/page/setting.dart';
import 'package:app_rhyme/page/user_agreement.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

final TopUiController globalTopUiController = Get.put(TopUiController());

class TopUiController extends GetxController {
  var currentIndex = 0.obs;
  Rx<Widget> currentWidget = Rx<Widget>(const MusicTablesPage());

  void changeTabIndex(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        currentWidget.value = const MusicTablesPage();
        break;
      case 1:
        currentWidget.value = const SearchPage();
        break;
      case 2:
        currentWidget.value = const SettingsPage();
        break;
      default:
        currentWidget.value = const Text("No Widget");
    }
    update();
  }

  void updateWidget(Widget widget) {
    currentWidget.value = widget;
    update();
  }

  void backToOriginWidget() {
    changeTabIndex(currentIndex.value);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isKeyboardVisible = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!globalConfig.userAgreement) {
        showUserAgreement(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: Stack(
        children: [
          SafeArea(
            child: Obx(() => globalTopUiController.currentWidget.value),
          ),

          // 以下内容改成固定在页面底部的
          // 使用MediaQuery检测键盘是否可见
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 音乐播放控制栏
                MusicPlayBar(
                  maxHeight: min(60, MediaQuery.of(context).size.height * 0.1),
                ),
                // 底部导航按钮
                Obx(() => CupertinoTabBar(
                      activeColor: activeIconColor,
                      backgroundColor: barBackgoundColor,
                      currentIndex: globalTopUiController.currentIndex.value,
                      onTap: globalTopUiController.changeTabIndex,
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
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

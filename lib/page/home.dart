import 'package:app_rhyme/comp/music_bar/bar.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/out_music_list_grid.dart';
import 'package:app_rhyme/page/search_page.dart';
import 'package:app_rhyme/page/setting.dart';
import 'package:app_rhyme/page/user_agreement.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
      // 监听键盘状态的变化
      KeyboardVisibilityController().onChange.listen((bool visible) {
        setState(() {
          isKeyboardVisible = visible;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Obx(() => globalTopUiController.currentWidget.value),

          // 以下内容改成固定在页面底部的
          // 使用MediaQuery检测键盘是否可见
          if (!isKeyboardVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 音乐播放控制栏
                  const MusicPlayBar(),
                  Obx(() => CupertinoTabBar(
                        activeColor: activeIconColor,
                        backgroundColor: barBackgoundColor,
                        currentIndex: globalTopUiController.currentIndex.value,
                        onTap: globalTopUiController.changeTabIndex,
                        items: const [
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Icon(
                                CupertinoIcons.music_albums_fill,
                              ),
                            ),
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Icon(CupertinoIcons.search),
                            ),
                          ),
                          BottomNavigationBarItem(
                            icon: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Icon(CupertinoIcons.settings),
                            ),
                          ),
                        ],
                      )),
                  // 底部导航栏图标按钮和底部的一个空白边界
                  Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      color: barBackgoundColor)
                ],
              ),
            ),
        ],
      ),
    );
  }
}

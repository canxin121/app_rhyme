import 'package:app_rhyme/desktop/comps/control_bar.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/pages/local_music_list_gridview_page.dart';
import 'package:app_rhyme/dialogs/user_aggrement_dialog.dart';
import 'package:app_rhyme/utils/check_update.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';

late BuildContext globalDesktopPageContext;
GlobalKey globalDesktopNavigatorKey = GlobalKey();

class DesktopHome extends StatefulWidget {
  const DesktopHome({super.key});

  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
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

    if (Navigator.of(globalDesktopPageContext).canPop()) {
      Navigator.of(globalDesktopPageContext).pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
          child: Row(
        children: [
          const MyNavListContainer(),
          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                  child: ControlBar(),
                ),
                Expanded(
                  child: Navigator(
                    key: globalDesktopNavigatorKey,
                    onGenerateRoute: (RouteSettings settings) {
                      return CupertinoPageRoute(
                        builder: (context) {
                          globalDesktopPageContext = context;
                          return const DesktopLocalMusicListGridPage();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

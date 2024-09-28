import 'package:app_rhyme/common_pages/search_page/music_aggregator.dart';
import 'package:app_rhyme/common_pages/search_page/playlist.dart';
import 'package:flutter/cupertino.dart';

void Function() globalMobileToggleSearchPage = () {};

class CombinedSearchPage extends StatefulWidget {
  const CombinedSearchPage({super.key});

  @override
  CombinedSearchPageState createState() => CombinedSearchPageState();
}

class CombinedSearchPageState extends State<CombinedSearchPage>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  void _onToggle() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % 2;
    });
  }

  @override
  void initState() {
    globalMobileToggleSearchPage = _onToggle;
    WidgetsBinding.instance.addObserver(this); // 添加观察者
    super.initState();
  }

  @override
  void dispose() {
    globalMobileToggleSearchPage = () {};
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor:
          isDarkMode ? CupertinoColors.black : CupertinoColors.white,
      child: IndexedStack(
        index: _selectedIndex,
        children: const [
          MusicAggregatorSearchPage(
            isDesktop: false,
          ),
          PlaylistSearchPage(
            isDesktop: false,
          ),
        ],
      ),
    );
  }
}

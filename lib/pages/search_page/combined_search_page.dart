import 'package:app_rhyme/pages/search_page/search_music_aggregator_page.dart';
import 'package:app_rhyme/pages/search_page/search_music_list_page.dart';
import 'package:flutter/cupertino.dart';

void Function() globalToggleSearchPage = () {};

class CombinedSearchPage extends StatefulWidget {
  const CombinedSearchPage({super.key});

  @override
  _CombinedSearchPageState createState() => _CombinedSearchPageState();
}

class _CombinedSearchPageState extends State<CombinedSearchPage>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  void _onToggle() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % 2;
    });
  }

  @override
  void initState() {
    globalToggleSearchPage = _onToggle;
    WidgetsBinding.instance.addObserver(this); // 添加观察者
    super.initState();
  }

  @override
  void dispose() {
    globalToggleSearchPage = () {};
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
          SearchMusicAggregatorPage(),
          SearchMusicListPage(),
        ],
      ),
    );
  }
}

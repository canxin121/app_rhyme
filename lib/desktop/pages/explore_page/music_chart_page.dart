import 'package:app_rhyme/common_comps/explore/music_chart_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';

class MusicChartPage extends StatefulWidget {
  final bool isDesktop;

  const MusicChartPage({
    super.key,
    required this.isDesktop,
  });

  @override
  MusicChartPageState createState() => MusicChartPageState();
}

class MusicChartPageState extends State<MusicChartPage>
    with WidgetsBindingObserver {
  final List<ServerMusicChartCollection> serverMusicChartCollections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchMusicCharts();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  void fetchMusicCharts() async {
    List<ServerMusicChartCollection> collections =
        await ServerMusicChartCollection.getMusicChartCollection();
    setState(() {
      serverMusicChartCollections.clear();
      serverMusicChartCollections.addAll(collections);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: getNavigatorBarColor(isDarkMode),
        middle: Text(
          '音乐排行榜',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: getTextColor(isDarkMode),
          ).useSystemChineseFont(),
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? Center(child: CupertinoActivityIndicator())
            : serverMusicChartCollections.isEmpty
                ? Center(
                    child: Text(
                      '暂无排行榜数据',
                      style: TextStyle(
                        fontSize: 18,
                        color: getTextColor(isDarkMode),
                      ).useSystemChineseFont(),
                    ),
                  )
                : MusicChartCollectionList(
                    collections: serverMusicChartCollections,
                    isDesktop: widget.isDesktop,
                  ),
      ),
    );
  }
}

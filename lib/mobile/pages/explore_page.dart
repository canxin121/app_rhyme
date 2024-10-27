import 'package:app_rhyme/common_comps/explore/music_chart_collection.dart';
import 'package:app_rhyme/common_comps/explore/playlist_tag_collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:chinese_font_library/chinese_font_library.dart';

enum ExploreSegment {
  musicChart,
  playlistTag,
}

extension ExploreSegmentExtension on ExploreSegment {
  String get displayName {
    switch (this) {
      case ExploreSegment.musicChart:
        return '音乐排行榜';
      case ExploreSegment.playlistTag:
        return '浏览歌单';
      default:
        return '';
    }
  }
}

class MobileExplorePage extends StatefulWidget {
  const MobileExplorePage({super.key});

  @override
  MobileExplorePageState createState() => MobileExplorePageState();
}

class MobileExplorePageState extends State<MobileExplorePage> {
  ExploreSegment _selectedSegment = ExploreSegment.musicChart;
  List<ServerMusicChartCollection> musicCharts = [];
  List<ServerPlaylistTagCollection> playlistTags = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMusicCharts();
    fetchPlaylistTags();
  }

  Future<void> fetchMusicCharts() async {
    List<ServerMusicChartCollection> collections =
        await ServerMusicChartCollection.getMusicChartCollection();
    setState(() {
      musicCharts = collections;
      isLoading = false;
    });
  }

  Future<void> fetchPlaylistTags() async {
    List<ServerPlaylistTagCollection> collections =
        await ServerPlaylistTagCollection.getPlaylistTags();
    setState(() {
      playlistTags = collections;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          _selectedSegment.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textColor,
          ).useSystemChineseFont(),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: CupertinoSlidingSegmentedControl<ExploreSegment>(
                groupValue: _selectedSegment,
                onValueChanged: (ExploreSegment? value) {
                  if (value != null) {
                    setState(() {
                      _selectedSegment = value;
                    });
                  }
                },
                children: {
                  ExploreSegment.musicChart:
                      Text(ExploreSegment.musicChart.displayName),
                  ExploreSegment.playlistTag:
                      Text(ExploreSegment.playlistTag.displayName),
                },
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CupertinoActivityIndicator())
                  : _selectedSegment == ExploreSegment.musicChart
                      ? MusicChartCollectionList(
                          collections: musicCharts,
                          isDesktop: false,
                        )
                      : PlaylistTagCollectionList(
                          collections: playlistTags,
                          isDesktop: false,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

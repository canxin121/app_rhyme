import 'package:app_rhyme/common_comps/card/rhyme_card.dart';
import 'package:app_rhyme/common_pages/online_music_agg_listview_page.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/navigate.dart';

class MusicChartCollectionSlider extends StatelessWidget {
  final MusicServer server;
  final MusicChartCollection chartCollection;
  final bool isDesktop;
  final double imageCardSize;

  const MusicChartCollectionSlider({
    super.key,
    required this.server,
    required this.chartCollection,
    required this.isDesktop,
    this.imageCardSize = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
          child: Text(
            chartCollection.name,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
              color: getTextColor(isDarkMode),
            ).useSystemChineseFont(),
          ),
        ),
        SizedBox(
          height: imageCardSize + 16.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: chartCollection.charts.length,
            itemBuilder: (context, index) {
              final musicChart = chartCollection.charts[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                    height: imageCardSize + 16.0,
                    width: imageCardSize,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: RhymeCard(
                              title: musicChart.name,
                              subtitle: musicChart.summary,
                              onClick: () {
                                navigate(
                                    context,
                                    OnlineMusicAggregatorListViewPage(
                                        title: musicChart.name,
                                        summary: musicChart.summary,
                                        isDesktop: isDesktop,
                                        fetchMusicAggregators:
                                            (int page, int limit) async {
                                          return await ServerMusicChartCollection
                                              .getMusicsFromChart(
                                                  server: server,
                                                  id: musicChart.id,
                                                  page: page,
                                                  limit: limit);
                                        }),
                                    isDesktop,
                                    "");
                              },
                              onSecondaryClick: () {},
                            )))),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ServerMusicChartCollectionSliderRows extends StatelessWidget {
  final ServerMusicChartCollection serverMusicChartCollection;
  final double imageCardSize;
  final bool isDesktop;

  const ServerMusicChartCollectionSliderRows(
      {super.key,
      required this.serverMusicChartCollection,
      required this.isDesktop,
      this.imageCardSize = 200});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Text(
            serverMusicChartCollection.server.name,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ).useSystemChineseFont(),
          ),
        ),
        const SizedBox(height: 16.0),
        Column(
          children:
              serverMusicChartCollection.collections.map((chartCollection) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MusicChartCollectionSlider(
                server: serverMusicChartCollection.server,
                chartCollection: chartCollection,
                isDesktop: isDesktop,
                imageCardSize: imageCardSize,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MusicChartCollectionList extends StatelessWidget {
  final List<ServerMusicChartCollection> collections;
  final bool isDesktop;

  const MusicChartCollectionList({
    super.key,
    required this.collections,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final serverMusicChartCollection = collections[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ServerMusicChartCollectionSliderRows(
            serverMusicChartCollection: serverMusicChartCollection,
            isDesktop: isDesktop,
          ),
        );
      },
    );
  }
}

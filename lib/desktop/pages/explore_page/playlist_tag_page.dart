import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/common_comps/explore/playlist_tag_collection.dart';
import 'package:chinese_font_library/chinese_font_library.dart';

class PlaylistTagPage extends StatefulWidget {
  final bool isDesktop;

  const PlaylistTagPage({
    super.key,
    required this.isDesktop,
  });

  @override
  PlaylistTagPageState createState() => PlaylistTagPageState();
}

class PlaylistTagPageState extends State<PlaylistTagPage>
    with WidgetsBindingObserver {
  final List<ServerPlaylistTagCollection> serverPlaylistTagCollections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchPlaylistTags();
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

  void fetchPlaylistTags() async {
    List<ServerPlaylistTagCollection> collections =
        await ServerPlaylistTagCollection.getPlaylistTags();
    setState(() {
      serverPlaylistTagCollections.clear();
      serverPlaylistTagCollections.addAll(collections);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
        backgroundColor: getBackgroundColor(widget.isDesktop, isDarkMode),
        child: Column(
          children: [
            CupertinoNavigationBar(
              backgroundColor: getNavigatorBarColor(isDarkMode),
              middle: Text(
                '浏览歌单',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ).useSystemChineseFont(),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CupertinoActivityIndicator())
                  : serverPlaylistTagCollections.isEmpty
                      ? Center(
                          child: Text(
                            '暂无歌单标签',
                            style: TextStyle(
                              fontSize: 18,
                              color: getTextColor(isDarkMode),
                            ).useSystemChineseFont(),
                          ),
                        )
                      : PlaylistTagCollectionList(
                          collections: serverPlaylistTagCollections,
                          isDesktop: widget.isDesktop,
                        ),
            )
          ],
        ));
  }
}

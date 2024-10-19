import 'dart:async';
import 'package:app_rhyme/common_comps/playlist/tag_playlist_slider.dart';
import 'package:app_rhyme/pulldown_menus/playlist_collection_listview_page_menu.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class DbPlaylistCollectionPage extends StatefulWidget {
  final bool isDesktop;

  const DbPlaylistCollectionPage({
    super.key,
    required this.isDesktop,
  });

  @override
  DbPlaylistCollectionPageState createState() =>
      DbPlaylistCollectionPageState();
}

class DbPlaylistCollectionPageState extends State<DbPlaylistCollectionPage>
    with WidgetsBindingObserver {
  final List<(PlaylistCollection, List<Playlist>)> playlistsCollections = [];

  late StreamSubscription<PlaylistCollection>
      playlistCollectionUpdateStreamSubscription;
  late StreamController<void> playlistCollectionsPageRefreshStreamController =
      StreamController.broadcast();
  late StreamSubscription<String> playlistDeleteStreamSubscription;

  @override
  Widget build(BuildContext context) {
    return widget.isDesktop ? buildDesktopUI() : buildMobileUI();
  }

  void fetchPlaylists({
    List<PlaylistCollection>? collections,
  }) async {
    collections ??= await PlaylistCollection.getFormDb();
    playlistsCollections.clear();
    for (var collection in collections) {
      var playlists = await collection.getPlaylistsFromDb();
      setState(() {
        playlistsCollections.add((collection, playlists));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    playlistCollectionUpdateStreamSubscription =
        playlistCollectionUpdateStreamController.stream
            .listen((playlistCollection) {
      var index = playlistsCollections
          .indexWhere((e) => e.$1.id == playlistCollection.id);
      if (index == -1) {
        return;
      }
      setState(() {
        playlistsCollections[index] =
            (playlistCollection, playlistsCollections[index].$2);
      });
    });

    playlistCollectionsPageRefreshStreamController.stream.listen((_) {
      fetchPlaylists();
    });

    playlistDeleteStreamSubscription =
        playlistDeleteStreamController.stream.listen((playlistId) {
      var index = playlistsCollections.indexWhere(
          (e) => e.$2.indexWhere((e) => e.identity == playlistId) != -1);
      if (index == -1) {
        return;
      }
      setState(() {
        playlistsCollections[index] = (
          playlistsCollections[index].$1,
          playlistsCollections[index]
              .$2
              .where((e) => e.identity != playlistId)
              .toList()
        );
      });
    });

    fetchPlaylists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    playlistCollectionUpdateStreamSubscription.cancel();
    playlistCollectionsPageRefreshStreamController.close();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  Widget buildDesktopUI() {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoPageScaffold(
        backgroundColor: getPrimaryBackgroundColor(isDarkMode),
        navigationBar: CupertinoNavigationBar(
          backgroundColor: getNavigatorBarColor(isDarkMode),
          leading: Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '所有歌单列表',
                style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor)
                    .useSystemChineseFont(),
              ),
            ),
          ),
          trailing: PlaylistCollectionPageMenu(
            builder: (context, showMenu) => CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: showMenu,
                child: Text(
                  '选项',
                  style: TextStyle(color: activeIconRed).useSystemChineseFont(),
                )),
            isDesktop: true,
            playlists:
                playlistsCollections.map((e) => e.$2).expand((e) => e).toList(),
          ),
        ),
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: playlistsCollections.length,
                itemBuilder: (context, index) {
                  var collection = playlistsCollections[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TagPlaylistCardSlider(
                      tag: collection.$1.name,
                      playlists: collection.$2,
                      isDesktop: widget.isDesktop,
                    ),
                  );
                },
              ),
            ),
          ],
        )));
  }

  /// 移动端 UI 构建
  Widget buildMobileUI() {
    return CupertinoPageScaffold(
      child: Center(
        child: Text('Mobile UI'),
      ),
    );
  }
}

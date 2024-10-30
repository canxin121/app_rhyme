import 'dart:async';
import 'package:app_rhyme/common_comps/playlist_collection/playlist_collection_slider.dart';
import 'package:app_rhyme/pulldown_menus/playlist_collection_page_menu.dart';
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
  late StreamSubscription<String> playlistDeleteStreamSubscription;
  late StreamSubscription<PlaylistCollection>
      playlistCollectionCreateStreamSubscription;
  late StreamSubscription<void>
      playlistCollectionsPageRefreshStreamSubscription;
  late StreamSubscription<int> playlistCollectionDeleteStreamSubscription;
  late StreamSubscription<(Playlist, int)> playlistCreateStreamSubscription;
  late StreamSubscription<Playlist> playlistUpdateStreamSubscription;
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
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return CupertinoPageScaffold(
        backgroundColor: getPrimaryBackgroundColor(isDarkMode),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoNavigationBar(
              backgroundColor: getNavigatorBarColor(isDarkMode),
              middle: Text(
                '所有歌单列表',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: getTextColor(isDarkMode),
                ).useSystemChineseFont(),
              ),
              trailing: PlaylistCollectionPageMenu(
                builder: (context, showMenu) => CupertinoButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: showMenu,
                    child: Text(
                      '选项',
                      style: TextStyle(color: activeIconRed)
                          .useSystemChineseFont(),
                    )),
                isDesktop: widget.isDesktop,
                playlists: playlistsCollections
                    .map((e) => e.$2)
                    .expand((e) => e)
                    .toList(),
                playlistCollections:
                    playlistsCollections.map((e) => e.$1).toList(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: playlistsCollections.length,
                itemBuilder: (context, index) {
                  var collection = playlistsCollections[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: PlaylistCollectionCardSlider(
                      playlistCollection: collection.$1,
                      playlists: collection.$2,
                      isDesktop: widget.isDesktop,
                    ),
                  );
                },
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    playlistCollectionCreateStreamSubscription =
        playlistCollectionCreateStreamController.stream
            .listen((playlistCollection) {
      setState(() {
        playlistsCollections.add((playlistCollection, []));
      });
    });

    playlistCollectionDeleteStreamSubscription =
        playlistCollectionDeleteStreamController.stream.listen((id) {
      var index = playlistsCollections.indexWhere((e) => e.$1.id == id);
      if (index == -1) {
        return;
      }
      setState(() {
        playlistsCollections.removeAt(index);
      });
    });

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

    playlistCollectionsPageRefreshStreamSubscription =
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

    playlistCreateStreamSubscription =
        playlistCreateStreamController.stream.listen((playlist) {
      var index =
          playlistsCollections.indexWhere((e) => e.$1.id == playlist.$2);
      if (index == -1) {
        return;
      }
      setState(() {
        playlistsCollections[index] = (
          playlistsCollections[index].$1,
          playlistsCollections[index].$2..add(playlist.$1)
        );
      });
    });
    playlistUpdateStreamSubscription =
        playlistUpdateStreamController.stream.listen((playlist) {
      for (var i = 0; i < playlistsCollections.length; i++) {
        var index = playlistsCollections[i]
            .$2
            .indexWhere((e) => e.identity == playlist.identity);
        if (index != -1) {
          setState(() {
            playlistsCollections[i].$2[index] = playlist;
          });
          break;
        }
      }
    });

    fetchPlaylists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    playlistCollectionUpdateStreamSubscription.cancel();
    playlistCollectionDeleteStreamSubscription.cancel();
    playlistCollectionCreateStreamSubscription.cancel();
    playlistDeleteStreamSubscription.cancel();
    playlistCreateStreamSubscription.cancel();
    playlistUpdateStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }
}

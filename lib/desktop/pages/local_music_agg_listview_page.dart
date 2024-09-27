import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list.dart';
import 'package:app_rhyme/desktop/comps/playlist_comp/playlist_header.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:flutter/cupertino.dart';

Future<void> Function() globalDesktopMusicAggregatorListPageRefreshFunction =
    () async {};

class LocalMusicContainerListPage extends StatefulWidget {
  final Playlist playlist;

  const LocalMusicContainerListPage({
    super.key,
    required this.playlist,
  });

  @override
  LocalMusicContainerListPageState createState() =>
      LocalMusicContainerListPageState();
}

class LocalMusicContainerListPageState
    extends State<LocalMusicContainerListPage> with WidgetsBindingObserver {
  late Playlist playlist;
  List<MusicAggregator> musicAggs = [];

  @override
  void initState() {
    playlist = widget.playlist;
    WidgetsBinding.instance.addObserver(this);
    globalDesktopMusicAggregatorListPageRefreshFunction = () async {
      var newPlaylist =
          await Playlist.findInDb(id: int.parse(playlist.identity));
      setState(() {
        if (newPlaylist != null) {
          playlist = newPlaylist;
        }
      });
      await loadMusicContainers();
    };
    loadMusicContainers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    globalDesktopMusicAggregatorListPageRefreshFunction = () async {};
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  Future<void> loadMusicContainers() async {
    try {
      var newMuiscAggs = await playlist.getMusicsFromDb();

      setState(() {
        musicAggs = newMuiscAggs;
      });
    } catch (e) {
      LogToast.error("加载歌曲列表", "加载歌曲列表失败!:$e",
          "[loadMusicContainers] Failed to load music list: $e");
      setState(() {
        musicAggs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    double screenWidth = MediaQuery.of(context).size.width;
    final ScrollController controller = ScrollController();
    return CupertinoPageScaffold(
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      child: CupertinoScrollbar(
          controller: controller,
          thickness: 10,
          radius: const Radius.circular(10),
          child: CustomScrollView(
            controller: controller,
            slivers: <Widget>[
              MusicListHeader(
                playlist: playlist,
                musicAggs: musicAggs,
                isDarkMode: isDarkMode,
                screenWidth: screenWidth,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
              MusicAggregatorList(
                musicAggs: musicAggs,
                playlist: playlist,
              ),
            ],
          )),
    );
  }
}

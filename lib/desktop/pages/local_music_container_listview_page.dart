import 'package:app_rhyme/desktop/comps/music_container_comp/music_container_list.dart';
import 'package:app_rhyme/desktop/comps/musiclist_comp/musiclist_header.dart';
import 'package:app_rhyme/desktop/home.dart';
import 'package:app_rhyme/desktop/utils/colors.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/src/rust/api/bind/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:flutter/cupertino.dart';

Future<void> Function() globalDesktopMusicContainerListPageRefreshFunction =
    () async {};
void Function() globalMusicContainerListPagePopFunction = () {};

class LocalMusicContainerListPage extends StatefulWidget {
  final MusicListW musicList;

  const LocalMusicContainerListPage({
    super.key,
    required this.musicList,
  });

  @override
  LocalMusicContainerListPageState createState() =>
      LocalMusicContainerListPageState();
}

class LocalMusicContainerListPageState
    extends State<LocalMusicContainerListPage> with WidgetsBindingObserver {
  List<MusicContainer> musicContainers = [];
  late MusicListW musicList;
  late MusicListInfo musicListInfo;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    musicList = widget.musicList;
    musicListInfo = musicList.getMusiclistInfo();
    // 设置全局的更新函数
    globalDesktopMusicContainerListPageRefreshFunction = () async {
      var musicLists = await SqlFactoryW.getAllMusiclists();
      setState(() {
        musicList = musicLists
            .singleWhere((ml) => ml.getMusiclistInfo().id == musicListInfo.id);
        musicListInfo = musicList.getMusiclistInfo();
      });
      await loadMusicContainers();
    };
    globalMusicContainerListPagePopFunction = () {
      Navigator.of(globalDesktopPageContext).pop(context);
    };
    // 加载歌单内音乐
    loadMusicContainers();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 清空全局的更新函数
    globalDesktopMusicContainerListPageRefreshFunction = () async {};
    globalMusicContainerListPagePopFunction = () {};
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      // 重建界面以响应亮暗模式变化
    });
  }

  Future<void> loadMusicContainers() async {
    try {
      var aggs = await SqlFactoryW.getAllMusics(musiclistInfo: musicListInfo);
      setState(() {
        musicContainers = aggs.map((a) => MusicContainer(a)).toList();
      });
    } catch (e) {
      LogToast.error("加载歌曲列表", "加载歌曲列表失败!:$e",
          "[loadMusicContainers] Failed to load music list: $e");

      setState(() {
        musicContainers = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: getPrimaryBackgroundColor(isDarkMode),
      child: CustomScrollView(
        slivers: <Widget>[
          MusicListHeader(
            musicList: musicList,
            musicContainers: musicContainers,
            isDarkMode: isDarkMode,
            screenWidth: screenWidth,
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          MusicContainerList(
            musicContainers: musicContainers,
            musicListW: musicList,
          ),
        ],
      ),
    );
  }
}

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/dialogs/input_musiclist_sharelink_dialog.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
import 'package:app_rhyme/pages/local_music_list_page.dart';
import 'package:app_rhyme/pages/online_music_list_page.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:toastification/toastification.dart';

void Function() globalMusicListGridPageRefreshFunction = () {};

class LocalMusicListGridPage extends StatefulWidget {
  const LocalMusicListGridPage({super.key});

  @override
  LocalMusicListGridPageState createState() => LocalMusicListGridPageState();
}

class LocalMusicListGridPageState extends State<LocalMusicListGridPage>
    with WidgetsBindingObserver {
  List<MusicListW> musicLists = [];

  @override
  void initState() {
    super.initState();
    globalMusicListGridPageRefreshFunction = () {
      loadMusicLists();
    };
    loadMusicLists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    globalMusicListGridPageRefreshFunction = () {};
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  // Function to load music lists
  void loadMusicLists() async {
    try {
      List<MusicListW> loadedLists = await SqlFactoryW.getAllMusiclists();
      setState(() {
        musicLists = loadedLists;
      });
    } catch (e) {
      toastification.show(
          type: ToastificationType.error,
          title:
              Text("加载歌单列表", style: const TextStyle().useSystemChineseFont()),
          description: Text("加载歌单列表失败!",
              style: const TextStyle().useSystemChineseFont()),
          autoCloseDuration: const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            CupertinoNavigationBar(
              // backgroundColor: backgroundColor,
              leading: Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '资料库',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: textColor),
                  ),
                ),
              ),
              trailing: MusicListGridPageMenu(
                builder: (context, showMenu) => GestureDetector(
                  child: Text(
                    '选项',
                    style: TextStyle(color: activeIconRed),
                  ),
                  onTapDown: (details) {
                    showMenu();
                  },
                ),
              ),
            ),
            // Display music lists grid view
            Expanded(
              child: musicLists.isEmpty
                  ? Center(
                      child: Text("没有歌单", style: TextStyle(color: textColor)))
                  : GridView.builder(
                      padding: const EdgeInsets.only(
                          top: 30, bottom: 150, right: 10, left: 10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: musicLists.length,
                      itemBuilder: (BuildContext context, int index) {
                        var musicList = musicLists[index];
                        return MusicListImageCard(
                          key: ValueKey(musicList.getMusiclistInfo().id),
                          musicListW: musicList,
                          online: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    LocalMusicContainerListPage(
                                  musicList: musicList,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class MusicListGridPageMenu extends StatelessWidget {
  const MusicListGridPageMenu({
    super.key,
    required this.builder,
  });
  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () async {
            if (context.mounted) {
              var musicListInfo = await showMusicListInfoDialog(context);
              if (musicListInfo != null) {
                try {
                  await SqlFactoryW.createMusiclist(
                      musicListInfos: [musicListInfo]);
                  globalMusicListGridPageRefreshFunction();
                  toastification.show(
                    autoCloseDuration: const Duration(seconds: 2),
                    type: ToastificationType.success,
                    title: Text(
                      '创建歌单',
                      style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ).useSystemChineseFont(),
                    ),
                    description: Text(
                      '创建歌单成功',
                      style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ).useSystemChineseFont(),
                    ),
                  );
                } catch (e) {
                  toastification.show(
                    autoCloseDuration: const Duration(seconds: 2),
                    type: ToastificationType.error,
                    title: Text(
                      '创建歌单',
                      style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ).useSystemChineseFont(),
                    ),
                    description: Text(
                      '创建歌单失败: $e',
                      style: TextStyle(
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ).useSystemChineseFont(),
                    ),
                  );
                }
              }
            }
          },
          title: '创建歌单',
          icon: CupertinoIcons.add,
        ),
        PullDownMenuItem(
          onTap: () async {
            var url = await showInputPlaylistShareLinkDialog(context);
            if (url != null) {
              var result =
                  await OnlineFactoryW.getMusiclistFromShare(shareUrl: url);
              var musicListW = result.$1;
              var musicAggregators = result.$2;
              if (context.mounted) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                      builder: (context) => OnlineMusicListPage(
                            musicList: musicListW,
                            firstPageMusicAggregators: musicAggregators,
                          )),
                );
              }
            }
          },
          title: '打开歌单链接',
          icon: CupertinoIcons.pencil,
        ),
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

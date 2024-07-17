import 'package:app_rhyme/comps/chores/button.dart';
import 'package:app_rhyme/pages/muti_select_pages/muti_select_local_music_container_listview_page.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';

class OnlineMusicListPage extends StatefulWidget {
  final MusicListW musicList;
  final List<MusicAggregatorW>? firstPageMusicAggregators;

  const OnlineMusicListPage(
      {super.key, required this.musicList, this.firstPageMusicAggregators});

  @override
  OnlineMusicListPageState createState() => OnlineMusicListPageState();
}

class OnlineMusicListPageState extends State<OnlineMusicListPage> {
  final PagingController<int, MusicAggregatorW> _pagingController =
      PagingController(firstPageKey: 1);
  late MusicListInfo musicListInfo;

  @override
  void initState() {
    super.initState();
    musicListInfo = widget.musicList.getMusiclistInfo();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchMusicAggregators(pageKey);
    });
    if (widget.firstPageMusicAggregators != null) {
      _pagingController.appendPage(
        widget.firstPageMusicAggregators!,
        2,
      );
    }
  }

  Future<void> _fetchAllMusics() async {
    while (_pagingController.nextPageKey != null) {
      await _fetchMusicAggregators(_pagingController.nextPageKey!);
    }
  }

  Future<void> _fetchMusicAggregators(int pageKey) async {
    try {
      var aggs =
          await widget.musicList.getMusicAggregators(page: pageKey, limit: 30);
      if (aggs.isEmpty) {
        _pagingController.appendLastPage([]);
      } else {
        _pagingController.appendPage(
          aggs,
          pageKey + 1,
        );
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final textColor = brightness == Brightness.dark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final Color dividerColor = isDarkMode
        ? const Color.fromARGB(255, 41, 41, 43)
        : const Color.fromARGB(255, 245, 245, 246);
    double screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.only(end: 16),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          trailing: OnlineMusicListChoicMenu(
            builder: (context, showMenu) => GestureDetector(
              child: Text(
                '选项',
                style: TextStyle(color: activeIconRed).useSystemChineseFont(),
              ),
              onTapDown: (details) {
                showMenu();
              },
            ),
            musicListW: widget.musicList,
            musicAggregators: _pagingController.itemList != null
                ? _pagingController.itemList!
                : [],
            fetchAllMusicAggregators: _fetchAllMusics,
          )),
      child: CustomScrollView(
        slivers: <Widget>[
          // 歌单封面
          SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.1,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1),
                child: SafeArea(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.7,
                    ),
                    child: MusicListImageCard(
                        musicListW: widget.musicList, online: true),
                  ),
                )),
          ),
          // Two buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildButton(
                    context,
                    icon: CupertinoIcons.play_fill,
                    label: '播放全部',
                    onPressed: () async {
                      await _fetchAllMusics();
                      if (_pagingController.itemList != null &&
                          _pagingController.itemList!.isNotEmpty) {
                        globalAudioHandler.clearReplaceMusicAll(
                            _pagingController.itemList!
                                .map((a) => MusicContainer(a))
                                .toList());
                      }
                    },
                  ),
                  buildButton(
                    context,
                    icon: Icons.shuffle,
                    label: '随机播放',
                    onPressed: () async {
                      await _fetchAllMusics();
                      if (_pagingController.itemList != null &&
                          _pagingController.itemList!.isNotEmpty) {
                        await globalAudioHandler.clearReplaceMusicAll(
                            shuffleList(_pagingController.itemList!)
                                .map((a) => MusicContainer(a))
                                .toList());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Divider(
                  color: dividerColor,
                  height: 0.5,
                ),
              ),
            ),
          ),
          PagedSliverList.separated(
            pagingController: _pagingController,
            separatorBuilder: (context, index) => Center(
              child: SizedBox(
                width: screenWidth * 0.85,
                child: Divider(
                  color: dividerColor,
                  height: 0.5,
                ),
              ),
            ),
            builderDelegate: PagedChildBuilderDelegate<MusicAggregatorW>(
                noItemsFoundIndicatorBuilder: (context) {
                  return Center(
                    child: Text(
                      '没有找到任何音乐',
                      style: TextStyle(color: textColor).useSystemChineseFont(),
                    ),
                  );
                },
                itemBuilder: (context, musicAggregator, index) => Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: MusicContainerListItem(
                        musicContainer: MusicContainer(musicAggregator),
                      ),
                    )),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 200),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class OnlineMusicListChoicMenu extends StatelessWidget {
  const OnlineMusicListChoicMenu({
    super.key,
    required this.builder,
    required this.musicListW,
    required this.musicAggregators,
    required this.fetchAllMusicAggregators,
  });

  final PullDownMenuButtonBuilder builder;
  final MusicListW musicListW;
  final List<MusicAggregatorW> musicAggregators;
  final Future<void> Function() fetchAllMusicAggregators;

  @override
  Widget build(BuildContext context) {
    MusicListInfo musicListInfo = musicListW.getMusiclistInfo();

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          leading: imageCacheHelper(musicListInfo.artPic),
          title: musicListInfo.name,
          subtitle: musicListInfo.desc,
        ),
        const PullDownMenuDivider.large(),
        ...onlineMusicListItems(context, musicListW),
        PullDownMenuItem(onTap: fetchAllMusicAggregators, title: "加载所有音乐"),
        PullDownMenuItem(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => MutiSelectLocalMusicContainerListPage(
                      musicList: musicListW,
                      musicContainers: musicAggregators
                          .map((a) => MusicContainer(a))
                          .toList()),
                ),
              );
            },
            title: "多选操作")
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

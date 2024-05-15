import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/page/in_search_music_list.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/advanced_music_sdk.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/pull_down_selection.dart';
import 'package:app_rhyme/util/toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:toastification/toastification.dart';

enum SearchTarget { music, musicList }

class SearchController extends GetxController {
  Rx<SearchTarget> searchTarget = SearchTarget.music.obs;
  var allowEmptyTime = 3.obs;
  var pagingController = PagingController<int, dynamic>(firstPageKey: 1).obs;
  var searchController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    pagingController.value.addPageRequestListener((pageKey) {
      fetchMusics(pageKey);
      update();
    });
  }

  void changeSearchTarget(SearchTarget target) {
    searchTarget.value = target;
    searchController.value.text = "";
    allowEmptyTime.value = 3;
    pagingController.value.refresh();
    switch (target) {
      case SearchTarget.music:
        pagingController.value =
            PagingController<int, dynamic>(firstPageKey: 1);
        pagingController.value.addPageRequestListener((pageKey) {
          fetchMusics(pageKey);
          update();
        });
        break;
      case SearchTarget.musicList:
        pagingController.value =
            PagingController<int, dynamic>(firstPageKey: 1);
        pagingController.value.addPageRequestListener((pageKey) {
          fetchMusicList(pageKey);
          update();
        });
        break;
    }
    update();
  }

  Future<void> fetchMusicList(int pageKey) async {
    try {
      if (searchController.value.text.isEmpty) {
        pagingController.value.appendLastPage([]);
      }
      var newItems = await searchMusicList(
        content: searchController.value.text,
        page: pageKey,
        source: 'KuWo',
      );

      List<(String, MusicList)> uniqueItems = [];

      if (pagingController.value.itemList != null) {
        for (var newItem in newItems) {
          bool exist = false;
          for ((String, MusicList) existItem
              in pagingController.value.itemList!) {
            if (existItem.$1 == newItem.$1) {
              exist = true;
            }
          }
          if (!exist) {
            uniqueItems.add(newItem);
          }
        }
      } else {
        uniqueItems.addAll(newItems);
      }

      if (uniqueItems.isEmpty) {
        allowEmptyTime -= 1;
      }

      if (allowEmptyTime < 0) {
        pagingController.value.appendLastPage(uniqueItems);
      } else {
        pagingController.value.appendPage(uniqueItems, pageKey + 1);
      }
    } catch (error) {
      pagingController.value.error = error;
    }
  }

  Future<void> fetchMusics(int pageKey) async {
    try {
      if (searchController.value.text.isEmpty) {
        pagingController.value.appendLastPage([]);
      }
      var results = await searchMusic(
        content: searchController.value.text,
        page: pageKey,
        source: 'KuWo',
      );

      List<Music> newItems = [];
      for (MusicW result in results) {
        newItems.add(Music(result));
      }
      List<Music> uniqueItems = [];

      if (pagingController.value.itemList != null) {
        for (Music newItem in newItems) {
          bool exist = false;
          for (Music existItem in pagingController.value.itemList!) {
            if (existItem.info.name == newItem.info.name &&
                existItem.info.artist.join("") ==
                    newItem.info.artist.join("")) {
              exist = true;
            }
          }
          if (!exist) {
            uniqueItems.add(newItem);
          }
        }
      } else {
        uniqueItems.addAll(newItems);
      }

      if (uniqueItems.isEmpty) {
        allowEmptyTime -= 1;
      }

      if (allowEmptyTime < 0) {
        pagingController.value.appendLastPage(uniqueItems);
      } else {
        pagingController.value.appendPage(uniqueItems, pageKey + 1);
      }
    } catch (error) {
      pagingController.value.error = error;
    }
  }
}

final SearchController globalSearchController = Get.put(SearchController());

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    globalSearchController.searchController.value = TextEditingController();

    return CupertinoPageScaffold(
        child: Column(
      children: [
        CupertinoNavigationBar(
            trailing: GestureDetector(
              child: Obx(() {
                if (globalSearchController.searchTarget.value ==
                    SearchTarget.music) {
                  return Text(
                    '歌曲',
                    style: TextStyle(color: activeIconColor)
                        .useSystemChineseFont(),
                  );
                } else {
                  return Text(
                    '歌单',
                    style: TextStyle(color: activeIconColor)
                        .useSystemChineseFont(),
                  );
                }
              }),
              onTapDown: (details) {
                showPullDownMenu(
                    context: context,
                    items: searchPageActionPullDown(
                        context,
                        globalSearchController.searchTarget.value,
                        globalSearchController.changeSearchTarget),
                    position: details.globalPosition & Size.zero);
              },
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '搜索',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ).useSystemChineseFont(),
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            controller: globalSearchController.searchController.value,
            onSubmitted: (String value) {
              if (value.isNotEmpty) {
                globalSearchController.allowEmptyTime.value = 3;
                globalSearchController.pagingController.value.refresh();
              }
            },
          ),
        ),
        Expanded(
          child: Obx(() {
            if (globalSearchController.searchTarget.value ==
                SearchTarget.music) {
              return PagedListView.separated(
                pagingController: globalSearchController.pagingController.value,
                padding: EdgeInsets.only(bottom: screenHeight * 0.1),
                separatorBuilder: (context, index) => const Divider(
                  color: CupertinoColors.systemGrey4,
                  indent: 30,
                  endIndent: 30,
                ),
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, displayMusic, index) => MusicCard(
                    music: displayMusic,
                    onClick: () {
                      globalAudioHandler.addMusicPlay(
                        displayMusic as Music,
                      );
                    },
                    onPress: (details) async {
                      var position = details.globalPosition & Size.zero;
                      await showPullDownMenu(
                          context: context,
                          items: searchMusicCardPullDown(
                              context, displayMusic as Music, position),
                          position: position);
                    },
                  ),
                ),
              );
            } else {
              return PagedGridView(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.2),
                  pagingController:
                      globalSearchController.pagingController.value,
                  builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, payloadAndMusicList_, index) {
                    var payloadAndMusicList =
                        payloadAndMusicList_ as (String, MusicList);
                    return Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: MusicListCard(
                          expanded: true,
                          musicList: payloadAndMusicList.$2,
                          onClick: () {
                            // 这里需要点击后进入这个新的歌单界面
                            globalTopUiController
                                .updateWidget(InSearchMusicListPage(
                              musicList: payloadAndMusicList.$2,
                              payload: payloadAndMusicList.$1,
                            ));
                          },
                          onPress: (details) async {
                            var position = details.globalPosition & Size.zero;
                            await showPullDownMenu(
                                context: context,
                                items: searchMusicListCardPullDown(
                                    context,
                                    payloadAndMusicList.$1,
                                    payloadAndMusicList.$2,
                                    position),
                                position: position);
                          },
                        ));
                  }),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2));
            }
          }),
        ),
      ],
    ));
  }
}

// 搜索界面右上角的搜索目标
List<PullDownMenuEntry> searchPageActionPullDown(
  BuildContext context,
  SearchTarget currentTarget,
  void Function(SearchTarget) changeSearchTarget,
) =>
    [
      if (currentTarget == SearchTarget.music)
        PullDownMenuItem(
          title: '搜索歌单',
          onTap: () async {
            changeSearchTarget(SearchTarget.musicList);
          },
          icon: CupertinoIcons.create,
        ),
      if (currentTarget == SearchTarget.musicList)
        PullDownMenuItem(
          title: '搜索歌曲',
          onTap: () async {
            changeSearchTarget(SearchTarget.music);
          },
          icon: CupertinoIcons.create,
        ),
    ];

// 搜索歌单时，搜索界面的音乐卡片的长按触发操作
List<PullDownMenuEntry> searchMusicListCardPullDown(
  BuildContext context,
  String payload,
  MusicList musiclist,
  Rect position,
) =>
    [
      PullDownMenuHeader(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: FutureBuilder<Image>(
              future: useCacheImage(musiclist.artPic),
              builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.hasError) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: defaultArtPic.image,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: snapshot.data?.image ?? defaultArtPic.image,
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: CupertinoColors.systemGrey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                }
              },
            ),
          ),
          title: musiclist.name,
          subtitle: musiclist.desc,
          iconWidget: CupertinoButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.profile_circled),
          )),
      const PullDownMenuDivider.large(),
      PullDownMenuItem(
        title: "添加作为新歌单",
        onTap: () async {
          int index =
              globalFloatWidgetContoller.addMsg("添加${musiclist.name}作为新歌单");
          try {
            await globalSqlMusicFactory
                .createMusicListTable(musicLists: [musiclist]);
            var musics = await getAllMusicFromMusicList(payload, "KuWo");
            for (var music in musics) {
              if (music.info.artPic != null) {
                cacheFile(file: music.info.artPic!, cachePath: picCachePath);
              }
            }
            cacheFile(file: musiclist.artPic, cachePath: picCachePath);
            await globalSqlMusicFactory.insertMusic(
                musicList: musiclist,
                musics: musics.map((e) => e.ref).toList());
            talker.info("[MusicList Search] succeed to add  musiclist");
          } catch (e) {
            if (context.mounted) {
              toast(
                  context, "Music Album", "添加失败: $e", ToastificationType.error);
            }
          } finally {
            globalFloatWidgetContoller.delMsg(index);
          }
        },
        icon: CupertinoIcons.add_circled,
      ),
      PullDownMenuItem(
        title: "添加到已有歌单",
        onTap: () async {
          int index =
              globalFloatWidgetContoller.addMsg("添加${musiclist.name}到新歌单");
          try {
            var musicLists = await globalSqlMusicFactory.readMusicLists();
            var musics = getAllMusicFromMusicList(payload, "KuWo");
            if (context.mounted) {
              await showPullDownMenu(
                  context: context,
                  items: addToMusicListPullDown(
                      context, musicLists, musics, position),
                  position: position);
            }
          } catch (e) {
            if (context.mounted) {
              toast(
                  context, "Music Album", "添加失败: $e", ToastificationType.error);
            }
          } finally {
            globalFloatWidgetContoller.delMsg(index);
          }
        },
        icon: CupertinoIcons.add_circled,
      ),
    ];

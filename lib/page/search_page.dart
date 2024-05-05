import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/comp/form/music_list_table_form.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/selection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/cupertino.dart';

class SearchController extends GetxController {
  var allowEmptyTime = 3.obs;
  var pagingController =
      PagingController<int, DisplayMusic>(firstPageKey: 1).obs;
  var searchController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    pagingController.value.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
      update();
    });
  }

  // void onLeaveDrop() {
  //   // 在离开时只在全局保留10个搜索结果，减少不使用时的内存消耗
  //   if (pagingController.value.itemList != null &&
  //       pagingController.value.itemList!.length > 10) {
  //     pagingController.value.itemList =
  //         pagingController.value.itemList!.sublist(0, 10);
  //     update();
  //   }
  // }

  Future<void> fetchPage(int pageKey) async {
    try {
      if (searchController.value.text.isEmpty) {
        pagingController.value.appendLastPage([]);
      }
      var results = await searchMusic(
        content: searchController.value.text,
        page: pageKey,
        source: 'KuWo',
      );

      List<DisplayMusic> newItems = [];
      for (MusicW result in results) {
        newItems.add(DisplayMusic(result));
      }
      List<DisplayMusic> uniqueItems = [];

      if (pagingController.value.itemList != null) {
        for (DisplayMusic newItem in newItems) {
          bool exist = false;
          for (DisplayMusic existItem in pagingController.value.itemList!) {
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

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController controller = Get.put(SearchController());
    return CupertinoPageScaffold(
        child: Column(
      children: [
        const CupertinoNavigationBar(
            // 界面最上面的 编辑选项
            leading: Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '搜索',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        )),
        // const Padding(padding: EdgeInsets.only(top: 40)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            controller: controller.searchController.value,
            onSubmitted: (String value) {
              if (value.isNotEmpty) {
                controller.allowEmptyTime.value = 3;
                controller.pagingController.value.refresh();
              }
            },
          ),
        ),
        Expanded(
          child: Obx(() => PagedListView<int, DisplayMusic>.separated(
                pagingController: controller.pagingController.value,
                padding: const EdgeInsets.only(bottom: 50),
                separatorBuilder: (context, index) => const Divider(
                  color: CupertinoColors.systemGrey4,
                  indent: 30,
                  endIndent: 30,
                ),
                builderDelegate: PagedChildBuilderDelegate<DisplayMusic>(
                  itemBuilder: (context, item, index) => MusicCard(
                    music: item,
                    onClick: () {
                      globalAudioHandler.addMusicPlay(
                        item,
                      );
                    },
                    // 以下是每个搜索结果音乐的，可进行的操作
                    onPress: () {
                      showCupertinoPopupWithActions(context: context, options: [
                        "添加到歌单",
                        "创建新歌单"
                      ], actionCallbacks: [
                        // 添加到已有歌单中
                        () async {
                          var tables =
                              await globalSqlMusicFactory.readMusicLists();
                          List<String> options =
                              tables.map((e) => e.name).toList();
                          if (context.mounted) {
                            showCupertinoPopupWithSameAction(
                                context: context,
                                options: options,
                                actionCallbacks: (index) async {
                                  // 将音乐插入歌单中
                                  await globalSqlMusicFactory.insertMusic(
                                      musicList: tables[index],
                                      musics: [item.ref]);
                                  // 缓存音乐的图片, 没必要阻塞
                                  if (item.info.artPic != null) {
                                    cacheFile(
                                      file: item.info.artPic!,
                                      cachePath: picCachePath,
                                    );
                                  }
                                });
                          }
                        },
                        // 创建一个新歌单并添加进去
                        () async {
                          var table = MusicList(
                              name: item.info.artist.join(","),
                              artPic: item.info.artPic ?? "",
                              desc: "");
                          createMusicListTableForm(context, table)
                              .then((newTable) {
                            if (newTable != null) {
                              // 创建新歌单
                              globalSqlMusicFactory.createMusicListTable(
                                  musicLists: [newTable]).then((_) {
                                globalSqlMusicFactory.insertMusic(
                                    musicList: newTable, musics: [item.ref]);
                              });
                              // 缓存音乐的图片, 没必要阻塞
                              if (item.info.artPic != null) {
                                cacheFile(
                                  file: item.info.artPic!,
                                  cachePath: picCachePath,
                                );
                              }
                            }
                          });
                        }
                      ]);
                    },
                  ),
                ),
              )),
        ),
      ],
    ));
  }
}

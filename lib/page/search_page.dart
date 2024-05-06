import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/util/pull_down_selection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

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
                  itemBuilder: (context, displayMusic, index) => MusicCard(
                    music: displayMusic,
                    onClick: () {
                      globalAudioHandler.addMusicPlay(
                        displayMusic,
                      );
                    },
                    onPress: (details) async {
                      var position = details.globalPosition & Size.zero;
                      await showPullDownMenu(
                          context: context,
                          items: searchMusicCardPullDown(
                              context, displayMusic, position),
                          position: position);
                    },
                  ),
                ),
              )),
        ),
      ],
    ));
  }
}

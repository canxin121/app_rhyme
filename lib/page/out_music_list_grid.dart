import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/comp/form/music_list_table_form.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/in_music_list.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MusicListsPage extends StatefulWidget {
  const MusicListsPage({super.key});

  @override
  MusicListsPageState createState() => MusicListsPageState();
}

class MusicListsPageState extends State<MusicListsPage> {
  Future<List<MusicList>>? musicLists;

  @override
  void initState() {
    super.initState();
    musicLists = globalSqlMusicFactory.readMusicLists();
  }

  void refreshMusicLists() {
    setState(() {
      musicLists = globalSqlMusicFactory.readMusicLists();
    });
  }

  Future<void> onMulSelece() async {}
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CupertinoNavigationBar(
                // 界面最上面的 编辑选项
                leading: Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '资料库',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ).useSystemChineseFont(),
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  child: Text(
                    '编辑',
                    style: TextStyle(color: activeIconColor)
                        .useSystemChineseFont(),
                  ),
                  onTapDown: (details) {
                    showPullDownMenu(
                        context: context,
                        items: musicListGridActionPullDown(
                            context, refreshMusicLists),
                        position: details.globalPosition & Size.zero);
                  },
                )),
            // 这里创建的是一个 所有歌单的grid view
            Expanded(
                child: FutureBuilder<List<MusicList>>(
              future: musicLists, // 使用更新后的future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('发生错误: ${snapshot.error}'));
                } else {
                  // 这里控制每一行显示多少个
                  return GridView.builder(
                    padding: const EdgeInsets.only(
                        top: 30, bottom: 150, right: 10, left: 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      var musicList = snapshot.data![index];
                      // grid的每一个元素是一个SquareMusicCard,也就是一个歌单
                      return MusicListCard(
                        musicList: musicList,
                        onClick: () {
                          globalTopUiController.updateWidget(InMusicListPage(
                            musicList: musicList,
                          ));
                        },
                        onPress: (details) {
                          var position = details.globalPosition & Size.zero;
                          showPullDownMenu(
                              context: context,
                              items: musicListPullDown(context, musicList,
                                  refreshMusicLists, position),
                              position: position);
                        },
                      );
                    },
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}

// 歌单表格界面的歌单卡片的长按触发操作
List<PullDownMenuEntry> musicListPullDown(
  BuildContext context,
  MusicList musicList,
  VoidCallback refresh,
  Rect position,
) =>
    [
      PullDownMenuHeader(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: FutureBuilder<Image>(
              future: useCacheImage(musicList.artPic),
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
          title: musicList.name,
          subtitle: musicList.desc,
          iconWidget: CupertinoButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.profile_circled),
          )),
      const PullDownMenuDivider.large(),
      PullDownMenuItem(
        title: "删除",
        onTap: () async {
          await globalSqlMusicFactory
              .delMusicListTable(musicLists: [musicList]);
          refresh();
        },
        icon: CupertinoIcons.delete_solid,
      ),
      PullDownMenuItem(
        title: '编辑',
        onTap: () async {
          createMusicListTableForm(context, musicList).then((value) {
            if (value != null) {
              globalSqlMusicFactory.changeMusicListMetadata(
                  oldList: [musicList], newList: [value]).then((_) {
                refresh();
              });
            }
          });
        },
        icon: CupertinoIcons.pencil,
      ),
    ];

// 资料库歌单列表右上角的编辑触发的的长按触发操作
List<PullDownMenuEntry> musicListGridActionPullDown(
  BuildContext context,
  void Function() refresh,
) =>
    [
      PullDownMenuItem(
        title: '创建新歌单',
        onTap: () async {
          var result = await createMusicListTableForm(context);
          if (result != null) {
            await globalSqlMusicFactory
                .createMusicListTable(musicLists: [result]);
            if (result.artPic.isNotEmpty) {
              await cacheFile(file: result.artPic, cachePath: picCachePath);
            }
            refresh();
          }
        },
        icon: CupertinoIcons.create,
      ),
    ];

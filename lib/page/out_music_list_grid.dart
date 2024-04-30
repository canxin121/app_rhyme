import 'package:app_rhyme/comp/form/music_list_table_form.dart';
import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/in_music_list.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_popup/flutter_popup.dart';

class MusicTablesPage extends StatefulWidget {
  const MusicTablesPage({super.key});

  @override
  MusicTablesPageState createState() => MusicTablesPageState();
}

class MusicTablesPageState extends State<MusicTablesPage> {
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

  Future<void> onAdd() async {
    var result = await createMusicListTableForm(context);
    if (result != null) {
      await globalSqlMusicFactory.createMusicListTable(musicLists: [result]);
      refreshMusicLists();
    }
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
                leading: const Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '资料库',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                trailing: editTextButton(context, onAdd, onMulSelece)),
            // 这里创建的是一个 所有歌单的grid view
            Expanded(
                child: FutureBuilder<List<MusicList>>(
              future: musicLists, // 使用更新后的future
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('发生错误: ${snapshot.error}'));
                } else if (snapshot.hasData) {
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
                          globalTopUiController.updateWidget(MusicPage(
                            musicList: musicList,
                          ));
                        },
                        onPress: () {
                          showCupertinoPopupWithActions(
                              context: context,
                              options: [
                                "删除",
                                "编辑"
                              ],
                              actionCallbacks: [
                                () async {
                                  await globalSqlMusicFactory.delMusicListTable(
                                      musicLists: [musicList]);
                                  refreshMusicLists();
                                },
                                () async {
                                  createMusicListTableForm(context, musicList)
                                      .then((value) {
                                    if (value != null) {
                                      globalSqlMusicFactory
                                          .changeMusicListMetadata(
                                              oldList: [musicList],
                                              newList: [value]).then((_) {
                                        refreshMusicLists();
                                      });
                                    }
                                  });
                                }
                              ]);
                        },
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('没有数据'));
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}

Widget editTextButton(BuildContext context, Future<void> Function() asyncOnadd,
    Future<void> Function() asyncOnMulSelect) {
  return CustomPopup(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          child: const Text('添加'),
          onPressed: () {
            asyncOnadd().then((value) {
              Navigator.pop(context);
            });
          },
        ),
      ],
    ),
    child: Text(
      '编辑',
      style: TextStyle(
        color: activeIconColor,
      ),
    ),
  );
}

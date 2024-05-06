import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/in_music_list.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/pull_down_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

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
                trailing: GestureDetector(
                  child: Text(
                    '编辑',
                    style: TextStyle(color: activeIconColor),
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
                          globalTopUiController.updateWidget(MusicPage(
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

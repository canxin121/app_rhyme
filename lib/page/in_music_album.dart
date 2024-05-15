import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/comp/form/music_list_table_form.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/src/rust/api/music_sdk.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/other.dart';
import 'package:app_rhyme/util/pull_down_selection.dart';
import 'package:app_rhyme/util/toast.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:toastification/toastification.dart';

class InMusicAlbumListPage extends StatefulWidget {
  final Music music;
  const InMusicAlbumListPage({
    super.key,
    required this.music,
  });

  @override
  InMusicAlbumListPageState createState() => InMusicAlbumListPageState();
}

class InMusicAlbumListPageState extends State<InMusicAlbumListPage> {
  MusicList musicList = const MusicList(name: "Album", artPic: "", desc: "");
  var allowEmptyTime = 3;
  var pagingController = PagingController<int, Music>(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    pagingController.addPageRequestListener((pageKey) {
      fetchMusicsFromMusicList(pageKey);
    });
  }

  Future<void> fetchAllMusics() async {
    int pageKey = 1;
    while (allowEmptyTime > 0) {
      await fetchMusicsFromMusicList(pageKey);
      pageKey++;
    }
  }

  Future<void> fetchMusicsFromMusicList(int pageKey) async {
    try {
      var (musicList_, newMusicsRefs) = await searchAlbum(
        music: widget.music.ref,
        page: pageKey,
      );
      if (musicList.name == "Album") {
        setState(() {
          musicList = musicList_;
        });
      }
      var newMusics = newMusicsRefs.map((e) => Music(e));
      List<Music> uniqueItems = [];

      if (pagingController.value.itemList != null) {
        for (var newMusic in newMusics) {
          bool exist = false;
          for (Music existItem in pagingController.value.itemList!) {
            if (existItem.info.name == newMusic.info.name &&
                existItem.info.artist.join(",") ==
                    newMusic.info.artist.join(",")) {
              exist = true;
            }
          }
          if (!exist) {
            uniqueItems.add(newMusic);
          }
        }
      } else {
        uniqueItems.addAll(newMusics);
      }

      if (uniqueItems.isEmpty) {
        allowEmptyTime -= 1;
      }

      if (allowEmptyTime < 0) {
        pagingController.appendLastPage(uniqueItems);
      } else {
        pagingController.appendPage(uniqueItems, pageKey + 1);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 16),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: Icon(CupertinoIcons.back, color: activeIconColor),
          onPressed: () {
            globalTopUiController.backToOriginWidget();
          },
        ),
        trailing: GestureDetector(
          child: Text(
            '编辑',
            style: TextStyle(color: activeIconColor).useSystemChineseFont(),
          ),
          onTapDown: (details) async {
            var position = details.globalPosition & Size.zero;
            if (context.mounted && pagingController.itemList != null) {
              await showPullDownMenu(
                  context: context,
                  items: musicAlbumActionPullDown(context, fetchAllMusics,
                      musicList, pagingController, position),
                  position: position);
            }
          },
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // Cover image
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                    top: screenWidth * 0.1,
                    left: screenWidth * 0.1,
                    right: screenWidth * 0.1),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.7,
                  ),
                  child: MusicListCard(musicList: musicList),
                ),
              ),
            ),
            // Two buttons
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      context,
                      icon: CupertinoIcons.play_fill,
                      label: '播放全部',
                      onPressed: () {
                        if (pagingController.itemList == null) return;
                        globalAudioHandler.clearReplaceMusicAll(
                            context, pagingController.itemList!);
                      },
                    ),
                    _buildButton(
                      context,
                      icon: Icons.shuffle,
                      label: '随机播放',
                      onPressed: () {
                        if (pagingController.itemList == null) return;
                        globalAudioHandler.clearReplaceMusicAll(
                            context, shuffleList(pagingController.itemList!));
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            const SliverToBoxAdapter(
              child: Divider(
                color: CupertinoColors.systemGrey5,
                height: 1,
              ),
            ),
            // 音乐列表
            PagedSliverList.separated(
              pagingController: pagingController,
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
                        items: inMusicAlbumMusicCardPullDown(
                            context, displayMusic as Music, position),
                        position: position);
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildButton(BuildContext context,
    {required IconData icon,
    required String label,
    required VoidCallback onPressed}) {
  return ElevatedButton.icon(
    icon: Icon(
      icon,
      size: 24,
      color: activeIconColor,
    ),
    label: Text(
      label,
      style: TextStyle(color: activeIconColor).useSystemChineseFont(),
    ),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.1,
            vertical: MediaQuery.of(context).size.height * 0.02),
        backgroundColor: CupertinoColors.systemGrey6),
  );
}

// 专辑界面的音乐卡片的长按触发操作
List<PullDownMenuEntry> inMusicAlbumMusicCardPullDown(
  BuildContext context,
  Music music,
  Rect position,
) =>
    [
      PullDownMenuHeader(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: FutureBuilder<Image>(
              future: useCacheImage(music.info.artPic),
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
          title: music.info.name,
          subtitle: music.info.artist.join(","),
          iconWidget: CupertinoButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.profile_circled),
          )),
      const PullDownMenuDivider.large(),
      PullDownMenuItem(
        title: "添加到歌单",
        onTap: () async {
          var musicLists = await globalSqlMusicFactory.readMusicLists();
          if (context.mounted) {
            await showPullDownMenu(
                context: context,
                items: addToMusicListPullDown(
                    context, musicLists, Future.value([music]), position),
                position: position);
          }
        },
        icon: CupertinoIcons.add_circled,
      ),
      PullDownMenuItem(
        title: '创建新歌单',
        onTap: () async {
          var table = MusicList(
              name: music.info.artist.join(","),
              artPic: music.info.artPic ?? "",
              desc: "");
          createMusicListTableForm(context, table).then((newTable) {
            if (newTable != null) {
              globalSqlMusicFactory
                  .createMusicListTable(musicLists: [newTable]).then((_) {
                globalSqlMusicFactory
                    .insertMusic(musicList: newTable, musics: [music.ref]);
              });
              if (music.info.artPic != null) {
                cacheFile(
                  file: music.info.artPic!,
                  cachePath: picCachePath,
                );
              }
            }
          });
        },
        icon: CupertinoIcons.create,
      ),
    ];
// 搜索歌单时，搜索界面的音乐卡片的长按触发操作
List<PullDownMenuEntry> musicAlbumActionPullDown(
  BuildContext context,
  Future<void> Function() fetchAllMusic,
  MusicList musiclist,
  PagingController<int, Music> pagingController,
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
            await fetchAllMusic();
            if (pagingController.itemList != null) {
              for (var music in pagingController.itemList!) {
                if (music.info.artPic != null) {
                  cacheFile(file: music.info.artPic!, cachePath: picCachePath);
                }
              }
              cacheFile(file: musiclist.artPic, cachePath: picCachePath);
              await globalSqlMusicFactory
                  .createMusicListTable(musicLists: [musiclist]);
              await globalSqlMusicFactory.insertMusic(
                  musicList: musiclist,
                  musics:
                      pagingController.itemList!.map((e) => e.ref).toList());
              talker.info("[MusicList Search] succeed to add  musiclist");
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
      PullDownMenuItem(
        title: "添加到已有歌单",
        onTap: () async {
          int index =
              globalFloatWidgetContoller.addMsg("添加${musiclist.name}到已有歌单");
          try {
            var musicLists = await globalSqlMusicFactory.readMusicLists();
            if (context.mounted) {
              await showPullDownMenu(
                  context: context,
                  items: addToMusicListPullDown(context, musicLists, () async {
                    await fetchAllMusic();
                    if (pagingController.itemList != null) {
                      return pagingController.itemList!;
                    }
                  }(), // 这里传递Future<List<Music>>
                      position),
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

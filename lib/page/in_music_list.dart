import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/in_music_album.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/other.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:pull_down_button/pull_down_button.dart';

class InMusicListPage extends StatefulWidget {
  final MusicList musicList;
  final Future<List<Music>>? musicsFuture;

  const InMusicListPage({
    super.key,
    required this.musicList,
    this.musicsFuture,
  });

  @override
  InMusicListPageState createState() => InMusicListPageState();
}

class InMusicListPageState extends State<InMusicListPage> {
  late MusicList musicList;
  late Future<List<Music>> musicsFuture;

  @override
  void initState() {
    super.initState();
    musicList = widget.musicList;
    musicsFuture = widget.musicsFuture ?? getMusicsFromSQL();
  }

  Future<List<Music>> getMusicsFromSQL() async {
    var results = await globalSqlMusicFactory.readMusic(musicList: musicList);
    return results.map((m) => Music(m)).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    List<Music> musics = [];
    List<Future<bool>> hasCache = [];
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
          onTapDown: (details) {
            showPullDownMenu(
                context: context,
                items: musicListActionPullDown(
                    context,
                    musics,
                    (index, hasCache_) => setState(() {
                          hasCache[index] = Future.value(hasCache_);
                        })),
                position: details.globalPosition & Size.zero);
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
                        globalAudioHandler.clearReplaceMusicAll(
                            context, musics);
                      },
                    ),
                    _buildButton(
                      context,
                      icon: Icons.shuffle,
                      label: '随机播放',
                      onPressed: () {
                        var musics_ = musics.toList();
                        musics_.shuffle();
                        globalAudioHandler.clearReplaceMusicAll(
                            context, shuffleList(musics_));
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
            FutureBuilder<List<Music>>(
              future: musicsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                } else if (snapshot.hasData) {
                  musics = snapshot.data!;
                  hasCache = musics.map((e) => e.hasCache()).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final music = musics[index];
                        return MusicCard(
                          key: ValueKey(music.info.id),
                          music: music,
                          onClick: () {
                            globalAudioHandler.addMusicPlay(
                              music,
                            );
                          },
                          hasCache: hasCache[index],
                          onPress: (details) async {
                            await showPullDownMenu(
                              context: context,
                              items: inListMusicCardPullDown(context, music,
                                  () async {
                                // 缓存
                                var floatIndex = globalFloatWidgetContoller
                                    .addMsg("缓存音乐: ${music.info.name}");
                                try {
                                  if (await music.hasCache()) return;
                                  var playInfo = await music.getPlayInfo();
                                  if (playInfo == null) return;
                                  String fileName = music.toCacheFileName();
                                  await cacheFile(
                                      file: playInfo.file,
                                      cachePath: musicCachePath,
                                      filename: fileName);
                                  // 如果这首歌正在播放列表中，替换他，防止继续在线播放
                                  globalAudioHandler.replaceMusic(music);
                                  // 在这里需要重新判断是否 hasCache,所以直接setState解决
                                  setState(() {
                                    hasCache[index] = Future.value(true);
                                  });
                                } finally {
                                  globalFloatWidgetContoller.delMsg(floatIndex);
                                }
                              }, () async {
                                // 删除缓存
                                if (music.info.defaultQuality == null) return;
                                var cacheFileName = music.toCacheFileName();
                                deleteCacheFile(
                                        file: "",
                                        cachePath: musicCachePath,
                                        filename: cacheFileName)
                                    .then((value) {
                                  // 删除缓存后刷新是否有缓存
                                  setState(() {
                                    hasCache[index] = Future.value(false);
                                  });
                                  if (kDebugMode) {
                                    print("成功删除缓存:${music.info.name}");
                                  }
                                  globalAudioHandler.replaceMusic(music);
                                });
                              }, () async {
                                // 删除音乐
                                await globalSqlMusicFactory.delMusic(
                                    musicList: musicList,
                                    ids: Int64List.fromList([music.info.id]));
                                setState(() {
                                  musics.removeAt(index);
                                  hasCache.removeAt(index);
                                });
                              }, () async {
                                // 编辑音乐
                              }, () async {
                                // 将音乐图片应用成歌单图片
                                var pic = music.info.artPic;
                                if (pic != null) {
                                  await globalSqlMusicFactory
                                      .changeMusicListMetadata(oldList: [
                                    musicList
                                  ], newList: [
                                    MusicList(
                                        name: "",
                                        artPic: pic,
                                        desc: musicList.desc)
                                  ]).then((_) {
                                    setState(() {
                                      musicList = MusicList(
                                          name: musicList.name,
                                          artPic: pic,
                                          desc: musicList.desc);
                                    });
                                  });
                                }
                              }),
                              position: details.globalPosition & Size.zero,
                            );
                          },
                        );
                      },
                      childCount: musics.length,
                    ),
                  );
                } else {
                  // No data
                  return const SliverFillRemaining(
                    child: Center(child: Text('No data available')),
                  );
                }
              },
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

// 在自定义歌单内的音乐卡片的长按触发操作
List<PullDownMenuEntry> inListMusicCardPullDown(
        BuildContext context,
        Music music,
        Future<void> Function() onSave,
        Future<void> Function() onUnSave,
        Future<void> Function() onDelete,
        Future<void> Function() onEdit,
        Future<void> Function() onUsePic) =>
    [
      PullDownMenuHeader(
          leading: AspectRatio(
            aspectRatio: 1.0,
            child: FutureBuilder<Image>(
              future: useCacheImage(music.info.artPic, cache: true),
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
      PullDownMenuActionsRow.medium(
        items: [
          PullDownMenuItem(
            onTap: () async {
              await onSave();
            },
            title: '缓存',
            icon: CupertinoIcons.cloud_download,
          ),
          PullDownMenuItem(
            onTap: () async {
              await onDelete();
            },
            title: '删除',
            icon: CupertinoIcons.delete,
          ),
          PullDownMenuItem(
            onTap: () async {
              await onEdit();
            },
            title: '编辑',
            icon: CupertinoIcons.pencil,
          ),
        ],
      ),
      const PullDownMenuDivider.large(),
      PullDownMenuItem(
        onTap: () async {
          globalTopUiController.updateWidget(
              InMusicAlbumListPage(key: UniqueKey(), music: music));
        },
        title: "查看专辑",
        icon: CupertinoIcons.music_albums,
      ),
      PullDownMenuItem(
        title: "删除缓存",
        onTap: () async {
          await onUnSave();
        },
        icon: CupertinoIcons.delete_solid,
      ),
      PullDownMenuItem(
        title: '用作封面',
        onTap: () async {
          await onUsePic();
        },
        icon: CupertinoIcons.photo,
      ),
    ];

// 资料库界面自定义歌单内部右上角的编辑触发的的长按触发操作
List<PullDownMenuEntry> musicListActionPullDown(
  BuildContext context,
  List<Music> displayMusics,
  void Function(int index, bool hasCache) refresh,
) =>
    [
      PullDownMenuItem(
        title: '全部缓存',
        onTap: () async {
          var i = 0;
          for (var music in displayMusics) {
            var index =
                globalFloatWidgetContoller.addMsg("缓存歌曲: ${music.info.name}");
            try {
              if (await music.hasCache()) continue;
              var playInfo = await music.getPlayInfo();
              if (playInfo != null) {
                String fileName =
                    music.toCacheFileName(quality_: playInfo.quality);
                await cacheFile(
                    file: playInfo.file,
                    cachePath: musicCachePath,
                    filename: fileName);
                await globalAudioHandler.replaceMusic(music);
                refresh(i, true);
              }
            } finally {
              i++;
              globalFloatWidgetContoller.delMsg(index);
            }
          }
        },
        icon: CupertinoIcons.cloud_download,
      ),
      PullDownMenuItem(
        title: '删除所有缓存',
        onTap: () async {
          var i = 0;
          for (var music in displayMusics) {
            try {
              if (music.info.defaultQuality != null) {
                if (!await music.hasCache()) continue;
                var cacheFileName = music.toCacheFileName();
                await deleteCacheFile(
                    file: "",
                    cachePath: musicCachePath,
                    filename: cacheFileName);
                await globalAudioHandler.replaceMusic(music);
                refresh(i, false);
              }
            } finally {
              i++;
            }
          }
        },
        icon: CupertinoIcons.delete_simple,
      ),
    ];

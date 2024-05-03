import 'package:app_rhyme/comp/card/music_list_card.dart';
import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/other.dart';
import 'package:app_rhyme/util/selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class MusicPage extends StatefulWidget {
  final MusicList musicList;

  const MusicPage({
    super.key,
    required this.musicList,
  });

  @override
  MusicPageState createState() => MusicPageState();
}

class MusicPageState extends State<MusicPage> {
  List<DisplayMusic> _musics = [];
  late MusicList _musicList;
  @override
  void initState() {
    _musicList = widget.musicList;
    super.initState();
    refreshMusicList();
  }

  Future<void> refreshMusicList() async {
    var results = await globalSqlMusicFactory.readMusic(musicList: _musicList);
    setState(() {
      _musics = results.map((m) => DisplayMusic(m)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        trailing: editTextButton(context),
      ),
      child: SafeArea(
          child: CustomScrollView(
        slivers: <Widget>[
          // 封面图片
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                  top: Screen.width * 0.1,
                  left: Screen.width * 0.1,
                  right: Screen.width * 0.1),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: Screen.width * 0.7,
                ),
                child: MusicListCard(musicList: _musicList),
              ),
            ),
          ),
          // 两个按钮
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
                      globalAudioHandler.clearReplaceMusicAll(_musics);
                    },
                  ),
                  _buildButton(
                    context,
                    icon: Icons.shuffle,
                    label: '随机播放',
                    onPressed: () {
                      var musics = _musics.toList();
                      musics.shuffle();
                      globalAudioHandler
                          .clearReplaceMusicAll(shuffleList(musics));
                    },
                  ),
                ],
              ),
            ),
          ),
          // 一个分界线
          const SliverToBoxAdapter(
            child: Divider(
              color: CupertinoColors.systemGrey5,
              height: 1,
            ),
          ),
          SliverList.separated(
            separatorBuilder: (context, index) => const Divider(
              color: CupertinoColors.systemGrey4,
              indent: 30,
              endIndent: 30,
            ),
            itemBuilder: (context, index) {
              final music = _musics[index];
              return MusicCard(
                key: ValueKey(music.info.id),
                music: music,
                onClick: () {
                  globalAudioHandler.addMusicPlay(
                    music,
                  );
                },
                hasCache: music.hasCache(),
                onPress: () {
                  showCupertinoPopupWithActions(context: context, options: [
                    "缓存",
                    "删除",
                    "用作封面",
                    "删除缓存"
                  ], actionCallbacks: [
                    () async {
                      // 缓存
                      var playMusic = await display2PlayMusic(music);
                      if (playMusic == null) return;
                      cacheFile(
                              file: playMusic.playInfo.file,
                              cachePath: musicCachePath,
                              filename: playMusic.toCacheFileName())
                          .then((file) {
                        // 下载完成之后设置本地路径为新的播放文件
                        playMusic.playInfo.file = file;
                        // 如果这首歌正在播放列表中，替换他，防止继续在线播放
                        globalAudioHandler.replaceMusic(playMusic);
                        // 在这里需要重新判断是否 hasCache,所以直接setState解决
                        setState(() {});
                      });
                    },
                    () async {
                      // 删除音乐
                      await globalSqlMusicFactory.delMusic(
                          musicList: _musicList,
                          ids: Int64List.fromList([music.info.id]));
                      setState(() {
                        _musics.removeAt(index);
                      });
                    },
                    () async {
                      // 将音乐图片应用成歌单图片
                      var pic = music.info.artPic;
                      if (pic != null) {
                        await globalSqlMusicFactory.changeMusicListMetadata(
                            oldList: [
                              _musicList
                            ],
                            newList: [
                              MusicList(
                                  name: "", artPic: pic, desc: _musicList.desc)
                            ]).then((_) {
                          setState(() {
                            _musicList = MusicList(
                                name: _musicList.name,
                                artPic: pic,
                                desc: _musicList.desc);
                          });
                        });
                      }
                    },
                    () async {
                      // 删除缓存
                      var result = music.toCacheFileNameAndExtra();
                      if (result == null) return;
                      var (cacheFileName, _) = result;
                      deleteCacheFile(
                              file: "",
                              cachePath: musicCachePath,
                              filename: cacheFileName)
                          .then((value) {
                        // 删除缓存后刷新是否有缓存
                        setState(() {});
                        if (kDebugMode) {
                          print("成功删除缓存:${music.info.name}");
                        }
                        display2PlayMusic(music).then((value) {
                          if (value == null) return;
                          globalAudioHandler.replaceMusic(value);
                        });
                      });
                    }
                  ]);
                },
              );
            },
            itemCount: _musics.length,
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 200),
            ),
          ),
        ],
      )),
    );
  }
}

Widget editTextButton(BuildContext context) {
  return CustomPopup(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text('多选'),
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
      style: TextStyle(color: activeIconColor),
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

import 'package:app_rhyme/comp/form/music_list_table_form.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 在歌单内的音乐卡片的长按触发操作
List<PullDownMenuEntry> inListMusicCardPullDown(
        BuildContext context,
        DisplayMusic music,
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

// 播放展示界面的列表中的音乐卡片的长按触发操作
List<PullDownMenuEntry> displayListMusicCardPullDown(
  BuildContext context,
  PlayMusic music,
  Future<void> Function() onDelete,
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
        title: "删除",
        onTap: () async {
          await onDelete();
        },
        icon: CupertinoIcons.delete_solid,
      ),
      PullDownMenuItem(
        title: "添加到歌单",
        onTap: () async {
          var musicLists = await globalSqlMusicFactory.readMusicLists();
          if (context.mounted) {
            await showPullDownMenu(
                context: context,
                items: addToMusicListPullDown(context, musicLists,
                    DisplayMusic(music.ref, info_: music.info), position),
                position: position);
          }
        },
        icon: CupertinoIcons.add_circled_solid,
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

// 搜索界面的音乐卡片的长按触发操作
List<PullDownMenuEntry> searchMusicCardPullDown(
  BuildContext context,
  DisplayMusic music,
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
                    context, musicLists, music, position),
                position: position);
          }
        },
        icon: CupertinoIcons.add_circled_solid,
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

// 添加到已存在的音乐歌单的触发操作
List<PullDownMenuEntry> addToMusicListPullDown(BuildContext context,
        List<MusicList> musicLists, DisplayMusic music, Rect position) =>
    musicLists
        .map(
          (musicList) => PullDownMenuHeader(
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
            onTap: () async {
              await globalSqlMusicFactory
                  .insertMusic(musicList: musicList, musics: [music.ref]);

              if (music.info.artPic != null) {
                await cacheFile(
                  file: music.info.artPic!,
                  cachePath: picCachePath,
                );
              }
            },
          ),
        )
        .toList();

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

// 选择变更后的quality的触发操作
List<PullDownMenuEntry> qualitySelectPullDown(
        BuildContext context,
        List<Quality> qualitys,
        Future<void> Function(Quality selectQuality) onSelect) =>
    [
      PullDownMenuTitle(
          title: Text(
        "选择一个音质",
        style: const TextStyle().useSystemChineseFont(),
      )),
      ...qualitys.map(
        (quality) => PullDownMenuItem(
            title: quality.short,
            onTap: () async {
              await onSelect(quality);
            }),
      )
    ];

// 歌单列表右上角的编辑触发的的长按触发操作
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

// 歌单内部右上角的编辑触发的的长按触发操作
List<PullDownMenuEntry> musicListActionPullDown(
  BuildContext context,
  List<DisplayMusic> displayMusics,
  void Function() refresh,
) =>
    [
      PullDownMenuItem(
        title: '全部缓存',
        onTap: () async {
          for (var music in displayMusics) {
            if (await music.hasCache()) continue;
            var playMusic = await display2PlayMusic(music);
            if (playMusic != null) {
              await cacheFile(
                  file: playMusic.playInfo.file,
                  cachePath: musicCachePath,
                  filename: playMusic.toCacheFileName());
            }
            refresh();
          }
        },
        icon: CupertinoIcons.cloud_download,
      ),
      PullDownMenuItem(
        title: '删除所有缓存',
        onTap: () async {
          for (var music in displayMusics) {
            if (music.info.defaultQuality != null) {
              var result =
                  music.toCacheFileNameAndExtra(music.info.defaultQuality!);
              if (result == null) return;
              var (cacheFileName, _) = result;
              await deleteCacheFile(
                  file: "", cachePath: musicCachePath, filename: cacheFileName);
              refresh();
            }
          }
        },
        icon: CupertinoIcons.delete_simple,
      ),
    ];

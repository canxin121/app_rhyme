import 'package:app_rhyme/comp/card/music_card.dart';
import 'package:app_rhyme/comp/form/music_list_table_form.dart';
import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/page/in_music_album.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/audio_controller.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/pull_down_selection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_down_button/pull_down_button.dart';

// MusicList组件
class MusicListComp extends StatelessWidget {
  final double maxHeight;
  final EdgeInsets picPadding;
  final double itemHeight;
  const MusicListComp(
      {super.key,
      required this.maxHeight,
      required this.picPadding,
      this.itemHeight = 50});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var musics = globalAudioHandler.musicList;

      return Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList.separated(
                separatorBuilder: (context, index) => const Divider(
                  color: CupertinoColors.systemGrey,
                  indent: 50,
                  endIndent: 50,
                ),
                itemBuilder: (context, index) => MusicCard(
                  titleBold: false,
                  darkFontColor: true,
                  height: itemHeight,
                  showQualityBackGround: false,
                  padding: Padding(padding: picPadding),
                  key: ValueKey((musics[index].info.name +
                          musics[index].info.source +
                          musics[index].info.name)
                      .hashCode),
                  music: musics[index],
                  onClick: () {
                    globalAudioHandler.seek(Duration.zero, index: index);
                  },
                  onPress: (details) async {
                    var position = details.globalPosition & Size.zero;
                    showPullDownMenu(
                        context: context,
                        items: displayListMusicCardPullDown(
                            context, musics[index], () async {
                          await globalAudioHandler.removeAt(index);
                        }, position),
                        position: position);
                  },
                ),
                itemCount: musics.length,
              ),
            ],
          ));
    });
  }
}

// 播放展示界面的列表中的音乐卡片的长按触发操作
List<PullDownMenuEntry> displayListMusicCardPullDown(
  BuildContext context,
  Music music,
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
                    Future.value([Music(music.ref)]), position),
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
      PullDownMenuItem(
        onTap: () async {
          globalTopUiController.updateWidget(
              InMusicAlbumListPage(key: UniqueKey(), music: Music(music.ref)));
        },
        title: "查看专辑",
        icon: CupertinoIcons.music_albums,
      ),
    ];

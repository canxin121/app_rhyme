import 'dart:async';

import 'package:app_rhyme/main.dart';
import 'package:app_rhyme/page/home.dart';
import 'package:app_rhyme/src/rust/api/cache.dart';
import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/types/music.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 添加到已存在的音乐歌单的触发操作
List<PullDownMenuEntry> addToMusicListPullDown(
        BuildContext context,
        List<MusicList> musicLists,
        Future<List<DisplayMusic>?> musicsFuture,
        Rect position) =>
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
              var musics = await musicsFuture;
              if (musics == null) return;
              await globalSqlMusicFactory.insertMusic(
                  musicList: musicList,
                  musics: musics.map((e) => e.ref).toList());
              for (var music in musics) {
                if (music.info.artPic != null) {
                  await cacheFile(
                    file: music.info.artPic!,
                    cachePath: picCachePath,
                  );
                }
              }
            },
          ),
        )
        .toList();

// 添加到已存在的音乐歌单的触发操作
List<PullDownMenuEntry> floatWidgetPullDown(Rect position) => [
      PullDownMenuHeader(
        onTap: null,
        title: "进行中的任务",
        leading: Container(
            constraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
            alignment: Alignment.center,
            child: const Icon(CupertinoIcons.square_stack_3d_down_right_fill)),
      ),
      ...globalFloatWidgetContoller.msgs.values.map(
        (msg) => PullDownMenuItem(onTap: null, title: msg),
      )
    ];

import 'dart:io';

import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

// 这是自定义歌单的展示卡片
class MusicListCard extends StatelessWidget {
  final MusicList musicList;
  final bool expanded;
  final VoidCallback? onClick;
  final void Function(LongPressStartDetails details)? onPress;
  const MusicListCard({
    super.key,
    required this.musicList,
    this.onClick,
    this.onPress,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    var picWidget = GlassContainer(
      shadowColor: Platform.isIOS
          ? CupertinoColors.black.withOpacity(0.2)
          : CupertinoColors.black.withOpacity(0.4),
      shadowStrength: Platform.isIOS ? 2 : 5,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(8.0),
      child: AspectRatio(
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
    );
    return GestureDetector(
      onLongPressStart: onPress,
      onTap: onClick,
      child: Column(
        children: <Widget>[
          if (expanded) Expanded(child: picWidget) else picWidget,
          // 歌单名称
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              musicList.name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ).useSystemChineseFont(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 歌单介绍
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              musicList.desc,
              style: const TextStyle(
                fontSize: 14.0,
                color: CupertinoColors.systemGrey,
              ).useSystemChineseFont(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

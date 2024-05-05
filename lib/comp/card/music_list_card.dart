import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/util/helper.dart';

// 这是自定义歌单的展示卡片
class MusicListCard extends StatelessWidget {
  final MusicList musicList;
  final VoidCallback? onClick;
  final VoidCallback? onPress;

  const MusicListCard({
    super.key,
    required this.musicList,
    this.onClick,
    this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: onPress,
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0), // 设置圆角
            child: AspectRatio(
              aspectRatio: 1.0,
              child: FutureBuilder<Image>(
                // 这里的第二个传参表示是否缓存
                future: useCacheImage(musicList.artPic),
                builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: defaultArtPic.image, // 默认图片
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: CupertinoColors.systemGrey, // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                        borderRadius: BorderRadius.circular(8.0), // 边框圆角
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: defaultArtPic.image, // 默认图片
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: CupertinoColors.systemGrey, // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                        borderRadius: BorderRadius.circular(8.0), // 边框圆角
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: snapshot.data?.image ??
                              defaultArtPic.image, // 默认图片
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: CupertinoColors.systemGrey, // 边框颜色
                          width: 1.0, // 边框宽度
                        ),
                        borderRadius: BorderRadius.circular(8.0), // 边框圆角
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          // 歌单名称
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              musicList.name,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              musicList.desc,
              style: const TextStyle(
                fontSize: 14.0,
                color: CupertinoColors.systemGrey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

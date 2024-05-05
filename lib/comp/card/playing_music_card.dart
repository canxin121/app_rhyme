import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 这个组件在 待播放列表和歌词的上方显示
class PlayingMusicCard extends StatefulWidget {
  final VoidCallback? onClick;
  final VoidCallback? onPress;
  const PlayingMusicCard({
    super.key,
    this.onClick,
    this.onPress,
  });

  @override
  PlayingMusicCardState createState() => PlayingMusicCardState();
}

class PlayingMusicCardState extends State<PlayingMusicCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 根据isTaller参数决定卡片的高度
    double cardHeight = 80.0;

    return SafeArea(
        child: GestureDetector(
      onTap: widget.onClick,
      onLongPress: widget.onPress,
      child: SizedBox(
        height: cardHeight, // 使用变量cardHeight作为高度
        width: double.infinity, // 确保SizedBox填充水平空间
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            // 可以添加装饰来可视化容器的边界
            color: Colors.transparent, // 设置透明背景
          ),
          child: Row(
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left: 20)),
              Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: FutureBuilder<Hero>(
                      future: playingMusicImage(), // 这里调用异步函数
                      builder:
                          (BuildContext context, AsyncSnapshot<Hero> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return defaultArtPic; // 默认图片
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return snapshot.data ??
                              defaultArtPic; // 异步函数提供的图片或默认图片
                        }
                      },
                    ),
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Obx(
                        () => Text(
                          playingMusicName,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 3.0),
                      Obx(() => Text(
                            playingMusicArtist,
                            style: const TextStyle(
                                fontSize: 12.0,
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

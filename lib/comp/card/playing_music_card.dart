import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 这个组件在 待播放列表和歌词的上方显示
class PlayingMusicCard extends StatefulWidget {
  final double height;
  final EdgeInsets picPadding;
  final VoidCallback? onClick;
  final VoidCallback? onPress;
  const PlayingMusicCard({
    super.key,
    this.onClick,
    this.onPress,
    required this.height,
    required this.picPadding,
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
    return SafeArea(
        child: GestureDetector(
      onTap: widget.onClick,
      onLongPress: widget.onPress,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            children: <Widget>[
              Padding(padding: widget.picPadding),
              Obx(() => ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: FutureBuilder<Hero>(
                      future: playingMusicImage(),
                      builder:
                          (BuildContext context, AsyncSnapshot<Hero> snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError) {
                          return defaultArtPic;
                        } else {
                          return snapshot.data ?? defaultArtPic;
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
              const Padding(padding: EdgeInsets.only(right: 20)),
            ],
          ),
        ),
      ),
    ));
  }
}

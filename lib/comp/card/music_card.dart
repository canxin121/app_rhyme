import 'package:app_rhyme/src/rust/api/mirror.dart';
import 'package:app_rhyme/util/colors.dart';
import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:app_rhyme/util/time_parse.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MusicCard extends StatefulWidget {
  final dynamic music;
  final VoidCallback? onClick;
  final VoidCallback? onPress;
  final Future<bool>? hasCache;
  final Padding? padding;
  final bool? showQualityBackGround;
  final double height;
  const MusicCard({
    super.key,
    required this.music,
    this.onClick,
    this.onPress,
    this.hasCache,
    this.padding,
    this.showQualityBackGround = true,
    this.height = 60,
  });

  @override
  MusicCardState createState() => MusicCardState();
}

class MusicCardState extends State<MusicCard> {
  late MusicInfo info;

  @override
  void initState() {
    super.initState();
    info = widget.music.info;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              widget.padding ??
                  const Padding(padding: EdgeInsets.only(left: 10)),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: info.artPic != null
                    ? FutureBuilder(
                        future: useCacheImage(info.artPic!),
                        builder: (context, snapshot) {
                          if (snapshot.hasError ||
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return defaultArtPic;
                          } else {
                            return snapshot.data ?? defaultArtPic;
                          }
                        },
                      )
                    : defaultArtPic,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        info.name,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ).useSystemChineseFont(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        info.artist.join(", "),
                        style: const TextStyle(
                                fontSize: 12.0,
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.w500)
                            .useSystemChineseFont(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (info.duration != null)
                Row(
                  children: [
                    // 显示音质
                    if (info.defaultQuality != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: (widget.showQualityBackGround != null &&
                                widget.showQualityBackGround == true)
                            ? BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                border: Border.all(
                                    color: CupertinoColors.systemGrey6,
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(4.0),
                              )
                            : null,
                        child: Text(
                          info.defaultQuality!.short,
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                          ).useSystemChineseFont(),
                        ),
                      ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    // 显示音乐总时长
                    Text(
                      formatDuration(info.duration!),
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: CupertinoColors.black,
                      ).useSystemChineseFont(),
                    ),
                    // 音乐总时长和是否下载图标的间隙
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    // 标志是否有缓存的图标
                    if (widget.hasCache != null)
                      FutureBuilder<bool>(
                        future: widget.hasCache,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            bool isDownloaded = snapshot.data ?? false;
                            return Icon(
                              isDownloaded
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_download_outlined,
                              size: 16.0,
                              color: activeIconColor,
                            );
                          }
                        },
                      ),
                  ],
                ),
              const Padding(padding: EdgeInsets.only(right: 10))
            ],
          ),
        ),
      ),
    );
  }
}

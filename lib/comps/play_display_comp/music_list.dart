import 'package:app_rhyme/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MusicContainerListItem(
                    musicContainer: musics[index],
                    inPlayList: true,
                    isDark: true,
                  ),
                ),
                itemCount: musics.length,
              ),
            ],
          ));
    });
  }
}

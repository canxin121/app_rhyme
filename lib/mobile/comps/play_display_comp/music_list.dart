import 'package:app_rhyme/mobile/comps/music_agg_comp/music_container_list_item.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// MusicList组件
class MusicListComp extends StatelessWidget {
  final double maxHeight;
  const MusicListComp({
    super.key,
    required this.maxHeight,
  });

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
                    musicAgg: musics[index].musicAggregator,
                    isDark: true,
                    onTap: () {
                      globalAudioHandler.seek(Duration.zero, index: index);
                    },
                    index: index,
                  ),
                ),
                itemCount: musics.length,
              ),
            ],
          ));
    });
  }
}

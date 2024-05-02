import 'package:app_rhyme/util/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class MusicInfo extends StatefulWidget {
  const MusicInfo({super.key});

  @override
  State<StatefulWidget> createState() => MusicInfoState();
}

class MusicInfoState extends State<MusicInfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 25),
      child: Column(
        children: [
          // 音乐名称
          Obx(() {
            return Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$playingMusicName\n$playingMusicArtist",
                style: const TextStyle(fontSize: 20.0),
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
              ),
            );
          }),
        ],
      ),
    );
  }
}

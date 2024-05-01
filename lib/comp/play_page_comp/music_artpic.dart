import 'package:app_rhyme/util/default.dart';
import 'package:app_rhyme/util/helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class MusicArtPic extends StatefulWidget {
  const MusicArtPic({
    super.key,
  }); // 修改构造函数

  @override
  State<StatefulWidget> createState() => MusicArtPicState();
}

class MusicArtPicState extends State<MusicArtPic> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FutureBuilder<Hero>(
        future: playingMusicImage(), // 这里调用异步函数
        builder: (BuildContext context, AsyncSnapshot<Hero> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: defaultArtPic,
                ) // 异步函数提供的图片或默认图片
                );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // 使用Cupertino组件包裹图片，并限制大小和加圆角边框
            return Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: snapshot.data ?? defaultArtPic,
                ));
          }
        },
      ),
    );
  }
}

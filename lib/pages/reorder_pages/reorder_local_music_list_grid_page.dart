import 'dart:io';

import 'package:app_rhyme/pages/local_music_list_gridview_page.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:reorderables/reorderables.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_image_card.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/utils/colors.dart';

class ReorderLocalMusicListGridPage extends StatefulWidget {
  final List<MusicListW> musicLists;
  const ReorderLocalMusicListGridPage({super.key, required this.musicLists});

  @override
  ReorderLocalMusicListGridPageState createState() =>
      ReorderLocalMusicListGridPageState();
}

class ReorderLocalMusicListGridPageState
    extends State<ReorderLocalMusicListGridPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final double screenWidth = MediaQuery.of(context).size.width;

    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final Color backgroundColor =
        isDarkMode ? CupertinoColors.black : CupertinoColors.white;

    return CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          padding: const EdgeInsetsDirectional.all(0),
          leading: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.back, color: activeIconRed),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            child: Icon(CupertinoIcons.checkmark, color: activeIconRed),
            onPressed: () async {
              try {
                List<int> musicIds = widget.musicLists
                    .map((ml) => ml.getMusiclistInfo().id)
                    .toList();
                await SqlFactoryW.reorderMusiclist(
                    newIds: Int64List.fromList(musicIds));
                LogToast.success("歌单排序成功", "歌单排序成功",
                    "[ReorderLocalMusicListGridPageState] Music list reordered successfully");
                globalMusicListGridPageRefreshFunction();
              } catch (e) {
                LogToast.error("歌单排序失败", "歌单排序错误:$e",
                    "[ReorderLocalMusicListGridPageState] Failed to reorder music list: $e");
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        child: Column(
          children: [
            SafeArea(child: SizedBox(height: Platform.isIOS ? 0 : 10)),
            widget.musicLists.isEmpty
                ? Center(
                    child: Text("没有歌单", style: TextStyle(color: textColor)),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ReorderableWrap(
                      padding: const EdgeInsets.only(bottom: 100),
                      spacing: 8.0,
                      runSpacing: 8.0,
                      needsLongPressDraggable: true,
                      children: widget.musicLists.map((musicList) {
                        return SizedBox(
                            width: screenWidth / 2 - 20,
                            child: MusicListImageCard(
                              key: ValueKey(musicList.getMusiclistInfo().id),
                              musicListW: musicList,
                              online: false,
                              onTap: () {},
                              cachePic: globalConfig.savePicWhenAddMusicList,
                            ));
                      }).toList(),
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          final MusicListW item =
                              widget.musicLists.removeAt(oldIndex);
                          widget.musicLists.insert(newIndex, item);
                        });
                      },
                    ),
                  )
          ],
        ));
  }
}

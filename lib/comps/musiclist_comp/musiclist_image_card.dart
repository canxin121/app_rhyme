import 'package:app_rhyme/comps/chores/badge.dart';
import 'package:app_rhyme/comps/musiclist_comp/musiclist_pulldown_menu.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:app_rhyme/utils/source_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';

class MusicListImageCard extends StatelessWidget {
  final MusicListW musicListW;
  final bool online;
  final GestureTapCallback? onTap;

  const MusicListImageCard({
    super.key,
    required this.musicListW,
    required this.online,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    MusicListInfo musicListInfo = musicListW.getMusiclistInfo();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    MusicListMenu(
                      builder: (context, showMenu) => GestureDetector(
                        onLongPress: () {
                          showMenu();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: imageCacheHelper(musicListInfo.artPic),
                        ),
                      ),
                      musicListW: musicListW,
                      online: online,
                    ),
                    Positioned(
                      top: 3,
                      left: 3,
                      child: Badge(
                        label: sourceToShort(musicListW.source()),
                        isDark: true,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: MusicListMenu(
                        builder: (context, showMenu) => GestureDetector(
                          onTap: showMenu,
                          child: Icon(CupertinoIcons.ellipsis_circle,
                              color: activeIconRed),
                        ),
                        musicListW: musicListW,
                        online: online,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Center(
                    child: Text(
                      musicListInfo.name,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  fit: FlexFit.loose,
                  child: Center(
                    child: Text(
                      musicListInfo.desc,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            color: CupertinoColors.systemGrey,
                            fontSize: 16,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

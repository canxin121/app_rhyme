import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/pages/local_music_list_grid_page.dart';
import 'package:app_rhyme/pages/local_music_list_page.dart';
import 'package:app_rhyme/src/rust/api/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/mirrors.dart';
import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:toastification/toastification.dart';

// 有三种使用场景: 1. 本地歌单 2. 在线歌单
// 区分:
// 1. 本地歌单的歌曲: online == false
// 2. 在线的歌曲:  online == true

// 可执行的操作:
// 1. 本地歌单的歌曲:查看详情, 编辑信息, 删除歌单
// 2. 在线的歌曲:查看详情,保存为新增歌单, 添加到已有歌单

@immutable
class MusicListMenu extends StatelessWidget {
  const MusicListMenu({
    super.key,
    required this.builder,
    required this.musicListW,
    required this.online,
  });

  final PullDownMenuButtonBuilder builder;
  final MusicListW musicListW;
  final bool online;

  @override
  Widget build(BuildContext context) {
    MusicListInfo musicListInfo = musicListW.getMusiclistInfo();
    List<dynamic> menuItems;

    if (!online) {
      // 本地歌单的歌曲
      menuItems = localMusiclistItems(context, musicListW);
    } else {
      // 在线的歌曲
      menuItems = _onlineMusicListItems(context, musicListW);
    }

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          leading: imageCacheHelper(musicListInfo.artPic),
          title: musicListInfo.name,
          subtitle: musicListInfo.desc,
        ),
        const PullDownMenuDivider.large(),
        ...menuItems,
      ],
      animationBuilder: null,
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}

// 查看详情, 编辑信息, 删除歌单
List<dynamic> localMusiclistItems(BuildContext context, MusicListW musicListW) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        PullDownMenuItem(
          onTap: () {
            showMusicListInfoDialog(context,
                defaultMusicList: musicListW.getMusiclistInfo(),
                readonly: true);
          },
          title: '查看详情',
          icon: CupertinoIcons.photo,
        ),
        PullDownMenuItem(
          onTap: () async {
            var newMusicListInfo = await showMusicListInfoDialog(context,
                defaultMusicList: musicListW.getMusiclistInfo(),
                readonly: false);
            if (newMusicListInfo != null) {
              try {
                await SqlFactoryW.changeMusiclistInfo(
                    old: [musicListW.getMusiclistInfo()],
                    new_: [newMusicListInfo]);
                globalMusicListGridPageRefreshFunction();
                await globalMusicContainerListPageRefreshFunction();

                toastification.show(
                    autoCloseDuration: const Duration(seconds: 2),
                    type: ToastificationType.success,
                    title: Text("编辑歌单",
                        style: const TextStyle().useSystemChineseFont()),
                    description: Text("编辑歌单成功",
                        style: const TextStyle().useSystemChineseFont()));
              } catch (e) {
                toastification.show(
                    autoCloseDuration: const Duration(seconds: 2),
                    type: ToastificationType.error,
                    title: Text("编辑歌单",
                        style: const TextStyle().useSystemChineseFont()),
                    description: Text("编辑歌单失败: $e",
                        style: const TextStyle().useSystemChineseFont()));
              }
            }
          },
          title: '编辑信息',
          icon: CupertinoIcons.pencil,
        ),
        PullDownMenuItem(
          onTap: () async {
            try {
              await SqlFactoryW.delMusiclist(
                  musiclistNames: [musicListW.getMusiclistInfo().name]);
              globalMusicListGridPageRefreshFunction();

              toastification.show(
                  autoCloseDuration: const Duration(seconds: 2),
                  type: ToastificationType.success,
                  title: Text("删除歌单",
                      style: const TextStyle().useSystemChineseFont()),
                  description: Text("删除歌单成功",
                      style: const TextStyle().useSystemChineseFont()));

              globalMusicListGridPageRefreshFunction();
              globalMusicContainerListPagePopFunction();
            } catch (e) {
              toastification.show(
                  autoCloseDuration: const Duration(seconds: 2),
                  type: ToastificationType.error,
                  title: Text("删除歌单",
                      style: const TextStyle().useSystemChineseFont()),
                  description: Text("删除歌单失败: $e",
                      style: const TextStyle().useSystemChineseFont()));
            }
          },
          title: '删除歌单',
          icon: CupertinoIcons.delete,
        ),
      ],
    ),
  ];
}

// 查看详情,保存为新增歌单, 添加到已有歌单
List<dynamic> _onlineMusicListItems(
    BuildContext context, MusicListW musicListw) {
  return [
    PullDownMenuItem(
      onTap: () {
        showMusicListInfoDialog(context,
            defaultMusicList: musicListw.getMusiclistInfo(), readonly: true);
      },
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      onTap: () async {
        var musicListInfo = await showMusicListInfoDialog(context,
            defaultMusicList: musicListw.getMusiclistInfo());
        if (musicListInfo != null) {
          try {
            await SqlFactoryW.createMusiclist(musicListInfos: [musicListInfo]);
            var aggs = await musicListw.fetchAllMusicAggregators(
                pagesPerBatch: 5, limit: 50);
            await SqlFactoryW.addMusics(
                musicsListName: musicListInfo.name, musics: aggs);
            globalMusicListGridPageRefreshFunction();
            toastification.show(
                title: Text("保存歌单",
                    style: const TextStyle().useSystemChineseFont()),
                description: Text("保存歌单成功",
                    style: const TextStyle().useSystemChineseFont()),
                autoCloseDuration: const Duration(seconds: 2),
                type: ToastificationType.success);
          } catch (e) {
            toastification.show(
                title: Text("保存歌单",
                    style: const TextStyle().useSystemChineseFont()),
                description: Text("保存歌单失败: $e",
                    style: const TextStyle().useSystemChineseFont()),
                autoCloseDuration: const Duration(seconds: 2),
                type: ToastificationType.error);
          }
        }
      },
      title: '保存为新增歌单',
      icon: CupertinoIcons.add_circled,
    ),
    PullDownMenuItem(
      onTap: () async {
        var targetMusicList = await showMusicListSelectionDialog(context);
        if (targetMusicList != null) {
          try {
            var aggs = await musicListw.fetchAllMusicAggregators(
                pagesPerBatch: 5, limit: 50);
            await SqlFactoryW.addMusics(
                musicsListName: targetMusicList.getMusiclistInfo().name,
                musics: aggs);
            await globalMusicContainerListPageRefreshFunction();
            toastification.show(
                title: Text("添加歌曲",
                    style: const TextStyle().useSystemChineseFont()),
                description: Text("添加歌曲成功",
                    style: const TextStyle().useSystemChineseFont()),
                autoCloseDuration: const Duration(seconds: 2),
                type: ToastificationType.success);
          } catch (e) {
            toastification.show(
                title: Text("添加歌曲",
                    style: const TextStyle().useSystemChineseFont()),
                description: Text("添加歌曲失败: $e",
                    style: const TextStyle().useSystemChineseFont()),
                autoCloseDuration: const Duration(seconds: 2),
                type: ToastificationType.error);
          }
        }
      },
      title: '添加到已有歌单',
      icon: CupertinoIcons.add_circled_solid,
    ),
  ];
}

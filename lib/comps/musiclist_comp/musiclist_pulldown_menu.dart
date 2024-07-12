import 'package:app_rhyme/src/rust/api/bind/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/utils/const_vars.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/pages/local_music_list_gridview_page.dart';
import 'package:app_rhyme/pages/local_music_container_listview_page.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

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
                LogToast.success("编辑歌单", "编辑歌单成功",
                    "[LocalMusicListItemsPullDown] Succeed to edit music list");
              } catch (e) {
                LogToast.error("编辑歌单", "编辑歌单失败: $e",
                    "[LocalMusicListItemsPullDown] Failed to edit music list: $e");
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
              LogToast.success("删除歌单", "删除歌单成功",
                  "[LocalMusicListItemsPullDown] Succeed to delete music list");
              globalMusicListGridPageRefreshFunction();
              globalMusicContainerListPagePopFunction();
            } catch (e) {
              LogToast.error("删除歌单", "删除歌单失败: $e",
                  "[LocalMusicListItemsPullDown] Failed to delete music list: $e");
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
          LogToast.success("保存歌单", "正在获取歌单数据，请稍等",
              "[OnlineMusicListItemsPullDown] Start to save music list");

          try {
            if (musicListInfo.artPic.isNotEmpty) {
              cacheFileHelper(musicListInfo.artPic, picCacheRoot);
            }
            await SqlFactoryW.createMusiclist(musicListInfos: [musicListInfo]);
            var aggs = await musicListw.fetchAllMusicAggregators(
                pagesPerBatch: 5,
                limit: 50,
                withLyric: globalConfig.saveLyricWhenAddMusicList);
            if (globalConfig.savePicWhenAddMusicList) {
              for (var agg in aggs) {
                var pic = agg.getDefaultMusic().getMusicInfo().artPic;
                if (pic != null && pic.isNotEmpty) {
                  cacheFileHelper(pic, picCacheRoot);
                }
              }
            }
            await SqlFactoryW.addMusics(
                musicsListName: musicListInfo.name, musics: aggs);
            globalMusicListGridPageRefreshFunction();
            LogToast.success("保存歌单", "保存歌单成功",
                "[OnlineMusicListItemsPullDown] Succeed to save music list");
          } catch (e) {
            LogToast.error("保存歌单", "保存歌单失败: $e",
                "[OnlineMusicListItemsPullDown] Failed to save music list: $e");
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
          LogToast.info("添加歌曲", "正在获取歌单数据，请稍等",
              "[OnlineMusicListItemsPullDown] Start to add music");
          try {
            var aggs = await musicListw.fetchAllMusicAggregators(
                pagesPerBatch: 5,
                limit: 50,
                withLyric: globalConfig.saveLyricWhenAddMusicList);
            if (globalConfig.savePicWhenAddMusicList) {
              for (var agg in aggs) {
                var pic = agg.getDefaultMusic().getMusicInfo().artPic;
                if (pic != null && pic.isNotEmpty) {
                  cacheFileHelper(pic, picCacheRoot);
                }
              }
            }
            await SqlFactoryW.addMusics(
                musicsListName: targetMusicList.getMusiclistInfo().name,
                musics: aggs);
            await globalMusicContainerListPageRefreshFunction();
            LogToast.success("添加歌曲", "添加歌曲成功",
                "[OnlineMusicListItemsPullDown] Succeed to add music");
          } catch (e) {
            LogToast.error("添加歌曲", "添加歌曲失败: $e",
                "[OnlineMusicListItemsPullDown] Failed to add music: $e");
          }
        }
      },
      title: '添加到已有歌单',
      icon: CupertinoIcons.add_circled_solid,
    ),
  ];
}

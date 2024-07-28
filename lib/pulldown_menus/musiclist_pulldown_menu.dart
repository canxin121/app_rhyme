import 'package:app_rhyme/src/rust/api/bind/factory_bind.dart';
import 'package:app_rhyme/src/rust/api/bind/mirrors.dart';
import 'package:app_rhyme/src/rust/api/bind/type_bind.dart';
import 'package:app_rhyme/utils/log_toast.dart';
import 'package:app_rhyme/dialogs/musiclist_info_dialog.dart';
import 'package:app_rhyme/dialogs/select_local_music_dialog.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:app_rhyme/utils/refresh.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 有三种使用场景: 1. 本地歌单 2. 在线歌单
// 区分:
// 1. 本地歌单的歌曲: online == false
// 2. 在线的歌曲:  online == true

// 可执行的操作:
// 1. 本地歌单的歌曲:查看详情, 编辑信息, 删除歌单
// 2. 在线的歌曲:查看详情,保存为新增歌单, 添加到已有歌单

void showMusicListMenu(
    BuildContext context, MusicListW musicListW, bool online, Rect position) {
  MusicListInfo musicListInfo = musicListW.getMusiclistInfo();
  List<dynamic> menuItems;

  if (!online) {
    // 本地歌单
    menuItems = localMusiclistItems(context, musicListW);
  } else {
    // 在线的歌单
    menuItems = onlineMusicListItems(context, musicListW);
  }
  List<PullDownMenuEntry> items = [
    PullDownMenuHeader(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      leading: imageCacheHelper(musicListInfo.artPic),
      title: musicListInfo.name,
      subtitle: musicListInfo.desc,
    ),
    const PullDownMenuDivider.large(),
    ...menuItems,
  ];
  showPullDownMenu(
    position: position,
    context: context,
    items: items,
  );
}

// 查看详情, 编辑信息, 删除歌单
List<PullDownMenuEntry> localMusiclistItems(
    BuildContext context, MusicListW musicList) {
  return [
    PullDownMenuActionsRow.medium(
      items: [
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () {
            showMusicListInfoDialog(context,
                defaultMusicList: musicList.getMusiclistInfo(), readonly: true);
          },
          title: '查看详情',
          icon: CupertinoIcons.photo,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            await editMusicListInfo(context, musicList);
          },
          title: '编辑信息',
          icon: CupertinoIcons.pencil,
        ),
        PullDownMenuItem(
          itemTheme: PullDownMenuItemTheme(
              textStyle: const TextStyle().useSystemChineseFont()),
          onTap: () async {
            try {
              await SqlFactoryW.delMusiclist(
                  musiclistNames: [musicList.getMusiclistInfo().name]);
              LogToast.success("删除歌单", "删除歌单成功",
                  "[LocalMusicListItemsPullDown] Succeed to delete music list");
              refreshMusicContainerListViewPage();
              refreshMusicListGridViewPage();
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
    PullDownMenuItem(
        itemTheme: PullDownMenuItemTheme(
            textStyle: const TextStyle().useSystemChineseFont()),
        onTap: () async {
          try {
            await SqlFactoryW.delDuplicateMusicsOfMusiclist(
                musiclistInfo: musicList.getMusiclistInfo());
            LogToast.success("歌曲合并去重", "歌曲合并去重成功",
                "[LocalMusicListItemsPullDown] Succeed to merge and deduplicate music");
            refreshMusicListGridViewPage();
            refreshMusicContainerListViewPage();
          } catch (e) {
            LogToast.error("歌曲合并去重", "歌曲合并去重失败: $e",
                "[LocalMusicListItemsPullDown] Failed to merge and deduplicate music: $e");
          }
        },
        title: "歌曲合并去重",
        icon: CupertinoIcons.music_note_list)
  ];
}

// 查看详情,保存为新增歌单, 添加到已有歌单
List<PullDownMenuEntry> onlineMusicListItems(
    BuildContext context, MusicListW musicListw) {
  return [
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () {
        showMusicListInfoDialog(context,
            defaultMusicList: musicListw.getMusiclistInfo(), readonly: true);
      },
      title: '查看详情',
      icon: CupertinoIcons.photo,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        var musicListInfo = await showMusicListInfoDialog(context,
            defaultMusicList: musicListw.getMusiclistInfo());
        if (musicListInfo != null) {
          await saveMusicList(musicListw, musicListInfo);
        }
      },
      title: '保存为新增歌单',
      icon: CupertinoIcons.add_circled,
    ),
    PullDownMenuItem(
      itemTheme: PullDownMenuItemTheme(
          textStyle: const TextStyle().useSystemChineseFont()),
      onTap: () async {
        var targetMusicList = await showMusicListSelectionDialog(context);
        if (targetMusicList != null) {
          await addAggsOfMusicListToTargetMusicList(
              musicListw, targetMusicList.getMusiclistInfo());
        }
      },
      title: '添加到已有歌单',
      icon: CupertinoIcons.add_circled_solid,
    ),
  ];
}

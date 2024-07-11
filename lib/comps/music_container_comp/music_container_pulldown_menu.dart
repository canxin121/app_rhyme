import 'package:app_rhyme/src/rust/api/type_bind.dart';
import 'package:app_rhyme/types/music_container.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:app_rhyme/utils/music_api_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

// 有三种使用场景: 1. 本地歌单的歌曲 2. 在线的歌曲 3. 播放列表
// 区分:
// 1. 本地歌单的歌曲: musicListW != null && inPlayList == false
// 2. 在线的歌曲: musicListW == null && inPlayList == false
// 3. 播放列表的歌曲: musicListW == null && inPlayList == true

// 可执行的操作:
// 1. 本地歌单的歌曲:查看详情, 缓存 or 取消缓存, 从歌单删除, 编辑信息, 搜索匹配信息,
// 搜索歌手, , 查看专辑, 添加到歌单, 创建新歌单, 用作歌单的封面
// 2. 在线的歌曲:查看详情, 添加到歌单, 创建新歌单, 搜索歌手, , 查看专辑
// 3. 播放列表的歌曲:查看详情, 从播放列表删除, , 查看专辑, 搜索歌手, 添加到歌单, 创建新歌单

@immutable
class MusicContainerMenu extends StatefulWidget {
  const MusicContainerMenu({
    super.key,
    required this.builder,
    required this.musicContainer,
    this.musicListW,
    this.inPlayList = false,
  });

  final MusicContainer musicContainer;
  final PullDownMenuButtonBuilder builder;
  final MusicListW? musicListW;
  final bool inPlayList;

  @override
  _MusicContainerMenuState createState() => _MusicContainerMenuState();
}

class _MusicContainerMenuState extends State<MusicContainerMenu> {
  late Future<bool> hasCacheFuture;

  @override
  void initState() {
    super.initState();
    hasCacheFuture = widget.musicContainer.hasCache();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> menuItems;

    if (widget.musicListW == null && !widget.inPlayList) {
      // 在线的歌曲
      menuItems = _onlineSongItems(context);
    } else if (widget.musicListW == null && widget.inPlayList) {
      // 播放列表的歌曲
      menuItems = _playlistItems(context);
    } else {
      menuItems = [];
    }

    return FutureBuilder<bool>(
      future: hasCacheFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          bool hasCache = snapshot.data ?? false;

          if (widget.musicListW != null && !widget.inPlayList) {
            // 更新本地歌单的菜单项
            menuItems = _localMusiclistItems(context, hasCache);
          }

          return PullDownButton(
            itemBuilder: (context) => [
              PullDownMenuHeader(
                leading: imageCacheHelper(widget.musicContainer.info.artPic),
                title: widget.musicContainer.info.name,
                subtitle: widget.musicContainer.info.artist.join(", "),
              ),
              const PullDownMenuDivider.large(),
              ...menuItems,
            ],
            animationBuilder: null,
            position: PullDownMenuPosition.automatic,
            buttonBuilder: widget.builder,
          );
        }
      },
    );
  }

  List<dynamic> _localMusiclistItems(BuildContext context, bool hasCache) {
    return [
      PullDownMenuActionsRow.medium(
        items: [
          PullDownMenuItem(
            onTap: () => deleteFromMusicList(
                context, widget.musicContainer, widget.musicListW!),
            title: '从歌单删除',
            icon: CupertinoIcons.delete,
          ),
          if (hasCache)
            PullDownMenuItem(
              onTap: () => deleteMusicCache(widget.musicContainer),
              title: '删除缓存',
              icon: CupertinoIcons.delete_solid,
            )
          else
            PullDownMenuItem(
              onTap: () => cacheMusicHelper(widget.musicContainer),
              title: '缓存音乐',
              icon: CupertinoIcons.cloud_download,
            ),
          PullDownMenuItem(
            onTap: () => editMusicInfo(context, widget.musicContainer),
            title: '编辑信息',
            icon: CupertinoIcons.pencil,
          ),
        ],
      ),
      PullDownMenuItem(
        onTap: () => showDetailsDialog(context, widget.musicContainer),
        title: '查看详情',
        icon: CupertinoIcons.photo,
      ),
      PullDownMenuItem(
        onTap: () => viewAlbum(context, widget.musicContainer),
        title: '查看专辑',
        icon: CupertinoIcons.music_albums,
      ),
      PullDownMenuItem(
        onTap: () => addToMusicList(context, widget.musicContainer),
        title: '添加到歌单',
        icon: CupertinoIcons.add,
      ),
      PullDownMenuItem(
        onTap: () => createNewMusicList(context, widget.musicContainer),
        title: '创建新歌单',
        icon: CupertinoIcons.add_circled,
      ),
      PullDownMenuItem(
        onTap: () =>
            setAsMusicListCover(widget.musicContainer, widget.musicListW!),
        title: '用作歌单的封面',
        icon: CupertinoIcons.photo_fill_on_rectangle_fill,
      ),
    ];
  }

  List<dynamic> _onlineSongItems(BuildContext context) {
    return [
      PullDownMenuActionsRow.medium(
        items: [
          PullDownMenuItem(
            onTap: () => createNewMusicList(context, widget.musicContainer),
            title: '创建新歌单',
            icon: CupertinoIcons.add_circled,
          ),
          PullDownMenuItem(
            onTap: () => addToMusicList(context, widget.musicContainer),
            title: '添加到歌单',
            icon: CupertinoIcons.add,
          ),
          PullDownMenuItem(
            onTap: () => viewAlbum(context, widget.musicContainer),
            title: '查看专辑',
            icon: CupertinoIcons.music_albums,
          ),
        ],
      ),
      PullDownMenuItem(
        onTap: () => showDetailsDialog(context, widget.musicContainer),
        title: '查看详情',
        icon: CupertinoIcons.photo,
      ),
      PullDownMenuItem(
        onTap: () {},
        title: '搜索歌手',
        icon: CupertinoIcons.profile_circled,
      ),
    ];
  }

  List<dynamic> _playlistItems(BuildContext context) {
    return [
      PullDownMenuActionsRow.medium(
        items: [
          PullDownMenuItem(
            onTap: () => deleteFromMusicList(
                context, widget.musicContainer, widget.musicListW!),
            title: '移除',
            icon: CupertinoIcons.delete,
          ),
          PullDownMenuItem(
            onTap: () => addToMusicList(context, widget.musicContainer),
            title: '添加到歌单',
            icon: CupertinoIcons.add,
          ),
          PullDownMenuItem(
            onTap: () => createNewMusicList(context, widget.musicContainer),
            title: '创建新歌单',
            icon: CupertinoIcons.add_circled,
          ),
        ],
      ),
      PullDownMenuItem(
        onTap: () => showDetailsDialog(context, widget.musicContainer),
        title: '查看详情',
        icon: CupertinoIcons.photo,
      ),
      PullDownMenuItem(
        onTap: () => viewAlbum(context, widget.musicContainer),
        title: '查看专辑',
        icon: CupertinoIcons.music_albums,
      ),
      // PullDownMenuItem(
      //   onTap: () {},
      //   title: '搜索歌手',
      //   icon: CupertinoIcons.profile_circled,
      // ),
    ];
  }
}

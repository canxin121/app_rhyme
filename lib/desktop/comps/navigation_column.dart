import 'dart:async';

import 'package:app_rhyme/common_pages/db_playlist_collection_page.dart';
import 'package:app_rhyme/common_pages/db_playlist_gridview_page.dart';
import 'package:app_rhyme/desktop/pages/explore_page/music_chart_page.dart';
import 'package:app_rhyme/desktop/pages/explore_page/playlist_tag_page.dart';
import 'package:app_rhyme/desktop/pages/search_page/music_aggregator.dart';
import 'package:app_rhyme/desktop/pages/search_page/playlist.dart';
import 'package:app_rhyme/desktop/home.dart';
import 'package:app_rhyme/common_pages/setting_page.dart';
import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/types/stream_controller.dart';
import 'package:app_rhyme/utils/cache_helper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

void Function() globalDesktopPopPage = () {};
void Function(Widget page, {bool replace}) globalDesktopNavigatorToPage =
    (Widget page, {bool replace = true}) {
  return;
};
void Function(String item) globalSetNavItemSelected = (String item) {};

class MyNavListContainer extends StatelessWidget {
  const MyNavListContainer({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color backgroundColor = isDarkMode
        ? const Color.fromARGB(255, 32, 32, 32)
        : const Color.fromARGB(255, 243, 243, 243);
    Color textColor =
        isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          decoration: BoxDecoration(color: backgroundColor),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: imageWithCache("", width: 30, height: 30),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "AppRhyme",
                  style: TextStyle(color: textColor).useSystemChineseFont(),
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: MyNavListView(),
        ),
      ],
    );
  }
}

class MyNavListView extends StatefulWidget {
  const MyNavListView({super.key});

  @override
  MyNavListViewState createState() => MyNavListViewState();
}

class MyNavListViewState extends State<MyNavListView> {
  List<PlaylistCollection> playlistCollections = [];
  late StreamSubscription<void>
      playlistCollectionsPageRefreshStreamSubscription;
  late StreamSubscription<int> playlistCollectionDeleteStreamSubscription;
  late StreamSubscription<PlaylistCollection>
      playlistCollectionUpdateStreamSubscription;
  late StreamSubscription<PlaylistCollection>
      playlistCollectionCreateStreamSubscription;

  @override
  void initState() {
    playlistCollectionsPageRefreshStreamSubscription =
        playlistCollectionsPageRefreshStreamController.stream.listen((e) {
      PlaylistCollection.getFormDb().then((e) {
        setState(() {
          playlistCollections = e;
        });
      });
    });

    playlistCollectionDeleteStreamSubscription =
        playlistCollectionDeleteStreamController.stream.listen((p) {
      setState(() {
        playlistCollections.removeWhere((element) => element.id == p);
      });
    });

    playlistCollectionUpdateStreamSubscription =
        playlistCollectionUpdateStreamController.stream.listen((e) {
      setState(() {
        var index =
            playlistCollections.indexWhere((element) => element.id == e.id);
        if (index != -1) {
          playlistCollections[index] = e;
        } else {
          playlistCollections.add(e);
        }
      });
    });

    playlistCollectionCreateStreamSubscription =
        playlistCollectionCreateStreamController.stream.listen((e) {
      setState(() {
        playlistCollections.add(e);
      });
    });

    globalDesktopNavigatorToPage = navigatorToPage;
    globalDesktopPopPage = popPage;

    PlaylistCollection.getFormDb().then((e) {
      setState(() {
        playlistCollections = e;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    playlistCollectionsPageRefreshStreamSubscription.cancel();
    playlistCollectionDeleteStreamSubscription.cancel();
    playlistCollectionUpdateStreamSubscription.cancel();
    playlistCollectionCreateStreamSubscription.cancel();

    globalDesktopNavigatorToPage = (Widget page, {bool replace = true}) {};
    globalDesktopPopPage = () {};
    super.dispose();
  }

  void navigatorToPage(Widget page, {bool replace = true}) {
    if (globalDesktopNavigatorKey.currentContext == null) return;
    if (replace) {
      Navigator.of(globalDesktopNavigatorKey.currentContext!).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => NestedNavigator(child: page),
        ),
      );
    } else {
      Navigator.of(globalDesktopNavigatorKey.currentContext!).push(
        CupertinoPageRoute(
          builder: (context) => NestedNavigator(child: page),
        ),
      );
    }
  }

  void popPage() {
    var navigator = Navigator.of(globalDesktopNavigatorKey.currentContext!);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavListView(
      initSelectedItem: '所有播放列表',
      children: [
        NavItem(
          title: '设置',
          icon: CupertinoIcons.settings,
          onTap: () {
            globalSetNavItemSelected("###Setting###");
            navigatorToPage(
              const SettingPage(
                isDesktop: true,
              ),
            );
          },
          identity: '###Setting###',
        ),
        NavGroup(title: "浏览", icon: CupertinoIcons.compass, items: [
          NavItem(
            title: '歌曲排行榜',
            icon: CupertinoIcons.music_note_2,
            onTap: () {
              globalSetNavItemSelected("###MusicChart###");
              navigatorToPage(const MusicChartPage(
                isDesktop: true,
              ));
            },
            identity: '###MusicChart###',
          ),
          NavItem(
            title: '浏览歌单',
            icon: CupertinoIcons.music_albums,
            onTap: () {
              globalSetNavItemSelected("###PlaylistTag###");
              navigatorToPage(const PlaylistTagPage(
                isDesktop: true,
              ));
            },
            identity: "###PlaylistTag###",
          ),
        ]),
        NavGroup(title: "搜索", icon: CupertinoIcons.search, items: [
          NavItem(
            title: '搜索单曲',
            icon: CupertinoIcons.music_note_2,
            onTap: () {
              globalSetNavItemSelected("###SearchSingleMusicAggregator###");
              navigatorToPage(const MusicAggregatorSearchPage(
                isDesktop: true,
              ));
            },
            identity: '###SearchSingleMusicAggregator###',
          ),
          NavItem(
            title: '搜索歌单',
            icon: CupertinoIcons.music_albums,
            onTap: () {
              globalSetNavItemSelected("###SearchMusicList###");
              navigatorToPage(const PlaylistSearchPage(
                isDesktop: true,
              ));
            },
            identity: "###SearchMusicList###",
          )
        ]),
        NavGroup(
          title: '资料库',
          icon: CupertinoIcons.music_note,
          items: [
            NavItem(
              title: '所有歌单列表',
              icon: CupertinoIcons.music_albums,
              onTap: () {
                globalSetNavItemSelected("###AllPlaylistCollection###");
                navigatorToPage(
                  const DbPlaylistCollectionPage(
                    isDesktop: true,
                  ),
                );
              },
              identity: '###AllPlaylistCollection###',
            ),
            ...playlistCollections.map(
              (pc) {
                var title = pc.name;
                return NavItem(
                  title: title,
                  icon: CupertinoIcons.music_albums,
                  onTap: () {
                    globalSetNavItemSelected(
                        "###PlaylistCollection_${pc.id}###");
                    pc
                        .getPlaylistsFromDb()
                        .then((pls) => navigatorToPage(DbPlaylistGridPage(
                              isDesktop: true,
                              playlists: pls,
                              playlistCollection: pc,
                            )));
                  },
                  identity: "###PlaylistCollection_${pc.id}###",
                );
              },
            )
          ],
        ),
      ],
    );
  }
}

class NestedNavigator extends StatelessWidget {
  final Widget child;

  const NestedNavigator({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return CupertinoPageRoute(
          builder: (context) => child,
        );
      },
    );
  }
}

class NavListView extends StatefulWidget {
  final List<Widget> children;
  final String initSelectedItem;
  const NavListView({
    super.key,
    required this.children,
    required this.initSelectedItem,
  });

  @override
  NavListViewState createState() => NavListViewState();
}

class NavListViewState extends State<NavListView> {
  late String _selectedItem;

  void _setItemSelected(String title) {
    setState(() {
      _selectedItem = title;
    });
  }

  @override
  void initState() {
    _selectedItem = widget.initSelectedItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globalSetNavItemSelected = _setItemSelected;
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode
        ? const Color.fromARGB(255, 32, 32, 32)
        : const Color.fromARGB(255, 243, 243, 243);

    return Container(
      width: 200,
      color: backgroundColor,
      child: ListView.builder(
        itemCount: widget.children.length,
        itemBuilder: (context, index) {
          final item = widget.children[index];
          if (item is NavItem) {
            return NavItem(
              title: item.title,
              icon: item.icon,
              isSelected: _selectedItem == item.identity,
              onTap: () {
                _setItemSelected(item.title);
                item.onTap();
              },
              identity: '###Widget_$index###',
            );
          } else if (item is NavGroup) {
            return NavGroup(
              title: item.title,
              icon: item.icon,
              selectedSubItem: _selectedItem,
              items: item.items,
              onSubItemSelected: (title) {
                setState(() {
                  _selectedItem = title;
                });
              },
            );
          } else {
            throw Exception('Unexpected widget type in NavColumn');
          }
        },
      ),
    );
  }
}

class NavGroup extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? selectedSubItem;
  final List<NavItem> items;
  final ValueChanged<String>? onSubItemSelected;

  const NavGroup({
    super.key,
    required this.title,
    required this.icon,
    this.selectedSubItem,
    required this.items,
    this.onSubItemSelected,
  });

  @override
  NavGroupState createState() => NavGroupState();
}

class NavGroupState extends State<NavGroup> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: NavItem(
            title: widget.title,
            icon: widget.icon,
            isExpanded: _isExpanded,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            identity: '###NavGroup###',
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: Column(
            children: widget.items.map((e) {
              return Padding(
                padding: const EdgeInsets.only(left: 26, right: 10),
                child: NavItem(
                  title: e.title,
                  icon: e.icon,
                  isSelected: e.identity == widget.selectedSubItem,
                  onTap: () {
                    widget.onSubItemSelected?.call(e.title);
                    e.onTap();
                  },
                  identity: '###NavGroup_###',
                ),
              );
            }).toList(),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class NavItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final bool? isExpanded;
  final VoidCallback onTap;
  final String identity;

  const NavItem({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    this.isExpanded,
    required this.onTap,
    required this.identity,
  });

  @override
  NavItemState createState() => NavItemState();
}

class NavItemState extends State<NavItem> {
  bool _isHovered = false;

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.isSelected;
    bool isHovered = _isHovered;
    bool? isExpanded = widget.isExpanded;
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return GestureDetector(
      onTap: isSelected ? null : widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: Padding(
            padding: const EdgeInsets.only(top: 1, bottom: 1),
            child: Stack(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected || isHovered
                        ? (isDarkMode
                            ? const Color.fromARGB(255, 55, 55, 55)
                            : const Color.fromARGB(255, 234, 234, 234))
                        : (isDarkMode
                            ? const Color.fromARGB(255, 32, 32, 32)
                            : const Color.fromARGB(255, 243, 243, 243)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 2,
                          style: TextStyle(
                            color: isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                            overflow: TextOverflow.ellipsis,
                            fontSize: 13,
                          ).useSystemChineseFont(),
                        ),
                      ),
                      if (isExpanded != null) const Spacer(),
                      if (isExpanded != null)
                        Icon(
                          isExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          size: 15,
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 8,
                    bottom: 8,
                    child: Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 250, 35, 59),
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                  ),
              ],
            )),
      ),
    );
  }
}

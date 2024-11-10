import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

final PagingController<int, MusicAggregator> pagingControllerMusicAggregator =
    PagingController(firstPageKey: 1);
final PagingController<int, Playlist> pagingControllerPlaylist =
    PagingController(firstPageKey: 1);
final TextEditingController inputContentController = TextEditingController();

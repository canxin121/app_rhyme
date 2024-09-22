import 'package:app_rhyme/desktop/comps/music_agg_comp/music_agg_list_item.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/pages/local_music_agg_listview_page.dart';
import 'package:app_rhyme/desktop/pages/local_playlist_gridview_page.dart';
import 'package:app_rhyme/mobile/pages/local_music_aggregator_listview_page.dart';
import 'package:app_rhyme/mobile/pages/local_playlist_gridview_page.dart';

void refreshPlaylistGridViewPage() {
  globalDesktopMusicListGridPageRefreshFunction();
  globalDesktopMusicListNavColumnRefreshFunction();
  globalMobileMusicListGridPageRefreshFunction();
}

void refreshMusicAggregatorListViewPage() {
  globalDesktopMusicContainerListPageRefreshFunction();
  globalMobileMusicContainerListPageRefreshFunction();
  globalNotifyMusicContainerCacheUpdated();
}

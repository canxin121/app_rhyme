import 'package:app_rhyme/desktop/comps/music_container_comp/music_container_list_item.dart';
import 'package:app_rhyme/desktop/comps/navigation_column.dart';
import 'package:app_rhyme/desktop/pages/local_music_container_listview_page.dart';
import 'package:app_rhyme/desktop/pages/local_music_list_gridview_page.dart';
import 'package:app_rhyme/mobile/pages/local_music_container_listview_page.dart';
import 'package:app_rhyme/mobile/pages/local_music_list_gridview_page.dart';

void refreshMusicListGridViewPage() {
  globalDesktopMusicListGridPageRefreshFunction();
  globalDesktopMusicListNavColumnRefreshFunction();
  globalMobileMusicListGridPageRefreshFunction();
}

void refreshMusicContainerListViewPage() {
  globalDesktopMusicContainerListPageRefreshFunction();
  globalMobileMusicContainerListPageRefreshFunction();
  globalNotifyMusicContainerCacheUpdated();
}

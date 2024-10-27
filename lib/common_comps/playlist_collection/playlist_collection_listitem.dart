import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:app_rhyme/utils/colors.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class PlaylistCollectionItem extends StatelessWidget {
  final PlaylistCollection collection;
  final bool isDarkMode;

  const PlaylistCollectionItem({
    super.key,
    required this.collection,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collection.name,
            style: TextStyle(
              color: getTextColor(isDarkMode),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ).useSystemChineseFont(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

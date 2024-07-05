import 'package:app_rhyme/utils/quality_picker.dart';
import 'package:flutter/cupertino.dart';

Future<QualityOption?> showQualityOptionDialog(BuildContext context) async {
  return await showCupertinoModalPopup<QualityOption>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: const Text('选择音质选项'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.low);
            },
            child: Text(qualityOptionToString(QualityOption.low)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.medium);
            },
            child: Text(qualityOptionToString(QualityOption.medium)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.high);
            },
            child: Text(qualityOptionToString(QualityOption.high)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context, QualityOption.highest);
            },
            child: Text(qualityOptionToString(QualityOption.highest)),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context, null); // null when cancelled
          },
          child: const Text('取消'),
        ),
      );
    },
  );
}

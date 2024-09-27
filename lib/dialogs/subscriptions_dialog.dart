import 'package:app_rhyme/src/rust/api/music_api/mirror.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<List<PlayListSubscription>?> showEditSubscriptionsDialog({
  required BuildContext context,
  List<PlayListSubscription>? subscriptions,
}) {
  return showCupertinoDialog<List<PlayListSubscription>?>(
    context: context,
    builder: (BuildContext context) => EditSubscriptionsDialog(
      subscriptions: subscriptions,
    ),
  );
}

class EditSubscriptionsDialog extends StatefulWidget {
  final List<PlayListSubscription>? subscriptions;

  const EditSubscriptionsDialog({super.key, this.subscriptions});

  @override
  _EditSubscriptionsDialogState createState() =>
      _EditSubscriptionsDialogState();
}

class _EditSubscriptionsDialogState extends State<EditSubscriptionsDialog> {
  late List<PlayListSubscription> subscriptions;

  @override
  void initState() {
    super.initState();
    subscriptions = widget.subscriptions ?? [];
  }

  Future<String?> validateShare(String share) async {
    try {
      Playlist playlist = await Playlist.getFromShare(share: share);
      return '[${playlist.server}]${playlist.name}';
    } catch (e) {
      return null;
    }
  }

  void addSubscription() {
    setState(() {
      subscriptions.add(PlayListSubscription(name: '', share: ''));
    });
  }

  void removeSubscription(int index) {
    setState(() {
      subscriptions.removeAt(index);
    });
  }

  void updateSubscription(int index, String name, String share) {
    setState(() {
      subscriptions[index].name = name;
      subscriptions[index].share = share;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return CupertinoAlertDialog(
      title: Text(
        "编辑订阅",
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
      ),
      content: Column(
        children: [
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CupertinoTextField(
                                placeholder: "分享链接",
                                controller: TextEditingController(
                                    text: subscription.share),
                                onChanged: (value) async {
                                  if (value.isEmpty) {
                                    return;
                                  }
                                  final validatedName =
                                      await validateShare(value);
                                  if (validatedName != null) {
                                    updateSubscription(
                                        index, validatedName, value);
                                  } else {
                                    if (context.mounted) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) =>
                                            CupertinoAlertDialog(
                                          title: const Text("解析失败"),
                                          content: const Text("无效的分享链接"),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text("确定"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: TextStyle(
                                  color: isDarkMode
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                                placeholderStyle: TextStyle(
                                  color: isDarkMode
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? CupertinoColors.darkBackgroundGray
                                      : CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              CupertinoTextField(
                                placeholder: "名称",
                                controller: TextEditingController(
                                    text: subscription.name),
                                onChanged: (value) {
                                  updateSubscription(
                                      index, value, subscription.share);
                                },
                                style: TextStyle(
                                  color: isDarkMode
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                                placeholderStyle: TextStyle(
                                  color: isDarkMode
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? CupertinoColors.darkBackgroundGray
                                      : CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => removeSubscription(index),
                          child: const Icon(CupertinoIcons.delete, size: 24),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: addSubscription,
            child: const Icon(CupertinoIcons.add, size: 24),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(
            "取消",
            style: TextStyle(
              color: isDarkMode
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.activeBlue,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
        CupertinoDialogAction(
          child: Text(
            "确认",
            style: TextStyle(
              color: isDarkMode
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.activeBlue,
            ),
          ),
          onPressed: () {
            Navigator.pop(context,
                subscriptions.where((e) => e.share.isNotEmpty).toList());
          },
        ),
      ],
    );
  }
}

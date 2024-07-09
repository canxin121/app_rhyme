import 'package:app_rhyme/utils/chore.dart';
import 'package:app_rhyme/utils/global_vars.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/cupertino.dart';

class UserAgreementDialog extends StatelessWidget {
  const UserAgreementDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    return Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            child: CupertinoAlertDialog(
              title: Text(
                '用户协议与免责声明',
                style: TextStyle(
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ).useSystemChineseFont(),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                              color: isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                        children: <TextSpan>[
                          const TextSpan(
                              text: '欢迎使用AppRhyme。在您使用本应用之前，请仔细阅读以下用户协议。\n\n'),
                          TextSpan(
                              text: '1. 接受协议\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(
                              text:
                                  '通过访问和/或使用本应用，您确认您已阅读、理解并同意受本协议的约束。如果您不同意本协议的任何条款，请不要使用本应用。\n\n'),
                          TextSpan(
                              text: '2. 数据来源和版权\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(
                              text:
                                  '本应用提供的官方音乐数据来源于各官方音乐平台的公开数据库。本应用中可能出现的版权数据，包括但不限于图像、音频、名称等，其所有权归属于相应的官方音乐平台。用户必须在24小时内删除本应用中的任何版权数据，以避免侵权行为。\n\n'),
                          TextSpan(
                              text: '3. 用户责任\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(
                              text:
                                  '用户应自行负责制作和使用音源链接自己的音乐库。用户应确保其使用本应用的行为符合当地法律法规。用户应自行承担因使用本应用而可能产生的任何形式的损害赔偿责任。\n\n'),
                          TextSpan(
                              text: '4. 免责声明\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(
                              text:
                                  '本应用开发者不对用户使用本应用产生的直接、间接、特殊、偶然或结果性损害负责。本应用开发者不承担由于用户违反本协议或当地法律法规而产生的任何责任。\n\n'),
                          TextSpan(
                              text: '5. 使用限制\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(
                              text:
                                  '本应用完全开源且免费，不向用户收取任何费用。用户使用本应用时，必须遵守本协议和免责声明。\n\n'),
                          TextSpan(
                              text: '6. 贡献\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(
                              text:
                                  '本应用不接受任何形式的商业合作或捐赠。欢迎用户对本应用进行开源代码和UI设计的贡献，但贡献内容必须符合法律法规和本协议要求。\n\n'),
                          TextSpan(
                              text: '7. 授权协议\n',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)
                                      .useSystemChineseFont()),
                          const TextSpan(text: '本应用遵循MIT或Apache-2.0开源协议。\n\n'),
                          const TextSpan(text: '通过使用本应用，您表示您理解并同意上述条款。\n'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    '不同意',
                    style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.systemRed,
                    ).useSystemChineseFont(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    '同意',
                    style: TextStyle(
                      color: isDarkMode
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.activeBlue,
                    ).useSystemChineseFont(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            )));
  }
}

Future<void> showUserAgreement(BuildContext context) async {
  if (globalConfig.userAgreement) return;

  var result = await showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return const UserAgreementDialog();
    },
  );
  if (result == null || result == false) {
    await exitApp();
  } else {
    globalConfig.userAgreement = true;
    globalConfig.save();
  }
}

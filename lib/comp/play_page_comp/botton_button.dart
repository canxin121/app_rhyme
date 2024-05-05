import 'package:flutter/cupertino.dart';

// 定义一个枚举来表示当前的页面状态
enum PageState { home, lyric, list }

class BottomButton extends StatefulWidget {
  final VoidCallback onList;
  final VoidCallback onLyric;
  final EdgeInsetsGeometry padding;
  const BottomButton(
      {super.key,
      required this.onList,
      required this.onLyric,
      required this.padding});

  @override
  State<StatefulWidget> createState() => BottomButtonState();
}

class BottomButtonState extends State<BottomButton> {
  // 使用PageState枚举来跟踪当前的页面状态
  PageState currentPage = PageState.home;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CupertinoButton(
          padding: widget.padding,
          child: Icon(
            currentPage == PageState.lyric
                ? CupertinoIcons.quote_bubble_fill
                : CupertinoIcons.quote_bubble,
            color: CupertinoColors.white,
          ),
          onPressed: () {
            setState(() {
              currentPage = currentPage == PageState.lyric
                  ? PageState.home
                  : PageState.lyric;
            });
            widget.onLyric();
          },
        ),
        CupertinoButton(
          padding: widget.padding,
          child: Icon(
            // 根据当前页面状态来决定图标
            currentPage == PageState.list
                ? CupertinoIcons.square_list_fill
                : CupertinoIcons.square_list,
            color: CupertinoColors.white,
          ),
          onPressed: () {
            setState(() {
              // 如果当前在歌单页面，点击则回到主页
              // 否则，进入歌单页面
              currentPage = currentPage == PageState.list
                  ? PageState.home
                  : PageState.list;
            });
            widget.onList();
          },
        ),
      ],
    );
  }
}

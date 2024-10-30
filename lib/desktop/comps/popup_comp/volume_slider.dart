import 'dart:async';
import 'package:app_rhyme/utils/global_vars.dart';
// import 'package:better_cupertino_slider/better_cupertino_slider.dart';
import 'package:flutter/cupertino.dart';

class VolumeSlider extends StatefulWidget {
  final bool isDarkMode;

  const VolumeSlider({super.key, required this.isDarkMode});

  @override
  VolumeSliderState createState() => VolumeSliderState();
}

class VolumeSliderState extends State<VolumeSlider> {
  double _volume = 0.5;
  late StreamSubscription<double> volumeListener;

  @override
  void initState() {
    super.initState();
    volumeListener = globalAudioHandler.player.volumeStream.listen((volume) {
      setState(() {
        _volume = volume;
      });
    });
  }

  @override
  void dispose() {
    volumeListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color.fromARGB(255, 45, 45, 45)
              : const Color.fromARGB(255, 251, 251, 251),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: widget.isDarkMode
                ? const Color.fromARGB(255, 116, 116, 116)
                : const Color.fromARGB(255, 217, 217, 217),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.volume_mute,
                color: widget.isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black),
            Expanded(
              child: CupertinoSlider(
                min: 0.0,
                max: 1.0,
                value: _volume,
                // configure: BetterCupertinoSliderConfigure(
                //   trackHorizontalPadding: 8.0,
                //   trackHeight: 4.0,
                //   thumbRadius: 8.0,
                //   thumbPainter: (canvas, rect) {
                //     final RRect rrect = RRect.fromRectAndRadius(
                //       rect,
                //       Radius.circular(rect.shortestSide / 2.0),
                //     );
                //     canvas.drawRRect(rrect, Paint()..color = activeIconRed);
                //   },
                // ),
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                    globalAudioHandler.player.setVolume(value);
                  });
                },
              ),
            ),
            Icon(CupertinoIcons.volume_up,
                color: widget.isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black),
          ],
        ),
      ),
    );
  }
}

void showVolumeSlider(BuildContext context, Rect position, bool isDarkMode) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return _VolumeSliderOverlay(
        position: position,
        isDarkMode: isDarkMode,
        onRemove: () {
          overlayEntry.remove();
        },
      );
    },
  );

  overlay.insert(overlayEntry);
}

class _VolumeSliderOverlay extends StatefulWidget {
  final Rect position;
  final bool isDarkMode;
  final VoidCallback onRemove;

  const _VolumeSliderOverlay({
    required this.position,
    required this.isDarkMode,
    required this.onRemove,
  });

  @override
  _VolumeSliderOverlayState createState() => _VolumeSliderOverlayState();
}

class _VolumeSliderOverlayState extends State<_VolumeSliderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemFill.withOpacity(0.0),
      child: GestureDetector(
        onTap: widget.onRemove,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: () {
                if (widget.position.left < 900) {
                  return 800.0;
                }
                return widget.position.right - 20;
              }(),
              top: 8,
              child: GestureDetector(
                onTap: () {},
                child: FadeTransition(
                  opacity: _animation,
                  child: VolumeSlider(isDarkMode: widget.isDarkMode),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

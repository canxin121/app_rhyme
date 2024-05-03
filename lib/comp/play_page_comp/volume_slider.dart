// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
// import 'package:interactive_slider/interactive_slider.dart';

// class VolumeSlider extends StatefulWidget {
//   final double padding;
//   const VolumeSlider({super.key, this.padding = 5.0});

//   @override
//   State<StatefulWidget> createState() => VolumeSliderState();
// }

// class VolumeSliderState extends State<VolumeSlider> {
//   InteractiveSliderController volumeController = InteractiveSliderController(0);
//   late StreamSubscription<double> listen2;
//   @override
//   void initState() {
//     super.initState();
//     listen2 = FlutterVolumeController.addListener((value) {
//       try {
//         volumeController.value = value;
//       } catch (e) {
//         if (e.toString().contains("disposed")) {
//           listen2.cancel();
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(left: widget.padding, right: widget.padding),
//       child: InteractiveSlider(
//         controller: volumeController,
//         padding: const EdgeInsets.all(0),
//         onProgressUpdated: (value) {
//           FlutterVolumeController.setVolume(value);
//         },
//         startIcon: const Icon(CupertinoIcons.volume_down),
//         endIcon: const Icon(CupertinoIcons.volume_up),
//       ),
//     );
//   }
// }

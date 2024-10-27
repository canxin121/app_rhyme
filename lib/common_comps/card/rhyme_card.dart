import 'dart:math';
import 'package:aura_box/aura_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RandomAuraBox extends StatelessWidget {
  final Widget child;

  const RandomAuraBox({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final List<List<AuraSpot>> spotPresets = [
      [
        AuraSpot(
          color: CupertinoColors.systemPurple.withOpacity(0.7),
          radius: 500,
          alignment: const Alignment(0, 0.9),
          blurRadius: 50,
        ),
        AuraSpot(
          color: CupertinoColors.systemPink.withOpacity(0.4),
          radius: 400,
          alignment: const Alignment(-1.2, 1.2),
          blurRadius: 50,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.activeGreen.withOpacity(0.7),
          radius: 600,
          alignment: const Alignment(-1, 0),
          blurRadius: 400,
        ),
        AuraSpot(
          color: CupertinoColors.systemTeal.withOpacity(0.6),
          radius: 300,
          alignment: const Alignment(0.5, 0.8),
          blurRadius: 300,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.systemRed.withOpacity(0.8),
          radius: 300,
          alignment: Alignment.center,
          blurRadius: 200,
        ),
        AuraSpot(
          color: CupertinoColors.systemYellow.withOpacity(0.6),
          radius: 300,
          alignment: const Alignment(0, 1.4),
          blurRadius: 30,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.systemPink.withOpacity(0.7),
          radius: 500,
          alignment: const Alignment(-0.9, -0.9),
          blurRadius: 60,
        ),
        AuraSpot(
          color: CupertinoColors.systemOrange.withOpacity(0.5),
          radius: 300,
          alignment: const Alignment(0, 0.9),
          blurRadius: 60,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.systemBlue.withOpacity(0.7),
          radius: 500,
          alignment: const Alignment(-0.8, 0.8),
          blurRadius: 100,
        ),
        AuraSpot(
          color: CupertinoColors.systemIndigo.withOpacity(0.6),
          radius: 400,
          alignment: const Alignment(1.0, -1.0),
          blurRadius: 50,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.systemYellow.withOpacity(0.6),
          radius: 600,
          alignment: const Alignment(0.9, -0.5),
          blurRadius: 150,
        ),
        AuraSpot(
          color: CupertinoColors.systemPurple.withOpacity(0.6),
          radius: 400,
          alignment: const Alignment(-0.8, 0.5),
          blurRadius: 80,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.systemTeal.withOpacity(0.7),
          radius: 500,
          alignment: const Alignment(0.9, 0.0),
          blurRadius: 70,
        ),
        AuraSpot(
          color: CupertinoColors.systemPink.withOpacity(0.4),
          radius: 400,
          alignment: const Alignment(-0.9, -0.8),
          blurRadius: 100,
        ),
      ],
      [
        AuraSpot(
          color: CupertinoColors.systemOrange.withOpacity(0.6),
          radius: 500,
          alignment: const Alignment(0.0, -0.8),
          blurRadius: 90,
        ),
        AuraSpot(
          color: CupertinoColors.systemRed.withOpacity(0.4),
          radius: 350,
          alignment: const Alignment(0.8, 0.8),
          blurRadius: 50,
        ),
      ],
    ];

    final List<BoxDecoration> decorationPresets = [
      const BoxDecoration(
        color: Colors.transparent,
      ),
      BoxDecoration(
        color: CupertinoColors.extraLightBackgroundGray,
      ),
      BoxDecoration(
        color: CupertinoColors.systemFill.withOpacity(0.2),
      ),
      BoxDecoration(
        color: CupertinoColors.systemPink.withOpacity(0.1),
      ),
      BoxDecoration(
        color: CupertinoColors.systemGreen.withOpacity(0.1),
      ),
      BoxDecoration(
        color: CupertinoColors.systemYellow.withOpacity(0.1),
      ),
    ];

    final random = Random();

    final randomSpots = spotPresets[random.nextInt(spotPresets.length)];
    final randomDecoration =
        decorationPresets[random.nextInt(decorationPresets.length)];

    return AuraBox(
      decoration: randomDecoration,
      spots: randomSpots,
      child: child,
    );
  }
}

class RhymeCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClick;
  final VoidCallback? onSecondaryClick;

  const RhymeCard({
    super.key,
    required this.title,
    this.subtitle,
    this.onClick,
    this.onSecondaryClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onSecondaryTap: onSecondaryClick,
      child: RandomAuraBox(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: Text(
                  "AppRhyme",
                  style: TextStyle(fontSize: 10, color: CupertinoColors.white),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

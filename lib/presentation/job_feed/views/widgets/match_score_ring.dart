import 'package:flutter/material.dart';

class MatchScoreRing extends StatelessWidget {
  final int score;
  final double size;

  const MatchScoreRing({super.key, required this.score, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color ringColor = score >= 90
        ? colorScheme.tertiary
        : (score >= 80 ? colorScheme.primary : colorScheme.secondary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100.0,
            strokeWidth: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(ringColor),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'MATCH',
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w700,
                  color: ringColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

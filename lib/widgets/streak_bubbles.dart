import 'package:flutter/material.dart';
import '../config/theme.dart';

class StreakBubbles extends StatelessWidget {
  final int streakCount;

  const StreakBubbles({
    super.key,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which bubbles are filled.
    // For visual demonstration, we show up to 7 bubbles.
    // We fill them based on streakCount. If streakCount is 12, we can show a full row of active days.
    // Let's say: the last 5 days are filled, or it wraps around. Let's just fill based on (streakCount % 7) or show the active week.
    final filledCount = streakCount > 0 ? (streakCount % 7 == 0 ? 7 : streakCount % 7) : 0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (index) {
        final isFilled = index < filledCount;
        return Container(
          width: 16.0,
          height: 16.0,
          margin: const EdgeInsets.only(left: 6.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.orange : Colors.transparent,
            border: Border.all(
              color: isFilled ? AppColors.orange : Colors.white.withOpacity( 0.35),
              width: 2.0,
            ),
          ),
        );
      }),
    );
  }
}

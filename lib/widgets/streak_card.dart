import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'streak_bubbles.dart';

class StreakCard extends StatelessWidget {
  final int streakCount;
  final VoidCallback? onTapViewCalendar;

  const StreakCard({
    super.key,
    required this.streakCount,
    this.onTapViewCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current streak',
                  style: TextStyle(
                    color: Colors.white.withOpacity( 0.7),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2.0),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: '$streakCount '),
                      const TextSpan(
                        text: 'days 🔥',
                        style: TextStyle(color: AppColors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StreakBubbles(streakCount: streakCount),
        ],
      ),
    );
  }
}

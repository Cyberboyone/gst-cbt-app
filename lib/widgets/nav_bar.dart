import 'package:flutter/material.dart';
import '../config/theme.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.navy.withValues(alpha: 0.06),
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 14.0,
        bottom: MediaQuery.of(context).padding.bottom + 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, '🏠', 'Home'),
          _buildNavItem(1, '📝', 'Practice'),
          _buildNavItem(2, '📥', 'Materials'),
          _buildNavItem(3, '🏆', 'Ranks'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label) {
    final isActive = currentIndex == index;
    final activeColor = AppColors.orange;
    final inactiveColor = const Color(0xFFAEB6C4);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 16.0,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 10.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

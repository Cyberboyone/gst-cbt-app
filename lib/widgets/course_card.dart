import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final double progressPercentage;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.progressPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pctText = '${(progressPercentage * 100).toInt()}% complete';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14.0),
        decoration: BoxDecoration(
          color: course.color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative circular overlay in top-right
            Positioned(
              right: -18.0,
              top: -18.0,
              child: Container(
                width: 70.0,
                height: 70.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),
            
            // Card Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      course.icon,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  
                  // Info column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.code,
                          style: const TextStyle(
                            color: AppColors.inkSoft,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          course.name,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        
                        // Progress bar background
                        Container(
                          height: 5.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progressPercentage.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          pctText,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  
                  // Go Button (arrow button)
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.navy,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

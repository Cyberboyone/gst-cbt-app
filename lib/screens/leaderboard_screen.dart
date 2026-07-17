import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../widgets/powered_by_footer.dart';

class LeaderboardScreen extends StatelessWidget {
  final bool isEmbedded;

  const LeaderboardScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final profile = profileProvider.profile;

    final body = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
      children: [
        if (profile != null) ...[
          // User Card
          Container(
            decoration: const BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: AppColors.orange,
                  child: Text(
                    profile.nickname.isNotEmpty ? profile.nickname[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 18.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.nickname,
                        style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Local Rank: #1 (Top Performer)',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${profile.xp}',
                      style: const TextStyle(color: AppColors.orange, fontSize: 24.0, fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      'Total XP',
                      style: TextStyle(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
        ],

        const Text(
          'Your Best High Scores',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.navy),
        ),
        const SizedBox(height: 12.0),

        // High scores list per course
        ...courseProvider.courses.map((course) {
          final progress = courseProvider.getProgressForCourse(course.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: course.color,
                child: Text(course.icon),
              ),
              title: Text(course.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
              subtitle: Text(
                'Attempted: ${progress.questionsAttempted} qns',
                style: const TextStyle(fontSize: 12.0),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: progress.bestScore >= 70 
                      ? AppColors.mint 
                      : (progress.bestScore >= 45 ? AppColors.sky : AppColors.peach),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  '${progress.bestScore}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20.0),
        
        // Leaderboard Offline Mode Explanation
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.lavender,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 24.0)),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  'Leaderboard rankings are compiled from your local device practice records. Connect online to sync and view national leaderboards when available.',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 12.0,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const PoweredByFooter(),
      ],
    );

    if (isEmbedded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ranks & Standings', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../models/course.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/streak_card.dart';
import '../widgets/course_card.dart';
import '../widgets/nav_bar.dart';
import '../widgets/powered_by_footer.dart';

import 'leaderboard_screen.dart';
import 'materials_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildActiveTab(),
      bottomNavigationBar: NavBar(
        currentIndex: _currentTab,
        onTap: _onTabChanged,
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_currentTab) {
      case 0:
        return const _HomeTab();
      case 1:
        return const _PracticeTab();
      case 2:
        return const MaterialsScreen(isEmbedded: true);
      case 3:
        return const LeaderboardScreen(isEmbedded: true);
      default:
        return const _HomeTab();
    }
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);

    final profile = profileProvider.profile;
    if (profile == null) return const SizedBox.shrink();

    final filteredCourses = courseProvider.courses;
    final questionsDone = profile.questionsToday;
    final dailyGoal = AppConstants.dailyGoalQuestions;
    final todayGoalPct = (questionsDone / dailyGoal).clamp(0.0, 1.0);

    final levelInfo = profileProvider.levelInfo;
    final levelProgress = profileProvider.levelProgress;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46.0,
                        height: 46.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.orange, Color(0xFFFFB877)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profile.nickname.isNotEmpty ? profile.nickname[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              color: AppColors.inkSoft,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            'Hello, ${profile.nickname}',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 19.0,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showAnnouncementsDialog(context),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cardShadow,
                                blurRadius: 12.0,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('🔔', style: TextStyle(fontSize: 16.0)),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 7.0,
                            height: 7.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.orange,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18.0),

              // Level Card
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.navy, Color(0xFF1A3A6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 16.0, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(levelInfo['icon'], style: const TextStyle(fontSize: 32.0)),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                levelInfo['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  '${profile.xp} XP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: LinearProgressIndicator(
                              value: levelProgress,
                              color: AppColors.orange,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              minHeight: 6.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${profile.xp}/${profileProvider.nextLevelXp} XP to next level',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Today's Goal Ring
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: const [
                    BoxShadow(color: AppColors.cardShadow, blurRadius: 16.0, offset: Offset(0, 6)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                child: Row(
                  children: [
                    ProgressRing(
                      percentage: todayGoalPct == 0.0 ? 0.05 : todayGoalPct,
                      size: 46.0,
                      strokeWidth: 5.0,
                      child: Text(
                        '${(todayGoalPct * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s goal',
                            style: TextStyle(
                              color: AppColors.inkSoft,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            '$questionsDone of $dailyGoal questions done',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (todayGoalPct >= 1.0)
                      const Text('✅', style: TextStyle(fontSize: 24.0)),
                  ],
                ),
              ),
              const SizedBox(height: 26.0),

              // Streak Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  const Text(
                    'Your Streak',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                  GestureDetector(
                    onTap: () => _showStreakDetails(context, profile.streakCount, profile.streakFreezeActive),
                    child: const Text(
                      'View info',
                      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: AppColors.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              StreakCard(streakCount: profile.streakCount),
              const SizedBox(height: 26.0),

              // Courses
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  const Text(
                    'Courses',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                    child: const Text(
                      'About App',
                      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w700, color: AppColors.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  final completion = courseProvider.getCompletionPercentage(course.id);
                  return CourseCard(
                    course: course,
                    progressPercentage: completion,
                    onTap: () => _startCourseQuiz(context, course),
                  );
                },
              ),

              const PoweredByFooter(),
            ],
          ),
        ),
      ),
    );
  }

  void _startCourseQuiz(BuildContext context, Course course) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.startSession(course: course, mode: QuizMode.practice).then((_) {
      Navigator.pushNamed(context, AppRoutes.practice);
    });
  }

  void _showStreakDetails(BuildContext context, int streakCount, bool hasFreeze) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Streak System', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
        content: Text(
          'You have a streak of $streakCount days!\n\n'
          'Answer at least 1 question every day to maintain your streak. '
          '${hasFreeze ? "You have a streak freeze active, which will protect your streak for 1 missed day." : "Buy a streak freeze from the Shop to protect your streak."}\n\n'
          'Streak multipliers:\n'
          '3-6 days: 1.2x XP\n'
          '7-13 days: 1.5x XP\n'
          '14-29 days: 2x XP\n'
          '30+ days: 3x XP',
          style: const TextStyle(color: AppColors.inkSoft, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAnnouncementsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Announcements', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
        content: const Text(
          'Welcome to the GST CBT Prep App!\n\nAll features are 100% offline. Study materials can be downloaded from the Materials tab when connected to the internet.',
          style: TextStyle(color: AppColors.inkSoft, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _PracticeTab extends StatelessWidget {
  const _PracticeTab();

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice & Exam Center', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
          children: [
            const Text(
              'Select a course to begin your study session. You can practice untimed with instant feedback, or take a timed exam simulation.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 24.0),

            _buildModeCard(
              context,
              title: 'Untimed Practice Mode',
              subtitle: 'Learn at your own pace with instant correct answer explanations.',
              icon: '📝',
              color: AppColors.sky,
              onTap: () => _chooseCourseForSession(context, QuizMode.practice),
            ),
            const SizedBox(height: 16.0),

            _buildModeCard(
              context,
              title: 'Timed Exam Simulation',
              subtitle: 'Simulate the real computer-based test with time limits.',
              icon: '⏱️',
              color: AppColors.peach,
              onTap: () => _chooseCourseForSession(context, QuizMode.exam),
            ),
            const SizedBox(height: 24.0),

            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            const SizedBox(height: 12.0),

            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    'Coins Balance',
                    '${profileProvider.profile?.coins ?? 0} 🪙',
                    AppColors.mint,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _buildStatTile(
                    'XP Earned',
                    '${profileProvider.profile?.xp ?? 0} XP',
                    AppColors.lavender,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Shop button
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.shop),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('🛒', style: TextStyle(fontSize: 24.0)),
                    const SizedBox(width: 12.0),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Coin Shop', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 14.0)),
                          SizedBox(height: 2.0),
                          Text('Spend coins on hints and streak freezes', style: TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: AppColors.navy.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            ),

            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.0)),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32.0)),
            const SizedBox(width: 18.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.navy)),
                  const SizedBox(height: 4.0),
                  Text(subtitle, style: TextStyle(fontSize: 12.0, color: AppColors.navy.withValues(alpha: 0.7), height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.navy, size: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16.0)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6.0),
          Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 18.0, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _chooseCourseForSession(BuildContext context, QuizMode mode) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    final filtered = courseProvider.courses;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
      backgroundColor: AppColors.cream,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mode == QuizMode.practice ? 'Select Practice Course' : 'Select Exam Course',
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            const SizedBox(height: 18.0),
            ...filtered.map((course) => Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: course.color, child: Text(course.icon)),
                    title: Text(course.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                    subtitle: Text(course.name, style: const TextStyle(fontSize: 12.0)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    onTap: () {
                      Navigator.pop(context);
                      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                      quizProvider.startSession(course: course, mode: mode).then((_) {
                        if (mode == QuizMode.practice) {
                          Navigator.pushNamed(context, AppRoutes.practice);
                        } else {
                          Navigator.pushNamed(context, AppRoutes.exam);
                        }
                      });
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/powered_by_footer.dart';

class ResultScreen extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswers;
  final int scorePercentage;
  final int timeSpentSeconds;
  final String courseCode;
  final String courseId;

  const ResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.timeSpentSeconds,
    required this.courseCode,
    required this.courseId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  bool _rewardsSaved = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
    _playCompletionSound();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveRewardsAndStats();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCompletionSound() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.settings.soundOn) return;
    final isPassed = widget.scorePercentage >= AppConstants.passingScorePercentage;
    final isPerfect = widget.scorePercentage == 100;
    if (isPerfect) {
      await _audioPlayer.play(AssetSource('sounds/complete.wav'));
    } else if (isPassed) {
      await _audioPlayer.play(AssetSource('sounds/correct.wav'));
    }
  }

  void _saveRewardsAndStats() {
    if (_rewardsSaved) return;
    _rewardsSaved = true;

    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final courses = Provider.of<CourseProvider>(context, listen: false);

    final previousLevel = AppConstants.getLevelForXp(profile.profile?.xp ?? 0);

    int xpBonus = 0;
    int coinBonus = 0;

    if (widget.scorePercentage == 100) {
      xpBonus = 100;
      coinBonus = 15;
    } else if (widget.scorePercentage >= 45) {
      xpBonus = 50;
      coinBonus = 5;
    }

    final totalXp = (widget.correctAnswers * 10) + xpBonus;
    final totalCoins = (widget.correctAnswers * 1) + coinBonus;

    profile.recordSessionStats(
      correct: widget.correctAnswers,
      attempted: widget.totalQuestions,
      coins: totalCoins,
    );
    profile.updateXP(totalXp);
    profile.addCoins(totalCoins);
    profile.updateStreak();

    courses.updateCourseProgress(
      courseId: widget.courseId,
      additionalAttempted: widget.totalQuestions,
      additionalCorrect: widget.correctAnswers,
      newExamScore: widget.scorePercentage,
    );

    final coursesPracticed = courses.courses
        .where((c) => courses.getProgressForCourse(c.id).questionsAttempted > 0)
        .map((c) => c.id)
        .toList();

    final currentExamPerfect = widget.scorePercentage == 100;
    final allCoursesPerfect = courses.courses.every((c) => courses.getProgressForCourse(c.id).bestScore >= 100 && courses.getProgressForCourse(c.id).bestScore > 0);
    final passedExamCount = courses.courses.where((c) => courses.getProgressForCourse(c.id).bestScore >= 45).length;

    final newBadges = profile.checkBadges(
      coursesPracticed: coursesPracticed,
      currentExamPerfect: currentExamPerfect,
      allCoursesPerfect: allCoursesPerfect,
      passedExamCount: passedExamCount,
    );

    final newLevel = AppConstants.getLevelForXp(profile.profile?.xp ?? 0);

    if (newBadges.isNotEmpty || newLevel > previousLevel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRewardsDialog(context, newBadges, newLevel > previousLevel, newLevel, profile);
      });
    }
  }

  void _showRewardsDialog(BuildContext context, List<String> newBadges, bool leveledUp, int newLevel, ProfileProvider profile) {
    final levelInfo = AppConstants.levels[newLevel];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        backgroundColor: AppColors.cream,
        title: Column(
          children: [
            Text(leveledUp ? '🎉' : '🏅', style: const TextStyle(fontSize: 48.0)),
            const SizedBox(height: 8.0),
            Text(
              leveledUp ? 'Level Up!' : 'Achievement Unlocked!',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 22.0),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leveledUp) ...[
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(levelInfo['icon'], style: const TextStyle(fontSize: 24.0)),
                    const SizedBox(width: 8.0),
                    Text(
                      'You are now a ${levelInfo['title']}!',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
            ],
            if (newBadges.isNotEmpty) ...[
              const Text('New Badges:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 8.0),
              ...newBadges.map((id) {
                final badge = AppConstants.badgeCatalog.firstWhere(
                  (b) => b['id'] == id,
                  orElse: () => {'name': id, 'icon': '🏆'},
                );
                return Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Text(badge['icon']!, style: const TextStyle(fontSize: 20.0)),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(badge['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13.0)),
                            Text(badge['description']!, style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                profile.clearRecentBadges();
                if (leveledUp) profile.clearLevelUp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _shareResults(String nickname) {
    final msg = 'Hey! I just completed the ${widget.courseCode} Exam Simulation on the CBT App.\n'
        'Score: ${widget.scorePercentage}% (${widget.correctAnswers}/${widget.totalQuestions} correct)\n'
        'Time: ${_formatTime(widget.timeSpentSeconds)}\n'
        'Download the app to test your prep!';
    Share.share(msg);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final nickname = profile?.nickname ?? 'Student';
    final isPassed = widget.scorePercentage >= AppConstants.passingScorePercentage;
    final isPerfect = widget.scorePercentage == 100;

    final streakMultiplier = AppConstants.getStreakMultiplier(profile?.streakCount ?? 0);
    int displayXpBonus = isPerfect ? 100 : (isPassed ? 50 : 0);
    int displayCoinBonus = isPerfect ? 15 : (isPassed ? 5 : 0);
    final earnedXp = ((widget.correctAnswers * 10 + displayXpBonus) * streakMultiplier).round();
    final earnedCoins = (widget.correctAnswers * 1) + displayCoinBonus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          children: [
            const SizedBox(height: 12.0),

            // Animated Score ring
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ProgressRing(
                  percentage: widget.scorePercentage / 100.0,
                  size: 130.0,
                  strokeWidth: 12.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.scorePercentage}%',
                        style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                      Text(
                        isPerfect ? 'PERFECT!' : (isPassed ? 'PASSED' : 'RE-TAKE'),
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: isPerfect ? AppColors.accent : (isPassed ? Colors.green : Colors.red),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Score Description Banner
            Container(
              decoration: BoxDecoration(
                color: isPerfect ? AppColors.lavender : (isPassed ? AppColors.mint : AppColors.peach),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(isPerfect ? '💯' : (isPassed ? '🏆' : '📚'), style: const TextStyle(fontSize: 24.0)),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPerfect ? 'Outstanding! Perfect Score!' : (isPassed ? 'Credit Accomplished!' : 'Keep Practicing!'),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          isPerfect
                              ? 'Flawless performance! You aced every single question!'
                              : (isPassed ? 'Congratulations! You performed above the credit cut-off of 45%.' : 'The passing score is 45%. Take another review practice.'),
                          style: const TextStyle(fontSize: 12.0, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            const Text('Exam Summary', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: AppColors.clayShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildStatRow('Course Subject', widget.courseCode),
                  const Divider(height: 1),
                  _buildStatRow('Questions Attempted', '${widget.totalQuestions}'),
                  const Divider(height: 1),
                  _buildStatRow('Correct Answers', '${widget.correctAnswers}'),
                  const Divider(height: 1),
                  _buildStatRow('Time Spent', _formatTime(widget.timeSpentSeconds)),
                  if (streakMultiplier > 1.0) ...[
                    const Divider(height: 1),
                    _buildStatRow('Streak Multiplier', 'x${streakMultiplier.toStringAsFixed(1)}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            const Text('Rewards Unlocked', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(14.0)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('XP Earned', style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('+$earnedXp XP', style: const TextStyle(color: AppColors.primary, fontSize: 18.0, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14.0)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Coins Reward', style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('+$earnedCoins 🪙', style: const TextStyle(color: AppColors.primary, fontSize: 18.0, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36.0),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareResults(nickname),
                      icon: const Icon(Icons.share_rounded, color: AppColors.accent, size: 18),
                      label: const Text('Share Result', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        elevation: 0,
                      ),
                      child: const Text('Return Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),

            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13.5, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 13.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

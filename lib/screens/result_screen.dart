import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/powered_by_footer.dart';
import '../utils/pdf_export.dart';

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

class _ResultScreenState extends State<ResultScreen> {
  bool _rewardsSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveRewardsAndStats();
    });
  }

  void _saveRewardsAndStats() {
    if (_rewardsSaved) return;
    _rewardsSaved = true;

    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final courses = Provider.of<CourseProvider>(context, listen: false);

    // Calculate dynamic XP and Coins rewards
    // 10 XP per correct answer. 50 XP bonus for passing (>=45%). 100 XP bonus for a perfect score (100%).
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

    // Save locally
    profile.updateXP(totalXp);
    profile.addCoins(totalCoins);
    profile.updateStreak();

    courses.updateCourseProgress(
      courseId: widget.courseId,
      additionalAttempted: widget.totalQuestions,
      additionalCorrect: widget.correctAnswers,
      newExamScore: widget.scorePercentage,
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _exportPdf(BuildContext context, String nickname) {
    PdfExportHelper.exportResultPdf(
      courseCode: widget.courseCode,
      scorePercentage: widget.scorePercentage,
      correctAnswers: widget.correctAnswers,
      totalQuestions: widget.totalQuestions,
      timeSpentSeconds: widget.timeSpentSeconds,
      studentName: nickname,
    );
  }

  void _shareResults(String nickname) {
    final msg = 'Hey! I just completed the ${widget.courseCode} Exam Simulation on the GST CBT Prep App.\n'
        'Score: ${widget.scorePercentage}% (${widget.correctAnswers}/${widget.totalQuestions} correct)\n'
        'Time: ${_formatTime(widget.timeSpentSeconds)}\n'
        'Download the app to test your prep!';
    
    Share.share(msg);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final nickname = profile?.nickname ?? 'Student';
    final isPassed = widget.scorePercentage >= 45;

    // Rewards calculation for display
    int displayXpBonus = widget.scorePercentage == 100 ? 100 : (widget.scorePercentage >= 45 ? 50 : 0);
    int displayCoinBonus = widget.scorePercentage == 100 ? 15 : (widget.scorePercentage >= 45 ? 5 : 0);
    final earnedXp = (widget.correctAnswers * 10) + displayXpBonus;
    final earnedCoins = (widget.correctAnswers * 1) + displayCoinBonus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Result', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
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
            
            // Large Score ring
            Center(
              child: ProgressRing(
                percentage: widget.scorePercentage / 100.0,
                size: 130.0,
                strokeWidth: 12.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.scorePercentage}%',
                      style: const TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.black,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      isPassed ? 'PASSED' : 'RE-TAKE',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            
            // Score Description Banner
            Container(
              decoration: BoxDecoration(
                color: isPassed ? AppColors.mint : AppColors.peach,
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    isPassed ? '🏆' : '📚',
                    style: const TextStyle(fontSize: 24.0),
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPassed ? 'Credit Accomplished!' : 'Keep Practicing!',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          isPassed 
                              ? 'Congratulations! You performed above the credit cut-off of 45%.'
                              : 'The university GST passing score is 45%. Take another review practice.',
                          style: const TextStyle(fontSize: 12.0, color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Performance statistics table
            const Text(
              'Exam Summary',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const [
                  BoxShadow(color: AppColors.cardShadow, blurRadius: 10.0, offset: Offset(0, 4))
                ],
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
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Rewards
            const Text(
              'Rewards Unlocked',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.lavender,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('XP Earned', style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('+$earnedXp XP', style: const TextStyle(color: AppColors.navy, fontSize: 18.0, fontWeight: FontWeight.black)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.sky,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Coins Reward', style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('+$earnedCoins 🪙', style: const TextStyle(color: AppColors.navy, fontSize: 18.0, fontWeight: FontWeight.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36.0),

            // Actions panel
            SizedBox(
              height: 50.0,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _exportPdf(context, nickname),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Export Transcript (PDF)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareResults(nickname),
                      icon: const Icon(Icons.share_rounded, color: AppColors.orange, size: 18),
                      label: const Text('Share Result', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.orange, width: 1.5),
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
                      onPressed: () {
                        // Reset session and return to home route
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
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
          Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 13.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

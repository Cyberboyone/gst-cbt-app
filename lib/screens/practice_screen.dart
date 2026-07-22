import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/quiz_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../providers/settings_provider.dart';
import '../services/ad_service.dart';
import 'practice_result_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final activeCourse = quizProvider.activeCourse;
    final questions = quizProvider.questions;
    final currentQ = quizProvider.currentQuestion;

    if (activeCourse == null || quizProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (questions.isEmpty || currentQ == null) {
      return Scaffold(
        appBar: AppBar(title: Text(activeCourse.code)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📚', style: TextStyle(fontSize: 48.0)),
                const SizedBox(height: 18.0),
                const Text('No questions available', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 8.0),
                const Text('Connect to the internet to fetch questions, or try again later.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.inkSoft)),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isLast = quizProvider.currentIndex == questions.length - 1;
    final progressVal = (quizProvider.currentIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(activeCourse.code, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.foreground, fontSize: 16.0)),
            Text(activeCourse.name, style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.w500)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primary),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          if (quizProvider.currentCombo >= 3)
            Container(
              margin: const EdgeInsets.only(right: 4.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12.0)),
                  const SizedBox(width: 2.0),
                  Text(
                    'x${quizProvider.currentCombo}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(
              settingsProvider.settings.soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              final newSoundOn = !settingsProvider.settings.soundOn;
              settingsProvider.toggleSound(newSoundOn);
              quizProvider.setSoundOn(newSoundOn);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress and combo indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${quizProvider.currentIndex + 1} of ${questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.foreground, fontSize: 12.0),
                      ),
                      Text(
                        'Correct: ${quizProvider.sessionCorrectAnswers}/${quizProvider.sessionAttempted}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.correct, fontSize: 12.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: progressVal,
                    color: AppColors.primary,
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  // Combo bar
                  if (quizProvider.sessionBestCombo >= 3) ...[
                    const SizedBox(height: 6.0),
                    Row(
                      children: [
                        Text(
                          'Best combo: ${quizProvider.sessionBestCombo} 🔥',
                          style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.w700, color: AppColors.accent),
                        ),
                        if (quizProvider.currentCombo >= 3) ...[
                          const SizedBox(width: 8.0),
                          Text(
                            '(${(AppConstants.getComboMultiplier(quizProvider.currentCombo) * 100).toInt()}% bonus)',
                            style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w600, color: AppColors.primary.withOpacity( 0.6)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Question body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: AppColors.clayShadow,
                      ),
                      padding: const EdgeInsets.all(22.0),
                      child: Text(
                        currentQ!.text,
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, color: AppColors.foreground, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    ...List.generate(currentQ.options.length, (idx) {
                      final optionText = currentQ.options[idx];
                      final isEliminated = quizProvider.eliminatedOptions.contains(idx);
                      return _buildOptionTile(context, quizProvider, idx, optionText, isEliminated);
                    }),

                    if (quizProvider.isAnswerChecked) ...[
                      const SizedBox(height: 20.0),
                      _buildExplanationBox(currentQ.explanation),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                children: [
                  // Hint button
                  if (!quizProvider.isAnswerChecked && !quizProvider.hintUsedThisQuestion)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40.0,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final profile = Provider.of<ProfileProvider>(context, listen: false);
                            final adsRemoved = Provider.of<SettingsProvider>(context, listen: false).settings.adsRemoved;
                            if (profile.profile!.coins >= AppConstants.coinsForHint) {
                              _showHintConfirmDialog(context, profile, quizProvider, adsRemoved: adsRemoved);
                            } else if (!adsRemoved) {
                              _showRewardedHintDialog(context, quizProvider);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Not enough coins for a hint! Need 5 coins.')),
                              );
                            }
                          },
                          icon: const Text('💡', style: TextStyle(fontSize: 14.0)),
                          label: Text('Use Hint (${AppConstants.coinsForHint} coins)', style: const TextStyle(fontSize: 12.0)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            foregroundColor: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 56.0,
                    child: ElevatedButton(
                      onPressed: quizProvider.selectedOptionIndex == null
                          ? null
                          : () => _handleAction(context, quizProvider, isLast),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        elevation: 0,
                      ),
                      child: Text(
                        quizProvider.isAnswerChecked ? (isLast ? 'Finish' : 'Next Question') : 'Check Answer',
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
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

  void _showHintConfirmDialog(BuildContext context, ProfileProvider profile, QuizProvider quiz, {bool adsRemoved = false}) {
    final optionCount = quiz.currentQuestion?.options.length ?? 4;
    final eliminateCount = ((optionCount - 1) / 2).ceil();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Use Hint?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: Text('This will eliminate $eliminateCount wrong answer(s) for ${AppConstants.coinsForHint} coins.', style: const TextStyle(color: AppColors.inkSoft)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.primary))),
          if (!adsRemoved)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showRewardedHintDialog(context, quiz);
              },
              child: const Text('Watch Ad', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final spent = await profile.spendCoins(AppConstants.coinsForHint);
              if (spent) {
                quiz.useHint();
              }
            },
            child: const Text('Use Hint', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRewardedHintDialog(BuildContext context, QuizProvider quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Watch an Ad?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: const Text('Watch a short video ad to get a free hint (no coins needed!).', style: TextStyle(color: AppColors.inkSoft)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.primary))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AdService.instance.showRewarded(
                onRewarded: () {
                  quiz.useHint();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Free hint granted!'), backgroundColor: Colors.green),
                    );
                  }
                },
                onFailed: () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ad not available. Try again later.')),
                    );
                  }
                },
              );
            },
            child: const Text('Watch Ad', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, QuizProvider quiz, int idx, String text, bool isEliminated) {
    final isSelected = quiz.selectedOptionIndex == idx;
    final isChecked = quiz.isAnswerChecked;
    final correctIdx = quiz.currentQuestion!.correctIndex;

    Color tileColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.foreground;

    if (isEliminated && !isChecked) {
      tileColor = Colors.grey.withOpacity( 0.1);
      textColor = Colors.grey;
    } else if (isChecked) {
      if (idx == correctIdx) {
        tileColor = const Color(0xFFDFF5E4);
        borderColor = const Color(0xFF2E7D32).withOpacity( 0.3);
      } else if (isSelected) {
        tileColor = const Color(0xFFFFE8D6);
        borderColor = Colors.red.withOpacity( 0.3);
      }
    } else if (isSelected) {
      borderColor = AppColors.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: AppColors.clayShadowSmall,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        onTap: isEliminated && !isChecked ? null : () => quiz.selectOption(idx),
        leading: CircleAvatar(
          radius: 14.0,
          backgroundColor: isSelected ? AppColors.accent : AppColors.foreground.withOpacity( 0.08),
          child: Text(
            String.fromCharCode(65 + idx),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.foreground,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
        title: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14.0)),
      ),
    );
  }

  Widget _buildExplanationBox(String explanation) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.primary.withOpacity( 0.08)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 16.0)),
              SizedBox(width: 8.0),
              Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13.0)),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(explanation, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5, height: 1.45)),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, QuizProvider quiz, bool isLast) {
    if (!quiz.isAnswerChecked) {
      quiz.checkAnswer();
    } else if (!isLast) {
      quiz.nextQuestion();
    } else {
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      final courses = Provider.of<CourseProvider>(context, listen: false);

      final streakMultiplier = AppConstants.getStreakMultiplier(profile.profile?.streakCount ?? 0);
      final comboMultiplier = AppConstants.getComboMultiplier(quiz.sessionBestCombo);
      final totalMultiplier = streakMultiplier * comboMultiplier;

      final baseXp = quiz.sessionCorrectAnswers * 10;
      final xpEarned = (baseXp * totalMultiplier).round();
      final coinsEarned = quiz.sessionCorrectAnswers;

      profile.recordCombo(quiz.sessionBestCombo);
      profile.recordSessionStats(
        correct: quiz.sessionCorrectAnswers,
        attempted: quiz.sessionAttempted,
        coins: coinsEarned,
      );
      profile.updateXP(xpEarned);
      profile.addCoins(coinsEarned);
      profile.updateStreak();

      courses.updateCourseProgress(
        courseId: quiz.activeCourse!.id,
        additionalAttempted: quiz.sessionAttempted,
        additionalCorrect: quiz.sessionCorrectAnswers,
      );

      // Check daily goal bonus
      final questionsNow = profile.profile?.questionsToday ?? 0;
      if (questionsNow >= AppConstants.dailyGoalQuestions && questionsNow - quiz.sessionAttempted < AppConstants.dailyGoalQuestions) {
        profile.addCoins(2);
      }

      final newBadges = profile.checkBadges(
        coursesPracticed: courses.courses
            .where((c) => courses.getProgressForCourse(c.id).questionsAttempted > 0)
            .map((c) => c.id)
            .toList(),
      );

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PracticeResultScreen(
            totalQuestions: quiz.sessionAttempted,
            correctAnswers: quiz.sessionCorrectAnswers,
            courseCode: quiz.activeCourse!.code,
            courseId: quiz.activeCourse!.id,
            bestCombo: quiz.sessionBestCombo,
            xpEarned: xpEarned,
            coinsEarned: coinsEarned,
            multiplier: totalMultiplier,
          ),
        ),
      );
    }
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Exit Session?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        content: const Text('Your current practice score will not be saved if you exit now.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.primary))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/quiz_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../providers/settings_provider.dart';

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
        body: Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );
    }

    if (questions.isEmpty) {
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
                const Text(
                  'No questions available',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.navy),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Connect to the internet to fetch questions from GitHub, or try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white),
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

    // Sync sound settings to quiz provider
    quizProvider.setSoundOn(settingsProvider.settings.soundOn);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              activeCourse.code,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy, fontSize: 16.0),
            ),
            Text(
              activeCourse.name,
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.navy),
          onPressed: () => _confirmExit(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              settingsProvider.settings.soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: AppColors.navy,
            ),
            onPressed: () {
              settingsProvider.toggleSound(!settingsProvider.settings.soundOn);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${quizProvider.currentIndex + 1} of ${questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 12.0),
                      ),
                      Text(
                        'Correct: ${quizProvider.sessionCorrectAnswers}/${quizProvider.sessionAttempted}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 12.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: progressVal,
                    color: AppColors.orange,
                    backgroundColor: AppColors.navy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
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
                    // Question text card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(color: AppColors.cardShadow, blurRadius: 12.0, offset: Offset(0, 4))
                        ],
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        currentQ!.text,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Options List
                    ...List.generate(currentQ.options.length, (idx) {
                      final optionText = currentQ.options[idx];
                      return _buildOptionTile(context, quizProvider, idx, optionText);
                    }),
                    
                    // Explanation section (if checked)
                    if (quizProvider.isAnswerChecked) ...[
                      const SizedBox(height: 20.0),
                      _buildExplanationBox(currentQ.explanation),
                    ],
                  ],
                ),
              ),
            ),
            
            // Bottom Action buttons
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: SizedBox(
                width: double.infinity,
                height: 56.0,
                child: ElevatedButton(
                  onPressed: quizProvider.selectedOptionIndex == null 
                      ? null 
                      : () => _handleAction(context, quizProvider, isLast),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    elevation: 0,
                  ),
                  child: Text(
                    quizProvider.isAnswerChecked 
                        ? (isLast ? 'Finish' : 'Next Question') 
                        : 'Check Answer',
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    QuizProvider quiz,
    int idx,
    String text,
  ) {
    final isSelected = quiz.selectedOptionIndex == idx;
    final isChecked = quiz.isAnswerChecked;
    final correctIdx = quiz.currentQuestion!.correctIndex;

    Color tileColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.navy;

    if (isChecked) {
      if (idx == correctIdx) {
        // Correct answer highlighted green
        tileColor = const Color(0xFFDFF5E4); // Mint
        borderColor = const Color(0xFF2E7D32).withOpacity(0.3);
      } else if (isSelected) {
        // Selected wrong answer highlighted red
        tileColor = const Color(0xFFFFE8D6); // Peach/soft red
        borderColor = Colors.red.withOpacity(0.3);
      }
    } else if (isSelected) {
      // Selected but not checked highlighted orange border
      borderColor = AppColors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8.0, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        onTap: () => quiz.selectOption(idx),
        leading: CircleAvatar(
          radius: 14.0,
          backgroundColor: isSelected ? AppColors.orange : AppColors.navy.withOpacity(0.08),
          child: Text(
            String.fromCharCode(65 + idx), // A, B, C, D
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ),
        title: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationBox(String explanation) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.navy.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 16.0)),
              SizedBox(width: 8.0),
              Text(
                'Explanation',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 13.0),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            explanation,
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, QuizProvider quiz, bool isLast) {
    if (!quiz.isAnswerChecked) {
      // Check answer
      quiz.checkAnswer();
    } else if (!isLast) {
      // Go to next
      quiz.nextQuestion();
    } else {
      // Finish Session, save progress and reward XP/Coins
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      final courses = Provider.of<CourseProvider>(context, listen: false);
      
      final xpEarned = quiz.sessionCorrectAnswers * 10;
      final coinsEarned = quiz.sessionCorrectAnswers * 1;
      
      // Update DB
      profile.updateXP(xpEarned);
      profile.addCoins(coinsEarned);
      profile.updateStreak();
      
      courses.updateCourseProgress(
        courseId: quiz.activeCourse!.id,
        additionalAttempted: quiz.sessionAttempted,
        additionalCorrect: quiz.sessionCorrectAnswers,
      );

      // Return to Home
      Navigator.pop(context);

      // Show congratulations toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Practice Complete! +$xpEarned XP, +$coinsEarned Coins 🪙',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.navy,
        ),
      );
    }
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Exit Session?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        content: const Text('Your current practice score will not be saved if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.navy)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit practice
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

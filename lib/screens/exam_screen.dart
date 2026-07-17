import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/quiz_provider.dart';
import 'result_screen.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  // Listen for timer expiration to auto-submit
  bool _didAutoSubmit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final quiz = Provider.of<QuizProvider>(context);
    if (quiz.mode == QuizMode.exam && quiz.examRemainingSeconds == 0 && !_didAutoSubmit && quiz.questions.isNotEmpty) {
      _didAutoSubmit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _submitExam(context, quiz, auto: true);
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _submitExam(BuildContext context, QuizProvider quiz, {bool auto = false}) {
    final results = quiz.submitExam();
    
    if (auto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time expired! Exam auto-submitted.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    // Navigate to results screen (push and remove exam from stack)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          totalQuestions: results['totalQuestions'] as int,
          correctAnswers: results['correctAnswers'] as int,
          scorePercentage: results['scorePercentage'] as int,
          timeSpentSeconds: results['timeSpentSeconds'] as int,
          courseCode: quiz.activeCourse!.code,
          courseId: quiz.activeCourse!.id,
        ),
      ),
    );
  }

  void _showQuestionGrid(BuildContext context, QuizProvider quiz) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      backgroundColor: AppColors.cream,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Questions Navigator',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800, color: AppColors.navy),
            ),
            const SizedBox(height: 18.0),
            
            // Grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: quiz.questions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (context, idx) {
                  final isAnswered = quiz.examAnswers.containsKey(idx);
                  final isCurrent = quiz.currentIndex == idx;
                  
                  Color color = Colors.white;
                  Color border = AppColors.navy.withOpacity(0.12);
                  Color text = AppColors.navy;

                  if (isCurrent) {
                    border = AppColors.orange;
                    color = AppColors.orange.withOpacity(0.08);
                  } else if (isAnswered) {
                    color = AppColors.navy;
                    text = Colors.white;
                  }

                  return GestureDetector(
                    onTap: () {
                      quiz.navigateToQuestion(idx);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: border, width: isCurrent ? 2.0 : 1.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
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
          child: const Text('No questions loaded'),
        ),
      );
    }

    final hasAnsweredCurrent = quizProvider.examAnswers.containsKey(quizProvider.currentIndex);
    final selectedOption = quizProvider.examAnswers[quizProvider.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              activeCourse.code,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy, fontSize: 16.0),
            ),
            const Text(
              'Exam Mode',
              style: TextStyle(color: Colors.red, fontSize: 11.0, fontWeight: FontWeight.bold),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            margin: const EdgeInsets.only(right: 14.0),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.red, size: 16.0),
                const SizedBox(width: 4.0),
                Text(
                  _formatDuration(quizProvider.examRemainingSeconds),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Question indicator bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${quizProvider.currentIndex + 1} of ${questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 12.0),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showQuestionGrid(context, quizProvider),
                    icon: const Icon(Icons.grid_on_rounded, size: 14),
                    label: const Text('View All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy.withOpacity(0.06),
                      foregroundColor: AppColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    ),
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
                      final isSelected = selectedOption == idx;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isSelected ? AppColors.orange : Colors.transparent,
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(color: AppColors.cardShadow, blurRadius: 8.0, offset: Offset(0, 2))
                          ],
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          onTap: () => quizProvider.selectOption(idx),
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
                            optionText,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Bottom navigation panel
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Row(
                children: [
                  // Prev Button
                  IconButton.filledTonal(
                    onPressed: quizProvider.currentIndex > 0 
                        ? () => quizProvider.navigateToQuestion(quizProvider.currentIndex - 1)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: AppColors.navy.withOpacity(0.06),
                    ),
                  ),
                  const SizedBox(width: 14.0),
                  
                  // Primary Action
                  Expanded(
                    child: SizedBox(
                      height: 56.0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (quizProvider.currentIndex < questions.length - 1) {
                            quizProvider.navigateToQuestion(quizProvider.currentIndex + 1);
                          } else {
                            // Prompt submit
                            _confirmSubmit(context, quizProvider);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          elevation: 0,
                        ),
                        child: Text(
                          quizProvider.currentIndex < questions.length - 1 ? 'Next' : 'Submit Exam',
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
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

  void _confirmSubmit(BuildContext context, QuizProvider quiz) {
    final unanswered = quiz.questions.length - quiz.examAnswers.length;
    final alertText = unanswered > 0
        ? 'You have $unanswered unanswered questions left. Are you sure you want to submit?'
        : 'Are you sure you want to complete and submit this exam?';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Submit Exam?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        content: Text(alertText, style: const TextStyle(color: AppColors.inkSoft)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.navy)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _submitExam(context, quiz);
            },
            child: const Text('Submit', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: const Text('Cancel Exam?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        content: const Text('Your answers will be lost and this attempt will not be recorded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Exam', style: TextStyle(color: AppColors.navy)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // exit exam
            },
            child: const Text('Cancel Exam', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

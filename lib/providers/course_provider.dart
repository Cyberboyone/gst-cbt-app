import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/progress.dart';
import '../services/hive_service.dart';

class CourseProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();

  final List<Course> _courses = [
    // 100 Level (University) Courses
    Course(
      id: 'gst101',
      code: 'GST 101',
      name: 'Use of English',
      icon: '📘',
      colorHex: '#FFE8D6', // Peach
      mode: '100_level',
    ),
    Course(
      id: 'gst102',
      code: 'GST 102',
      name: 'Nigerian Peoples & Culture',
      icon: '🌍',
      colorHex: '#DCEEFF', // Sky
      mode: '100_level',
    ),
    Course(
      id: 'gst111',
      code: 'GST 111',
      name: 'Logic & Philosophy',
      icon: '🧠',
      colorHex: '#DFF5E4', // Mint
      mode: '100_level',
    ),
    Course(
      id: 'gst112',
      code: 'GST 112',
      name: 'Citizenship Education',
      icon: '🏛️',
      colorHex: '#EAE2FA', // Lavender
      mode: '100_level',
    ),
    Course(
      id: 'cos101',
      code: 'COS 101',
      name: 'Intro to Computer Science',
      icon: '💻',
      colorHex: '#FFE8D6', // Peach
      mode: '100_level',
    ),
    Course(
      id: 'bio101',
      code: 'BIO 101',
      name: 'General Biology',
      icon: '🧬',
      colorHex: '#DFF5E4', // Mint
      mode: '100_level',
    ),
    
    // JAMB Subjects
    Course(
      id: 'jamb_eng',
      code: 'ENG',
      name: 'Use of English',
      icon: '📚',
      colorHex: '#DCEEFF', // Sky
      mode: 'jamb',
    ),
    Course(
      id: 'jamb_phy',
      code: 'PHY',
      name: 'Physics',
      icon: '⚛️',
      colorHex: '#FFE8D6', // Peach
      mode: 'jamb',
    ),
    Course(
      id: 'jamb_mth',
      code: 'MTH',
      name: 'Mathematics',
      icon: '🧮',
      colorHex: '#EAE2FA', // Lavender
      mode: 'jamb',
    ),

    // WAEC Subjects
    Course(
      id: 'waec_eng',
      code: 'ENG',
      name: 'English Language',
      icon: '📝',
      colorHex: '#DCEEFF', // Sky
      mode: 'waec',
    ),
    Course(
      id: 'waec_mth',
      code: 'MTH',
      name: 'Mathematics',
      icon: '📐',
      colorHex: '#DFF5E4', // Mint
      mode: 'waec',
    ),
  ];

  List<Course> get courses => _courses;

  final Map<String, CourseProgress> _progressMap = {};

  CourseProvider() {
    loadAllProgress();
  }

  void loadAllProgress() {
    for (var course in _courses) {
      _progressMap[course.id] = _hiveService.getProgress(course.id);
    }
    notifyListeners();
  }

  CourseProgress getProgressForCourse(String courseId) {
    return _progressMap[courseId] ??
        CourseProgress(
          courseId: courseId,
          questionsAttempted: 0,
          correctCount: 0,
          bestScore: 0,
          lastAttemptDate: DateTime.now(),
        );
  }

  double getCompletionPercentage(String courseId) {
    // For demo purposes and mock completeness, we'll calculate based on standard 100 questions pool.
    // If questions are cached, we can check how many questions are in Hive.
    final cachedQuestionsCount = _hiveService.getCachedQuestions(courseId).length;
    final total = cachedQuestionsCount > 0 ? cachedQuestionsCount : 100;
    
    final progress = getProgressForCourse(courseId);
    if (progress.questionsAttempted == 0) return 0.0;
    
    final pct = (progress.questionsAttempted / total);
    return pct > 1.0 ? 1.0 : pct;
  }

  Future<void> updateCourseProgress({
    required String courseId,
    required int additionalAttempted,
    required int additionalCorrect,
    int? newExamScore,
  }) async {
    final current = getProgressForCourse(courseId);
    
    int updatedAttempted = current.questionsAttempted + additionalAttempted;
    int updatedCorrect = current.correctCount + additionalCorrect;
    int updatedBestScore = current.bestScore;

    if (newExamScore != null && newExamScore > current.bestScore) {
      updatedBestScore = newExamScore;
    }

    final updated = CourseProgress(
      courseId: courseId,
      questionsAttempted: updatedAttempted,
      correctCount: updatedCorrect,
      bestScore: updatedBestScore,
      lastAttemptDate: DateTime.now(),
    );

    _progressMap[courseId] = updated;
    await _hiveService.saveProgress(updated);
    notifyListeners();
  }
}

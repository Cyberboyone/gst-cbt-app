import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/course.dart';
import '../models/question.dart';
import '../services/hive_service.dart';

enum QuizMode { practice, exam }

class QuizProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Active session parameters
  Course? _activeCourse;
  Course? get activeCourse => _activeCourse;

  QuizMode _mode = QuizMode.practice;
  QuizMode get mode => _mode;

  List<Question> _questions = [];
  List<Question> get questions => _questions;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Sound settings
  bool _soundOn = true;
  void setSoundOn(bool value) => _soundOn = value;

  // --- Practice Mode specific state ---
  int? _selectedOptionIndex; // Selected index for current question
  int? get selectedOptionIndex => _selectedOptionIndex;

  bool _isAnswerChecked = false;
  bool get isAnswerChecked => _isAnswerChecked;

  int _sessionCorrectAnswers = 0;
  int get sessionCorrectAnswers => _sessionCorrectAnswers;

  int _sessionAttempted = 0;
  int get sessionAttempted => _sessionAttempted;

  // --- Exam Mode specific state ---
  final Map<int, int> _examAnswers = {}; // Map of question index -> selected option index
  Map<int, int> get examAnswers => _examAnswers;

  int _examDurationSeconds = 1800; // 30 mins default
  int _examRemainingSeconds = 1800;
  int get examRemainingSeconds => _examRemainingSeconds;
  
  Timer? _examTimer;
  bool get isExamRunning => _examTimer != null && _examTimer!.isActive;

  // Start a new session
  Future<void> startSession({
    required Course course,
    required QuizMode mode,
    List<Question>? overrideQuestions,
    int examDurationMinutes = 30,
  }) async {
    _isLoading = true;
    _activeCourse = course;
    _mode = mode;
    _currentIndex = 0;
    _selectedOptionIndex = null;
    _isAnswerChecked = false;
    _sessionCorrectAnswers = 0;
    _sessionAttempted = 0;
    _examAnswers.clear();
    _examRemainingSeconds = examDurationMinutes * 60;
    _examDurationSeconds = examDurationMinutes * 60;
    
    _cancelTimer();
    notifyListeners();

    // Fetch questions
    if (overrideQuestions != null && overrideQuestions.isNotEmpty) {
      _questions = List.from(overrideQuestions);
    } else {
      // Load questions from local DB
      final localQuestions = _hiveService.getCachedQuestions(course.id);
      if (localQuestions.isNotEmpty) {
        _questions = List.from(localQuestions)..shuffle();
      } else {
        _questions = [];
      }
    }

    // Limit exam mode to 40 questions maximum, or all if less
    if (_mode == QuizMode.exam && _questions.length > 40) {
      _questions = _questions.sublist(0, 40);
    } else if (_mode == QuizMode.practice) {
      if (_questions.length > 20) {
        _questions = _questions.sublist(0, 20); // standard practice batch
      }
    }

    _isLoading = false;
    notifyListeners();

    if (_mode == QuizMode.exam) {
      _startExamTimer();
    }
  }

  // Current Question
  Question? get currentQuestion {
    if (_questions.isEmpty || _currentIndex >= _questions.length) return null;
    return _questions[_currentIndex];
  }

  // --- Practice Mode Operations ---
  void selectOption(int index) {
    if (_mode == QuizMode.practice) {
      if (_isAnswerChecked) return;
      _selectedOptionIndex = index;
    } else {
      // Exam mode
      _examAnswers[_currentIndex] = index;
    }
    notifyListeners();
  }

  Future<void> checkAnswer() async {
    if (_mode != QuizMode.practice || _isAnswerChecked || _selectedOptionIndex == null) return;
    
    _isAnswerChecked = true;
    _sessionAttempted++;

    final correct = currentQuestion!.correctIndex;
    final isCorrect = _selectedOptionIndex == correct;

    if (isCorrect) {
      _sessionCorrectAnswers++;
      if (_soundOn) {
        // Play correct sound
        await _playAssetSound('sounds/correct.mp3');
      }
    } else {
      if (_soundOn) {
        // Play wrong sound
        await _playAssetSound('sounds/wrong.mp3');
      }
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedOptionIndex = null;
      _isAnswerChecked = false;
      notifyListeners();
    }
  }

  // --- Exam Mode Operations ---
  void navigateToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void _startExamTimer() {
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_examRemainingSeconds > 0) {
        _examRemainingSeconds--;
        notifyListeners();
      } else {
        _cancelTimer();
        // Time expired, auto-submit is triggered via UI listening
        notifyListeners();
      }
    });
  }

  void _cancelTimer() {
    _examTimer?.cancel();
    _examTimer = null;
  }

  // Submit Exam
  Map<String, dynamic> submitExam() {
    _cancelTimer();
    int correctCount = 0;
    
    for (int i = 0; i < _questions.length; i++) {
      final selected = _examAnswers[i];
      final actualCorrect = _questions[i].correctIndex;
      if (selected == actualCorrect) {
        correctCount++;
      }
    }

    final scorePercentage = _questions.isEmpty 
        ? 0 
        : ((correctCount / _questions.length) * 100).round();

    return {
      'totalQuestions': _questions.length,
      'correctAnswers': correctCount,
      'scorePercentage': scorePercentage,
      'timeSpentSeconds': _examDurationSeconds - _examRemainingSeconds,
    };
  }

  Future<void> _playAssetSound(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}

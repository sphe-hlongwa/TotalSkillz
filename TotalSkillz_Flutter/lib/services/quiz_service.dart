import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';

/// Quiz engine — Dart port of the quiz logic from main.js
class QuizService extends ChangeNotifier {
  List<Question> _allQuestions = [];
  List<Question> _currentSessionQuestions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = false;

  List<Question> get currentQuestions => _currentSessionQuestions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isFinished => _currentSessionQuestions.isNotEmpty && _currentIndex >= _currentSessionQuestions.length;

  Question? get currentQuestion {
    if (_currentIndex >= 0 && _currentIndex < _currentSessionQuestions.length) {
      return _currentSessionQuestions[_currentIndex];
    }
    return null;
  }

  /// Load questions from local assets
  Future<void> loadQuestions() async {
    if (_allQuestions.isNotEmpty) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final decoded = json.decode(response);
      
      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['questions'] is List) {
        list = decoded['questions'] as List;
      } else {
        list = [];
      }

      _allQuestions = list.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading questions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start a new quiz session filtered by topic
  void startQuiz({String? topic, int count = 10, String? difficulty}) {
    List<Question> filtered = _allQuestions;
    
    if (topic != null && topic != 'all') {
      filtered = filtered.where((q) => q.topic == topic).toList();
    }
    
    if (difficulty != null) {
      filtered = filtered.where((q) => q.difficulty == difficulty).toList();
    }

    filtered.shuffle();
    _currentSessionQuestions = filtered.take(count).toList();
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }

  /// Register answer and return whether it was correct
  bool answerQuestion(int selectedIndex) {
    if (currentQuestion == null) return false;
    
    final bool correct = currentQuestion!.isCorrect(selectedIndex);
    if (correct) _score++;
    
    return correct;
  }

  void nextQuestion() {
    _currentIndex++;
    notifyListeners();
  }

  void reset() {
    _currentSessionQuestions = [];
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }

  /// XP calculation logic from website
  int calculateXpEarned() {
    if (_currentSessionQuestions.isEmpty) return 0;
    final base = _score * 10;
    final bonus = (_score == _currentSessionQuestions.length) ? 50 : 0;
    return base + bonus;
  }

  List<String> get topics {
    return _allQuestions.map((q) => q.topic).toSet().toList()..sort();
  }
}

class QuizResult {
  final int total;
  final int attempted;
  final int correct;
  final double score;
  final int xpEarned;

  const QuizResult({
    required this.total,
    required this.attempted,
    required this.correct,
    required this.score,
    required this.xpEarned,
  });

  String get grade {
    if (score >= 0.8) return 'A';
    if (score >= 0.7) return 'B';
    if (score >= 0.6) return 'C';
    if (score >= 0.5) return 'D';
    return 'F';
  }

  bool get passed => score >= 0.5;
}

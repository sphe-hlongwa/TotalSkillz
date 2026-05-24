import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/examiner_model.dart';

class ExaminerService extends ChangeNotifier {
  List<ExaminerQuestion> _allQuestions = [];
  List<ExaminerQuestion> _sessionQuestions = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  int? _selectedStepId;
  bool _isAnswered = false;

  List<ExaminerQuestion> get questions => _sessionQuestions;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  int? get selectedStepId => _selectedStepId;
  bool get isAnswered => _isAnswered;

  ExaminerQuestion? get currentQuestion {
    if (_currentIndex < _sessionQuestions.length) {
      return _sessionQuestions[_currentIndex];
    }
    return null;
  }

  Future<void> loadQuestions() async {
    if (_allQuestions.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/examiner_data.json');
      final List<dynamic> data = json.decode(response);
      _allQuestions = data.map((q) => ExaminerQuestion.fromJson(q)).toList();
    } catch (e) {
      debugPrint('Error loading examiner questions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startSession({int count = 5}) {
    _allQuestions.shuffle();
    _sessionQuestions = _allQuestions.take(count).toList();
    _currentIndex = 0;
    _selectedStepId = null;
    _isAnswered = false;
    notifyListeners();
  }

  void selectStep(int stepId) {
    if (_isAnswered) return;
    _selectedStepId = stepId;
    _isAnswered = true;
    notifyListeners();
  }

  void nextQuestion() {
    _currentIndex++;
    _selectedStepId = null;
    _isAnswered = false;
    notifyListeners();
  }

  bool get isCorrect => _selectedStepId == currentQuestion?.incorrectStepId;

  bool get isFinished => _currentIndex >= _sessionQuestions.length;
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/question.dart';

class DailyChallengeService extends ChangeNotifier {
  Question? _currentQuestion;
  bool _isLoading = false;
  bool _isAnswered = false;
  int? _selectedOption;
  bool? _isCorrect;

  Question? get currentQuestion => _currentQuestion;
  bool get isLoading => _isLoading;
  bool get isAnswered => _isAnswered;
  int? get selectedOption => _selectedOption;
  bool? get isCorrect => _isCorrect;

  Future<void> loadDailyChallenge() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final List<dynamic> data = json.decode(response);
      final allQuestions = data.map((q) => Question.fromJson(q)).toList();
      
      // Filter for hard questions matching web logic
      final hardQuestions = allQuestions.where((q) => q.difficulty.toLowerCase() == 'hard').toList();
      
      if (hardQuestions.isNotEmpty) {
        // Use date as seed
        final now = DateTime.now();
        final dateString = "${now.year}-${now.month}-${now.day}";
        final seed = dateString.codeUnits.fold(0, (prev, element) => prev + element);
        
        final random = Random(seed);
        _currentQuestion = hardQuestions[random.nextInt(hardQuestions.length)];
      }
    } catch (e) {
      debugPrint('Error loading daily challenge: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void submitAnswer(int index) {
    if (_isAnswered || _currentQuestion == null) return;
    
    _selectedOption = index;
    _isCorrect = index == _currentQuestion!.correctIndex;
    _isAnswered = true;
    notifyListeners();
  }

  void reset() {
    _isAnswered = false;
    _selectedOption = null;
    _isCorrect = null;
    notifyListeners();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../services/quiz_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class ExamScreen extends StatefulWidget {
  final String? topic;
  const ExamScreen({super.key, this.topic});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int? _selectedIndex;
  int _secondsLeft = 45 * 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quiz = context.read<QuizService>();
      quiz.loadQuestions().then((_) {
        quiz.startQuiz(topic: widget.topic, count: 30);
        _startTimer();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        _finishExam();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _timeFormatted {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onAnswered(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onNext() {
    final quiz = context.read<QuizService>();
    quiz.answerQuestion(_selectedIndex ?? -1); // Register answer
    
    if (quiz.isFinished) {
      _finishExam();
    } else {
      quiz.nextQuestion();
      setState(() => _selectedIndex = null);
    }
  }

  Future<void> _finishExam() async {
    _timer?.cancel();
    final quiz = context.read<QuizService>();
    final firestore = context.read<FirestoreService>();
    
    final xp = quiz.calculateXpEarned();
    await firestore.updateTopicProgress(
      topic: 'exam',
      attempted: quiz.currentQuestions.length,
      correct: quiz.score,
      total: quiz.currentQuestions.length,
      xpEarned: xp,
    );

    if (mounted) {
      _showResultsDialog(context, xp);
    }
  }

  void _showResultsDialog(BuildContext context, int xp) {
    final quiz = context.read<QuizService>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Exam Result', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${(quiz.score / quiz.currentQuestions.length * 100).toInt()}%', 
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            const SizedBox(height: 8),
            Text('You got ${quiz.score} out of ${quiz.currentQuestions.length} correct'),
            Text('+$xp XP Earned', style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizService>();
    final currentQ = quiz.currentQuestion;

    if (quiz.isLoading || currentQ == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Mode'),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: _secondsLeft < 300 ? AppTheme.error.withValues(alpha: 0.2) : AppTheme.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⏱ $_timeFormatted',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _secondsLeft < 300 ? AppTheme.error : AppTheme.text,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (quiz.currentIndex + 1) / quiz.currentQuestions.length,
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text('Question ${quiz.currentIndex + 1} of ${quiz.currentQuestions.length}', 
                    style: const TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: _buildMathText(currentQ.question, style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(currentQ.options.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _onAnswered(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border, width: isSelected ? 2 : 1),
                          ),
                          child: _buildMathText(currentQ.options[index]),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _selectedIndex != null ? _onNext : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(quiz.isFinished ? 'Submit Exam' : 'Next Question'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathText(String text, {TextStyle? style}) {
    if (text.contains(r'\(') || text.contains(r'\[') || text.contains(r'\\')) {
      final cleaned = text
          .replaceAll(r'\(', '')
          .replaceAll(r'\)', '')
          .replaceAll(r'\[', '')
          .replaceAll(r'\]', '');
      return Math.tex(
        cleaned,
        textStyle: style ?? const TextStyle(fontSize: 15, color: AppTheme.text),
      );
    }
    return Text(text, style: style ?? const TextStyle(fontSize: 15, color: AppTheme.text));
  }
}

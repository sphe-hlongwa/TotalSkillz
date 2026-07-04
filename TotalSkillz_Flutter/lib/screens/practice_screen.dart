import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../services/quiz_service.dart';
import '../services/firestore_service.dart';
import '../models/user_progress.dart';
import '../theme/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  final String? topic;
  const PracticeScreen({super.key, this.topic});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int? _selectedIndex;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quiz = context.read<QuizService>();
      quiz.loadQuestions().then((_) {
        quiz.startQuiz(topic: widget.topic);
      });
    });
  }

  void _onAnswered(int index) {
    if (_isAnswered) return;
    
    setState(() {
      _selectedIndex = index;
      _isAnswered = true;
    });

    final quiz = context.read<QuizService>();
    final correct = quiz.answerQuestion(index);

    if (!correct) {
      // Log to mistake vault
      final current = quiz.currentQuestion;
      if (current != null) {
        context.read<FirestoreService>().addToMistakeVault(
          MistakeItem(
            questionText: current.question,
            topic: current.topic,
            streak: 0,
            lastSeen: DateTime.now(),
          ),
        );
      }
    }
  }

  void _onNext() {
    final quiz = context.read<QuizService>();
    if (quiz.isFinished) {
      _showResults();
    } else {
      quiz.nextQuestion();
      setState(() {
        _selectedIndex = null;
        _isAnswered = false;
      });
    }
  }

  Future<void> _showResults() async {
    final quiz = context.read<QuizService>();
    final firestore = context.read<FirestoreService>();
    
    final xp = quiz.calculateXpEarned();
    
    await firestore.updateTopicProgress(
      topic: widget.topic ?? 'General',
      attempted: quiz.currentQuestions.length,
      correct: quiz.score,
      total: quiz.currentQuestions.length,
      xpEarned: xp,
    );

    if (mounted) {
      _buildResultsDialog(context, xp);
    }
  }

  void _buildResultsDialog(BuildContext context, int xp) {
    final quiz = context.read<QuizService>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Practice Complete!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: AppTheme.warning, size: 64),
            const SizedBox(height: 16),
            Text('You scored ${quiz.score}/${quiz.currentQuestions.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('+$xp XP Earned', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to topics
            },
            child: const Text('Back to Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              quiz.startQuiz(topic: widget.topic);
              setState(() {
                _selectedIndex = null;
                _isAnswered = false;
              });
            },
            child: const Text('Restart Quiz'),
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

    final progress = (quiz.currentIndex + 1) / quiz.currentQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic ?? 'Practice'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${quiz.currentIndex + 1}/${quiz.currentQuestions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: AppTheme.bg),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    final isCorrect = currentQ.isCorrect(index);
                    final isSelected = _selectedIndex == index;
                    
                    Color borderColor = AppTheme.border;
                    Color bgColor = AppTheme.surface;
                    IconData? statusIcon;

                    if (_isAnswered) {
                      if (isCorrect) {
                        borderColor = AppTheme.success;
                        bgColor = AppTheme.success.withValues(alpha: 0.1);
                        statusIcon = Icons.check_circle_rounded;
                      } else if (isSelected) {
                        borderColor = AppTheme.error;
                        bgColor = AppTheme.error.withValues(alpha: 0.1);
                        statusIcon = Icons.cancel_rounded;
                      }
                    } else if (isSelected) {
                      borderColor = AppTheme.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => _onAnswered(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: isSelected || (_isAnswered && isCorrect) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: _buildMathText(currentQ.options[index])),
                              if (statusIcon != null)
                                Icon(statusIcon, color: isCorrect ? AppTheme.success : AppTheme.error),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (_isAnswered)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (currentQ.solution != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppTheme.info, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMathText(currentQ.solution!.join('\n'), style: const TextStyle(color: AppTheme.info, fontSize: 13))),
                        ],
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(quiz.isFinished ? 'Finish Session' : 'Continue'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMathText(String text, {TextStyle? style}) {
    final textStyle = style ?? const TextStyle(fontSize: 15, color: AppTheme.text, height: 1.5);
    
    final RegExp mathRegExp = RegExp(r'(\$\$.*?\$\$|\$.*?\$|\\\(.*?\\\)|\\\[.*?\\\])', dotAll: true);
    final Iterable<RegExpMatch> matches = mathRegExp.allMatches(text);
    
    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;
    
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: textStyle));
      }
      
      String mathContent = match.group(0)!;
      if (mathContent.startsWith(r'$$') && mathContent.endsWith(r'$$')) {
        mathContent = mathContent.substring(2, mathContent.length - 2);
      } else if (mathContent.startsWith(r'$') && mathContent.endsWith(r'$')) {
        mathContent = mathContent.substring(1, mathContent.length - 1);
      } else if (mathContent.startsWith(r'\(') && mathContent.endsWith(r'\)')) {
        mathContent = mathContent.substring(2, mathContent.length - 2);
      } else if (mathContent.startsWith(r'\[') && mathContent.endsWith(r'\]')) {
        mathContent = mathContent.substring(2, mathContent.length - 2);
      }
      
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          mathContent,
          textStyle: textStyle,
          mathStyle: MathStyle.text,
          onErrorFallback: (err) => Text(mathContent, style: textStyle.copyWith(color: AppTheme.error)),
        ),
      ));
      
      lastMatchEnd = match.end;
    }
    
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: textStyle));
    }
    
    if (spans.isEmpty) {
      return Text(text, style: textStyle);
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

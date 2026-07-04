import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../services/examiner_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';

class ExaminerScreen extends StatefulWidget {
  const ExaminerScreen({super.key});

  @override
  State<ExaminerScreen> createState() => _ExaminerScreenState();
}

class _ExaminerScreenState extends State<ExaminerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<ExaminerService>();
      service.loadQuestions().then((_) {
        service.startSession();
      });
    });
  }

  void _onStepTap(int stepId) {
    context.read<ExaminerService>().selectStep(stepId);
  }

  void _onNext() {
    final service = context.read<ExaminerService>();
    if (service.isFinished) {
      Navigator.pop(context);
    } else {
      service.nextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ExaminerService>();
    final currentQ = service.currentQuestion;

    if (service.isLoading || currentQ == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spot the Error'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${service.currentIndex + 1}/${service.questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (service.currentIndex + 1) / service.questions.length,
            minHeight: 6,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentQ.topic, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 8),
                        _buildMathText(currentQ.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Touch the step that contains an error:', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                  const SizedBox(height: 16),
                  ...currentQ.steps.map((step) {
                    final isSelected = service.selectedStepId == step.id;
                    final isAnswered = service.isAnswered;
                    final isActuallyIncorrect = step.id == currentQ.incorrectStepId;

                    Color borderColor = AppTheme.border;
                    Color bgColor = AppTheme.surface;
                    Widget? icon;

                    if (isAnswered) {
                      if (isActuallyIncorrect) {
                        borderColor = AppTheme.success;
                        bgColor = AppTheme.success.withValues(alpha: 0.1);
                        icon = const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20);
                      } else if (isSelected) {
                        borderColor = AppTheme.error;
                        bgColor = AppTheme.error.withValues(alpha: 0.1);
                        icon = const Icon(Icons.cancel_rounded, color: AppTheme.error, size: 20);
                      }
                    } else if (isSelected) {
                      borderColor = AppTheme.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _onStepTap(step.id),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor, width: isAnswered && (isActuallyIncorrect || isSelected) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.bg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Center(child: Text('${step.id + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _buildMathText(step.tex)),
                              ?icon,
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
          if (service.isAnswered)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: service.isCorrect ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.isCorrect ? 'Correct!' : 'Incorrect',
                          style: TextStyle(
                            color: service.isCorrect ? AppTheme.success : AppTheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(currentQ.explanation, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: service.isFinished ? 'Finish' : 'Next Question',
                    onPressed: _onNext,
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

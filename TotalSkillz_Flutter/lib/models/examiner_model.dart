 class ExaminerQuestion {
  final String id;
  final String topic;
  final String question;
  final String difficulty;
  final List<ExaminerStep> steps;
  final int incorrectStepId;
  final String explanation;

  ExaminerQuestion({
    required this.id,
    required this.topic,
    required this.question,
    required this.difficulty,
    required this.steps,
    required this.incorrectStepId,
    required this.explanation,
  });

  factory ExaminerQuestion.fromJson(Map<String, dynamic> json) {
    return ExaminerQuestion(
      id: json['id'],
      topic: json['topic'],
      question: json['question'],
      difficulty: json['difficulty'],
      steps: (json['steps'] as List).map((s) => ExaminerStep.fromJson(s)).toList(),
      incorrectStepId: json['incorrectStepId'],
      explanation: json['explanation'],
    );
  }
}

class ExaminerStep {
  final int id;
  final String tex;

  ExaminerStep({required this.id, required this.tex});

  factory ExaminerStep.fromJson(Map<String, dynamic> json) {
    return ExaminerStep(
      id: json['id'],
      tex: json['tex'],
    );
  }
}

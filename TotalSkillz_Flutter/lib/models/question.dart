/// Data model for a quiz question
class Question {
  final String? id;
  final String topic;
  final String difficulty; // 'easy', 'manageable', 'hard'
  final String question;
  final List<String> options;
  final int correctIndex;
  final List<String>? solution;
  final Map<String, dynamic>? graph;

  const Question({
    this.id,
    required this.topic,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.solution,
    this.graph,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString(),
      topic: json['topic']?.toString() ?? 'general',
      difficulty: json['difficulty']?.toString() ?? 'manageable',
      question: json['q']?.toString() ?? json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: (json['answer'] ?? json['correctIndex'] ?? 0) as int,
      solution: (json['solution'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      graph: json['graph'] as Map<String, dynamic>?,
    );
  }

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

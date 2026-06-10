class MasterclassTopic {
  final List<MasterclassItem> items;

  MasterclassTopic({required this.items});

  factory MasterclassTopic.fromJson(List<dynamic> json) {
    return MasterclassTopic(
      items: json.map((i) => MasterclassItem.fromJson(i)).toList(),
    );
  }
}

class MasterclassItem {
  final String title;
  final String question;
  final List<MasterclassStep> steps;

  MasterclassItem({
    required this.title,
    required this.question,
    required this.steps,
  });

  factory MasterclassItem.fromJson(Map<String, dynamic> json) {
    return MasterclassItem(
      title: json['title'],
      question: json['question'],
      steps: (json['steps'] as List).map((s) => MasterclassStep.fromJson(s)).toList(),
    );
  }
}

class MasterclassStep {
  final String tex;
  final String note;

  MasterclassStep({required this.tex, required this.note});

  factory MasterclassStep.fromJson(Map<String, dynamic> json) {
    return MasterclassStep(
      tex: json['tex'],
      note: json['note'],
    );
  }
}

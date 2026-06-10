/// Data model for user progress stored in Firestore
class UserProgress {
  final String uid;
  final String displayName;
  final String email;
  final bool isAdmin;
  final Map<String, TopicProgress> topics;
  final int totalXp;
  final int streak;
  final List<MistakeItem> mistakeVault;
  final List<String> badges;
  final UserSettings settings;
  final DateTime? lastActiveDate;
  final DateTime? lastDailyDate;

  const UserProgress({
    required this.uid,
    required this.displayName,
    required this.email,
    this.isAdmin = false,
    this.topics = const {},
    this.totalXp = 0,
    this.streak = 0,
    this.mistakeVault = const [],
    this.badges = const [],
    this.settings = const UserSettings(),
    this.lastActiveDate,
    this.lastDailyDate,
  });

  factory UserProgress.fromFirestore(Map<String, dynamic> data, String uid) {
    final topicsRaw = data['topics'] as Map<String, dynamic>? ?? {};
    final vaultRaw = data['mistakeVault'] as List<dynamic>? ?? [];
    final badgesRaw = data['badges'] as List<dynamic>? ?? [];
    final role = data['role']?.toString() ?? 'student';

    return UserProgress(
      uid: uid,
      displayName: data['displayName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      isAdmin: role == 'admin',
      topics: topicsRaw.map((k, v) =>
          MapEntry(k, TopicProgress.fromMap(v as Map<String, dynamic>))),
      totalXp: (data['totalXp'] ?? data['xp'] ?? 0) as int,
      streak: (data['streak'] ?? 0) as int,
      mistakeVault: vaultRaw.map((e) => MistakeItem.fromMap(e as Map<String, dynamic>)).toList(),
      badges: badgesRaw.map((e) => e.toString()).toList(),
      settings: data['settings'] != null 
          ? UserSettings.fromMap(data['settings'] as Map<String, dynamic>)
          : const UserSettings(),
      lastActiveDate: data['lastActive'] != null
          ? (data['lastActive'] is DateTime 
              ? data['lastActive'] as DateTime 
              : DateTime.tryParse(data['lastActive'].toString()))
          : null,
      lastDailyDate: data['lastDailyDate'] != null
          ? (data['lastDailyDate'] is DateTime
              ? data['lastDailyDate'] as DateTime
              : DateTime.tryParse(data['lastDailyDate'].toString()))
          : null,
    );
  }

  double get overallProgress {
    if (topics.isEmpty) return 0;
    final total = topics.values.fold<int>(0, (sum, t) => sum + t.questionsTotal);
    final done = topics.values.fold<int>(0, (sum, t) => sum + t.questionsCorrect);
    return total == 0 ? 0 : done / total;
  }
}

class MistakeItem {
  final String questionText;
  final String topic;
  final int streak;
  final DateTime lastSeen;

  MistakeItem({
    required this.questionText,
    required this.topic,
    this.streak = 1,
    required this.lastSeen,
  });

  factory MistakeItem.fromMap(Map<String, dynamic> map) {
    return MistakeItem(
      questionText: map['qText'] ?? map['questionText'] ?? '',
      topic: map['topic'] ?? '',
      streak: (map['streak'] ?? 1) as int,
      lastSeen: map['lastSeen'] != null 
          ? DateTime.tryParse(map['lastSeen'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'qText': questionText,
    'topic': topic,
    'streak': streak,
    'lastSeen': lastSeen.toIso8601String(),
  };
}

class UserSettings {
  final String theme;
  final int dailyGoal;
  final int targetMark;
  final int weeklyHours;
  final List<String> weakAreas;
  final DateTime? examDate;
  final bool reminders;
  final String school;
  final String province;
  final int dailyGoalXp;
  final bool notificationsEnabled;

  const UserSettings({
    this.theme = 'dark',
    this.dailyGoal = 10,
    this.targetMark = 80,
    this.weeklyHours = 5,
    this.weakAreas = const [],
    this.examDate,
    this.reminders = false,
    this.school = '',
    this.province = '',
    this.dailyGoalXp = 50,
    this.notificationsEnabled = true,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      theme: map['theme']?.toString() ?? 'dark',
      dailyGoal: (map['dailyGoal'] ?? 10) as int,
      targetMark: (map['targetMark'] ?? 80) as int,
      weeklyHours: (map['weeklyHours'] ?? 5) as int,
      weakAreas: (map['weakAreas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      examDate: map['examDate'] != null ? DateTime.tryParse(map['examDate'].toString()) : null,
      reminders: map['reminders'] == true,
      school: map['school']?.toString() ?? '',
      province: map['province']?.toString() ?? '',
      dailyGoalXp: (map['dailyGoalXp'] ?? 50) as int,
      notificationsEnabled: map['notificationsEnabled'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
    'theme': theme,
    'dailyGoal': dailyGoal,
    'targetMark': targetMark,
    'weeklyHours': weeklyHours,
    'weakAreas': weakAreas,
    'examDate': examDate?.toIso8601String(),
    'reminders': reminders,
    'school': school,
    'province': province,
    'dailyGoalXp': dailyGoalXp,
    'notificationsEnabled': notificationsEnabled,
  };
}

class TopicProgress {
  final int questionsAttempted;
  final int questionsCorrect;
  final int questionsTotal;
  final bool completed;

  const TopicProgress({
    this.questionsAttempted = 0,
    this.questionsCorrect = 0,
    this.questionsTotal = 0,
    this.completed = false,
  });

  factory TopicProgress.fromMap(Map<String, dynamic> map) {
    return TopicProgress(
      questionsAttempted: (map['attempted'] ?? 0) as int,
      questionsCorrect: (map['correct'] ?? 0) as int,
      questionsTotal: (map['total'] ?? 0) as int,
      completed: map['completed'] == true,
    );
  }

  double get accuracy =>
      questionsAttempted == 0 ? 0 : questionsCorrect / questionsAttempted;
}

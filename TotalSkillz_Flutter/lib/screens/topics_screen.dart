import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../services/quiz_service.dart';
import '../theme/app_theme.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  static const Map<String, IconData> _icons = {
    'algebra': Icons.calculate,
    'calculus': Icons.trending_up,
    'trigonometry': Icons.change_history,
    'statistics': Icons.bar_chart,
    'probability': Icons.casino_outlined,
    'finance': Icons.attach_money,
    'functions': Icons.show_chart,
    'analytical_geometry': Icons.grid_on,
    'euclidean_geometry': Icons.architecture,
    'patterns': Icons.format_list_numbered,
  };

  static const List<Color> _colours = [
    AppTheme.primary,
    AppTheme.accent,
    AppTheme.error,
    AppTheme.success,
    AppTheme.warning,
    Color(0xFFE91E96),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  Map<String, dynamic> _lessonData = {};
  String? _selectedTopic;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizService>().loadQuestions();
    });
  }

  Future<void> _loadLessonData() async {
    try {
      final raw = await rootBundle.loadString('assets/topics_lessons.json');
      setState(() => _lessonData = json.decode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Could not load lesson data: $e');
    }
  }

  IconData _iconFor(String topic) {
    final lower = topic.toLowerCase().replaceAll(' ', '_');
    for (final entry in _icons.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.school_outlined;
  }

  Color _colorFor(int index) => _colours[index % _colours.length];

  String _normaliseKey(String topic) {
    return topic.toLowerCase().replaceAll(' ', '_');
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedTopic != null) {
      return _buildTopicDetail(_selectedTopic!);
    }
    return _buildTopicsList();
  }

  // ──────────────── TOPIC LIST ────────────────
  Widget _buildTopicsList() {
    final quizService = context.watch<QuizService>();
    final topics = quizService.topics;

    return Scaffold(
      appBar: AppBar(title: const Text('Topics')),
      body: quizService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : topics.isEmpty
              ? const Center(child: Text('No topics found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topics.length,
                  itemBuilder: (ctx, i) {
                    final topic = topics[i];
                    final key = _normaliseKey(topic);
                    final meta = _lessonData[key] as Map<String, dynamic>?;
                    final color = _colorFor(i);
                    final lessonCount = (meta?['lessons'] as List?)?.length ?? 0;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 400 + i * 60),
                      curve: Curves.easeOutCubic,
                      builder: (ctx, val, child) => Opacity(
                        opacity: val,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - val)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        color: AppTheme.surface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppTheme.border),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _selectedTopic = topic),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(_iconFor(topic), color: color, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(meta?['title'] ?? topic,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(
                                        meta?['desc'] ?? 'Tap to explore',
                                        style: const TextStyle(
                                            color: AppTheme.textMuted, fontSize: 12),
                                      ),
                                      if (lessonCount > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '$lessonCount lesson${lessonCount > 1 ? 's' : ''} available',
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    color: AppTheme.textMuted, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // ──────────────── TOPIC DETAIL ────────────────
  Widget _buildTopicDetail(String topic) {
    final key = _normaliseKey(topic);
    final meta = _lessonData[key] as Map<String, dynamic>?;
    final lessons = (meta?['lessons'] as List<dynamic>?) ?? [];
    final idx = context.read<QuizService>().topics.indexOf(topic);
    final color = _colorFor(idx >= 0 ? idx : 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _selectedTopic = null),
        ),
        title: Text(meta?['title'] ?? topic),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: AppTheme.surface,
              child: const TabBar(
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textMuted,
                tabs: [
                  Tab(text: 'Lessons'),
                  Tab(text: 'Practice'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ── Lessons Tab ──
                  lessons.isEmpty
                      ? const Center(
                          child: Text('No lessons available yet.',
                              style: TextStyle(color: AppTheme.textMuted)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: lessons.length,
                          itemBuilder: (ctx, i) {
                            final lesson = lessons[i] as Map<String, dynamic>;
                            return _LessonCard(
                              lesson: lesson,
                              color: color,
                              index: i,
                            );
                          },
                        ),
                  // ── Practice Tab ──
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz_outlined, size: 64, color: color.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('Practice: $topic',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                            'Test your knowledge with topic-specific questions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => context.push(
                                '/practice?topic=${Uri.encodeComponent(topic)}'),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Start Practice'),
                            style: FilledButton.styleFrom(
                              backgroundColor: color,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────── LESSON CARD ────────────────
class _LessonCard extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Color color;
  final int index;

  const _LessonCard({required this.lesson, required this.color, required this.index});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final steps = (lesson['steps'] as List<dynamic>?) ?? [];
    final formula = lesson['formula'] as String?;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + widget.index * 80),
      curve: Curves.easeOutCubic,
      builder: (ctx, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - val)),
          child: child,
        ),
      ),
      child: Card(
        color: AppTheme.surface,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(lesson['title'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.expand_more, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formula box
                    if (formula != null && formula.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Center(
                          child: Math.tex(
                            formula,
                            textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    // Explanation
                    Text(lesson['explanation'] ?? '',
                        style: const TextStyle(
                            color: AppTheme.textSubtle, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 16),
                    // Steps
                    ...steps.asMap().entries.map((entry) {
                      final step = entry.value as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 12, top: 2),
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: TextStyle(
                                    color: widget.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(step['desc'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  if (step['tex'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Math.tex(
                                          step['tex'],
                                          textStyle: const TextStyle(
                                              fontSize: 14, color: AppTheme.primary),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

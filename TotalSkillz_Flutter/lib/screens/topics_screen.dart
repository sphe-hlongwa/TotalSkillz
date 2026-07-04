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

class _TopicsScreenState extends State<TopicsScreen>
    with SingleTickerProviderStateMixin {
  static const Map<String, IconData> _icons = {
    'algebra': Icons.superscript,
    'calculus': Icons.all_inclusive,
    'trigonometry': Icons.architecture,
    'statistics': Icons.query_stats,
    'probability': Icons.casino,
    'finance': Icons.monetization_on,
    'functions': Icons.show_chart,
    'analytical_geometry': Icons.straighten,
    'euclidean_geometry': Icons.category,
    'patterns': Icons.format_list_numbered,
  };

  static const List<Color> _colours = [
    AppTheme.primary,
    AppTheme.secondary,
    AppTheme.error,
    AppTheme.success,
    AppTheme.warning,
    Color(0xFFE91E96),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF6B35),
    Color(0xFF2ECC71),
  ];

  Map<String, dynamic> _lessonData = {};
  String? _selectedTopic;
  late AnimationController _listAnimCtrl;

  @override
  void initState() {
    super.initState();
    _listAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadLessonData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizService>().loadQuestions();
    });
  }

  @override
  void dispose() {
    _listAnimCtrl.dispose();
    super.dispose();
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

  String _normaliseKey(String topic) =>
      topic.toLowerCase().replaceAll(' ', '_');

  @override
  Widget build(BuildContext context) {
    if (_selectedTopic != null) {
      return _TopicDetailView(
        topic: _selectedTopic!,
        lessonData: _lessonData,
        color: _colorFor(
            context.read<QuizService>().topics.indexOf(_selectedTopic!)),
        onBack: () {
          setState(() => _selectedTopic = null);
          _listAnimCtrl
            ..reset()
            ..forward();
        },
        onPractice: (t) =>
            context.push('/practice?topic=${Uri.encodeComponent(t)}'),
      );
    }
    return _buildTopicsList();
  }

  Widget _buildTopicsList() {
    final quizService = context.watch<QuizService>();
    final topics = quizService.topics;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: quizService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : topics.isEmpty
              ? _emptyState()
              : CustomScrollView(
                  slivers: [
                    // ─── Page Header ─────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.primary,
                                        AppTheme.primaryDark
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.book_outlined,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Topics',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.w800)),
                                    const Text('Pick a topic to study',
                                        style: TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Stats strip
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  _StatChip(
                                    icon: Icons.topic_outlined,
                                    label: '${topics.length} Topics',
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  _StatChip(
                                    icon: Icons.menu_book_outlined,
                                    label: '${_totalLessons(topics)} Lessons',
                                    color: AppTheme.secondary,
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.verified_outlined,
                                            color: AppTheme.success, size: 14),
                                        SizedBox(width: 4),
                                        Text('Grade 12',
                                            style: TextStyle(
                                                color: AppTheme.success,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ─── Topic Cards ──────────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final topic = topics[i];
                            final key = _normaliseKey(topic);
                            final meta =
                                _lessonData[key] as Map<String, dynamic>?;
                            final color = _colorFor(i);
                            final lessonCount =
                                (meta?['lessons'] as List?)?.length ?? 0;

                            return _TopicListCard(
                              topic: topic,
                              meta: meta,
                              color: color,
                              lessonCount: lessonCount,
                              icon: _iconFor(topic),
                              index: i,
                              onTap: () =>
                                  setState(() => _selectedTopic = topic),
                            );
                          },
                          childCount: topics.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  int _totalLessons(List<String> topics) {
    int count = 0;
    for (final t in topics) {
      final key = _normaliseKey(t);
      count += (_lessonData[key]?['lessons'] as List?)?.length ?? 0;
    }
    return count;
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 64, color: AppTheme.textMuted.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No topics found',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
        ],
      ),
    );
  }
}

// ─── Topic List Card ────────────────────────────────────────────────────────
class _TopicListCard extends StatefulWidget {
  final String topic;
  final Map<String, dynamic>? meta;
  final Color color;
  final int lessonCount;
  final IconData icon;
  final int index;
  final VoidCallback onTap;

  const _TopicListCard({
    required this.topic,
    required this.meta,
    required this.color,
    required this.lessonCount,
    required this.icon,
    required this.index,
    required this.onTap,
  });

  @override
  State<_TopicListCard> createState() => _TopicListCardState();
}

class _TopicListCardState extends State<_TopicListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 55),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                children: [
                  // Colour top bar
                  Container(height: 4, color: widget.color),
                  // Card body
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(widget.icon,
                              color: widget.color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.meta?['title'] ?? widget.topic,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.meta?['desc'] ?? 'Tap to explore',
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.lessonCount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: widget.color
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${widget.lessonCount} lesson${widget.lessonCount > 1 ? 's' : ''}',
                                        style: TextStyle(
                                            color: widget.color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: AppTheme.textMuted, size: 15),
                      ],
                    ),
                  ),
                  // Bottom accent border
                  Container(
                    height: 1,
                    color: AppTheme.border,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stat Chip ──────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Topic Detail View ──────────────────────────────────────────────────────
class _TopicDetailView extends StatelessWidget {
  final String topic;
  final Map<String, dynamic> lessonData;
  final Color color;
  final VoidCallback onBack;
  final void Function(String) onPractice;

  const _TopicDetailView({
    required this.topic,
    required this.lessonData,
    required this.color,
    required this.onBack,
    required this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    final key = topic.toLowerCase().replaceAll(' ', '_');
    final meta = lessonData[key] as Map<String, dynamic>?;
    final lessons = (meta?['lessons'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            // ── Hero SliverAppBar ──
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: AppTheme.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.25),
                            AppTheme.surface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 52,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                            ),
                            child: Icon(
                              _iconForTopic(topic),
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meta?['title'] ?? topic,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      color: AppTheme.text),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  meta?['desc'] ?? '',
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // ── Pinned Tab Bar ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  indicatorColor: color,
                  labelColor: color,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Lessons'),
                    Tab(text: 'Practice'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // ── Lessons Tab ──
              lessons.isEmpty
                  ? _emptyLessons()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: lessons.length,
                      itemBuilder: (ctx, i) {
                        return _LessonCard(
                          lesson: lessons[i] as Map<String, dynamic>,
                          color: color,
                          index: i,
                        );
                      },
                    ),
              // ── Practice Tab ──
              _PracticeTab(topic: topic, color: color, onPractice: onPractice),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyLessons() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 56, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text('No lessons yet',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
        ],
      ),
    );
  }

  IconData _iconForTopic(String t) {
    const icons = <String, IconData>{
      'algebra': Icons.superscript,
      'calculus': Icons.all_inclusive,
      'trigonometry': Icons.architecture,
      'statistics': Icons.query_stats,
      'probability': Icons.casino,
      'finance': Icons.monetization_on,
      'functions': Icons.show_chart,
      'analytical_geometry': Icons.straighten,
      'euclidean_geometry': Icons.category,
      'patterns': Icons.format_list_numbered,
    };
    final lower = t.toLowerCase().replaceAll(' ', '_');
    for (final e in icons.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return Icons.school_outlined;
  }
}

// ─── Practice Tab ───────────────────────────────────────────────────────────
class _PracticeTab extends StatelessWidget {
  final String topic;
  final Color color;
  final void Function(String) onPractice;

  const _PracticeTab(
      {required this.topic, required this.color, required this.onPractice});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Practice card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: 4,
                )
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: const Icon(Icons.quiz_outlined,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 20),
                const Text('Ready to practice?',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 10),
                const Text(
                  'Test your knowledge with topic-specific exam-style questions.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => onPractice(topic),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Practice Session'),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Mastery Workshop hint
          _MasteryWorkshopBanner(),
        ],
      ),
    );
  }
}

// ─── Mastery Workshop Banner ─────────────────────────────────────────────────
class _MasteryWorkshopBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mastery Workshop',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFFF59E0B))),
                SizedBox(height: 2),
                Text(
                  'Step-by-step annotated solutions for exam mastery',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lesson Card ─────────────────────────────────────────────────────────────
class _LessonCard extends StatefulWidget {
  final Map<String, dynamic> lesson;
  final Color color;
  final int index;

  const _LessonCard(
      {required this.lesson, required this.color, required this.index});

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _expandAnim =
        CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandCtrl.forward();
    } else {
      _expandCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final steps = (lesson['steps'] as List<dynamic>?) ?? [];
    final formula = lesson['formula'] as Map<String, dynamic>?;
    final formulaTex = formula?['tex'] as String?;
    final formulaLabel = formula?['label'] as String?;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + widget.index * 70),
      curve: Curves.easeOutCubic,
      builder: (ctx, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(offset: Offset(0, 16 * (1 - val)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Colour accent bar
                    Container(
                      width: 5,
                      height: 38,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Lesson number badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: TextStyle(
                              color: widget.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textMuted, size: 22),
                    ),
                  ],
                ),
              ),
            ),
            // ── Expandable Body ───────────────────────────────────────
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppTheme.border, height: 1),
                    const SizedBox(height: 14),
                    // Formula box
                    if (formulaTex != null && formulaTex.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: widget.color.withValues(alpha: 0.35),
                              width: 1.5),
                        ),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Math.tex(
                                _cleanTex(formulaTex),
                                textStyle: const TextStyle(
                                    fontSize: 17, color: AppTheme.text),
                              ),
                            ),
                            if (formulaLabel != null &&
                                formulaLabel.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                formulaLabel,
                                style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                    // Explanation
                    if ((lesson['explanation'] ?? '').isNotEmpty) ...[
                      Text(
                        lesson['explanation'] ?? '',
                        style: const TextStyle(
                            color: AppTheme.textSubtle,
                            fontSize: 13,
                            height: 1.6),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Steps
                    if (steps.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.format_list_numbered_rounded,
                              color: widget.color, size: 16),
                          const SizedBox(width: 6),
                          Text('Step-by-Step',
                              style: TextStyle(
                                  color: widget.color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...steps.asMap().entries.map((entry) {
                        final step = entry.value as Map<String, dynamic>;
                        return _StepItem(
                          step: step,
                          number: entry.key + 1,
                          color: widget.color,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Strip surrounding \[ \] or $$ that KaTeX adds but flutter_math needs bare
  String _cleanTex(String tex) {
    var t = tex.trim();
    if (t.startsWith(r'\[') && t.endsWith(r'\]')) {
      t = t.substring(2, t.length - 2).trim();
    } else if (t.startsWith(r'$$') && t.endsWith(r'$$')) {
      t = t.substring(2, t.length - 2).trim();
    }
    return t;
  }
}

// ─── Step Item ───────────────────────────────────────────────────────────────
class _StepItem extends StatelessWidget {
  final Map<String, dynamic> step;
  final int number;
  final Color color;

  const _StepItem(
      {required this.step, required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    final tex = step['tex'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number bubble
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$number',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11)),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step['desc'] ?? '',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text)),
                if (tex != null && tex.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: color.withValues(alpha: 0.2)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        tex,
                        textStyle: TextStyle(
                            fontSize: 14, color: color),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sliver Tab Bar Delegate ─────────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext ctx, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate old) => false;
}

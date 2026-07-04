
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/discovery_service.dart';
import '../services/daily_challenge_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress.dart';
import '../theme/app_theme.dart';
import '../widgets/discovery_overlay.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _statsKey = GlobalKey();
  final GlobalKey _practiceKey = GlobalKey();
  final GlobalKey _vaultKey = GlobalKey();
  final GlobalKey _errorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDiscoveryTour();
    });
  }

  void _startDiscoveryTour() {
    final discovery = context.read<DiscoveryService>();
    discovery.init().then((_) {
      if (!discovery.isCompleted) {
        discovery.startTour([
          DiscoveryStep(
            title: "Track Your Mastery",
            body:
                "Monitor your XP, streak, and overall syllabus progress here. Consistency is key to a distinction!",
            targetKey: _statsKey,
            icon: Icons.trending_up,
          ),
          DiscoveryStep(
            title: "Targeted Practice",
            body:
                "Access 3000+ questions organized by topic. We track your accuracy for each section.",
            targetKey: _practiceKey,
            icon: Icons.quiz_outlined,
          ),
          DiscoveryStep(
            title: "Your Growth Engine",
            body:
                "Every mistake you make is saved here automatically. Reviewing these regularly is the fastest way to improve.",
            targetKey: _vaultKey,
            icon: Icons.lock_reset_rounded,
          ),
          DiscoveryStep(
            title: "Spot the Error",
            body:
                "Learn from the examiner's perspective. Find the mistakes in derivations to master the logic.",
            targetKey: _errorKey,
            icon: Icons.search_off_rounded,
          ),
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AuthService>(); // refresh on auth changes
    final discovery = context.watch<DiscoveryService>();
    final isWide = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          StreamBuilder<UserProgress?>(
            stream: context.read<FirestoreService>().watchUserProgress(),
            builder: (context, snap) {
              final progress = snap.data;
              final totalAttempted = progress?.topics.values.fold<int>(0, (s, t) => s + t.questionsAttempted) ?? 0;
              final totalCorrect = progress?.topics.values.fold<int>(0, (s, t) => s + t.questionsCorrect) ?? 0;
              final accuracy = totalAttempted > 0 ? ((totalCorrect / totalAttempted) * 100).toInt() : 0;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Broadcasts
                        _buildBroadcastFeed(),

                        // ─── Search Bar ───────────────────────────────────
                        _AnimateIn(
                          delay: 0,
                          child: _SearchBar(
                            onSearch: (q) => context.go('/topics'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── 4-Ring Stats Panel ───────────────────────────
                        _AnimateIn(
                          delay: 60,
                          child: Container(
                            key: _statsKey,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.border),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: isWide
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _RingStatItem(
                                        label: 'Correct',
                                        value: '$totalCorrect',
                                        percent: totalAttempted > 0
                                            ? (totalCorrect / totalAttempted).clamp(0.0, 1.0)
                                            : 0.0,
                                        ringColor: AppTheme.success,
                                        iconBg: AppTheme.success.withValues(alpha: 0.15),
                                        iconColor: AppTheme.success,
                                        icon: Icons.check_circle_outline,
                                      ),
                                    ),
                                    Expanded(
                                      child: _RingStatItem(
                                        label: 'Attempted',
                                        value: '$totalAttempted',
                                        percent: totalAttempted > 0
                                            ? (totalAttempted / (totalAttempted + 100)).clamp(0.0, 1.0)
                                            : 0.0,
                                        ringColor: AppTheme.primary,
                                        iconBg: AppTheme.primary.withValues(alpha: 0.15),
                                        iconColor: AppTheme.primary,
                                        icon: Icons.edit_outlined,
                                      ),
                                    ),
                                    Expanded(
                                      child: _RingStatItem(
                                        label: 'Accuracy',
                                        value: '$accuracy%',
                                        percent: accuracy / 100.0,
                                        ringColor: const Color(0xFF6366F1),
                                        iconBg: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                        iconColor: const Color(0xFF6366F1),
                                        icon: Icons.gps_fixed,
                                      ),
                                    ),
                                    Expanded(
                                      child: _RingStatItem(
                                        label: 'Badges',
                                        value: '${progress?.badges.length ?? 0}',
                                        percent: (progress?.badges.length ?? 0) > 0
                                            ? ((progress!.badges.length) / 20.0).clamp(0.0, 1.0)
                                            : 0.0,
                                        ringColor: AppTheme.warning,
                                        iconBg: AppTheme.warning.withValues(alpha: 0.15),
                                        iconColor: AppTheme.warning,
                                        icon: Icons.military_tech_outlined,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _RingStatItem(
                                            label: 'Correct',
                                            value: '$totalCorrect',
                                            percent: totalAttempted > 0
                                                ? (totalCorrect / totalAttempted).clamp(0.0, 1.0)
                                                : 0.0,
                                            ringColor: AppTheme.success,
                                            iconBg: AppTheme.success.withValues(alpha: 0.15),
                                            iconColor: AppTheme.success,
                                            icon: Icons.check_circle_outline,
                                          ),
                                        ),
                                        Expanded(
                                          child: _RingStatItem(
                                            label: 'Attempted',
                                            value: '$totalAttempted',
                                            percent: totalAttempted > 0
                                                ? (totalAttempted / (totalAttempted + 100)).clamp(0.0, 1.0)
                                                : 0.0,
                                            ringColor: AppTheme.primary,
                                            iconBg: AppTheme.primary.withValues(alpha: 0.15),
                                            iconColor: AppTheme.primary,
                                            icon: Icons.edit_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _RingStatItem(
                                            label: 'Accuracy',
                                            value: '$accuracy%',
                                            percent: accuracy / 100.0,
                                            ringColor: const Color(0xFF6366F1),
                                            iconBg: const Color(0xFF6366F1).withValues(alpha: 0.15),
                                            iconColor: const Color(0xFF6366F1),
                                            icon: Icons.gps_fixed,
                                          ),
                                        ),
                                        Expanded(
                                          child: _RingStatItem(
                                            label: 'Badges',
                                            value: '${progress?.badges.length ?? 0}',
                                            percent: (progress?.badges.length ?? 0) > 0
                                                ? ((progress!.badges.length) / 20.0).clamp(0.0, 1.0)
                                                : 0.0,
                                            ringColor: AppTheme.warning,
                                            iconBg: AppTheme.warning.withValues(alpha: 0.15),
                                            iconColor: AppTheme.warning,
                                            icon: Icons.military_tech_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Two-column layout on wide screens ────────────
                        _AnimateIn(
                          delay: 120,
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Main column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildTopicsSection(context),
                                          const SizedBox(height: 24),
                                          _AnimateIn(delay: 400, child: _BadgesSection(progress: progress)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Right sidebar
                                    SizedBox(
                                      width: 360,
                                      child: Column(
                                        children: [
                                          _buildDailyChallenge(context),
                                          const SizedBox(height: 16),
                                          _buildLeaderboardCard(context),
                                          const SizedBox(height: 16),
                                          _buildExamModeCard(context),
                                          const SizedBox(height: 16),
                                          _buildWeakAreasCard(context, progress),
                                          const SizedBox(height: 16),
                                          _buildRecommendedLessonsCard(context, progress),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDailyChallenge(context),
                                    const SizedBox(height: 16),
                                    _buildTopicsSection(context),
                                    const SizedBox(height: 16),
                                    _buildLeaderboardCard(context),
                                    const SizedBox(height: 16),
                                    _buildExamModeCard(context),
                                    const SizedBox(height: 16),
                                    _buildWeakAreasCard(context, progress),
                                    const SizedBox(height: 16),
                                    _buildRecommendedLessonsCard(context, progress),
                                    const SizedBox(height: 24),
                                    _AnimateIn(delay: 400, child: _BadgesSection(progress: progress)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 24),
                        _buildSupportCard(context),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),

          // Discovery Overlay
          if (discovery.isTourActive && discovery.currentStep != null)
            DiscoveryOverlay(
              targetKey: discovery.currentStep!.targetKey,
              title: discovery.currentStep!.title,
              body: discovery.currentStep!.body,
              icon: discovery.currentStep!.icon,
              onNext: discovery.next,
              onSkip: discovery.skip,
              isLastStep:
                  discovery.currentStepIndex == discovery.steps.length - 1,
            ),
        ],
      ),
    );
  }

  // ─── Topics grid (mirrors web's topicsGrid) ────────────────────────────────
  static const List<Map<String, dynamic>> _topicsData = [
    {'id': 'algebra',             'title': 'Algebra',         'desc': 'Equations, inequalities, sequences and series', 'color': Color(0xFF4F46E5)}, // --primary
    {'id': 'patterns',            'title': 'Patterns',        'desc': 'Arithmetic & Geometric number patterns',        'color': Color(0xFF6366F1)}, // --secondary
    {'id': 'functions',           'title': 'Functions',       'desc': 'Graphs, inverses, transformations',             'color': Color(0xFF10B981)}, // --accent-green
    {'id': 'finance',             'title': 'Finance',         'desc': 'Annuities, loans, sinking funds, and decay',    'color': Color(0xFFF59E0B)}, // --accent-amber
    {'id': 'trigonometry',        'title': 'Trigonometry',    'desc': 'Identities, equations, sine and cosine rules',  'color': Color(0xFF818CF8)}, // --primary-light
    {'id': 'analytical_geometry', 'title': 'Analytical Geom', 'desc': 'Circles, tangents, and coordinate geometry',    'color': Color(0xFF4338CA)}, // --primary-dark
    {'id': 'euclidean_geometry',  'title': 'Euclidean Geom',  'desc': 'Circle theorems and proportionality',           'color': Color(0xFF059669)}, // emerald-600
    {'id': 'calculus',            'title': 'Calculus',        'desc': 'Limits, derivatives, and rates of change',      'color': Color(0xFFEF4444)}, // --accent-red
    {'id': 'probability',         'title': 'Probability',     'desc': 'Counting, Venn diagrams, and rules',            'color': Color(0xFFF59E0B)}, // --accent-amber
    {'id': 'statistics',          'title': 'Statistics',      'desc': 'Regression, correlation, and distributions',    'color': Color(0xFF0EA5E9)}, // sky-500 (no CSS var)
  ];

  static const Map<String, IconData> _topicIcons = {
    'algebra':             Icons.superscript,
    'patterns':            Icons.format_list_numbered,
    'functions':           Icons.show_chart,
    'finance':             Icons.monetization_on,
    'trigonometry':        Icons.architecture,
    'analytical_geometry': Icons.straighten,
    'euclidean_geometry':  Icons.category,
    'calculus':            Icons.all_inclusive,
    'probability':         Icons.casino,
    'statistics':          Icons.query_stats,
  };

  Widget _buildTopicsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Topics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Select a topic to start learning and practising.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (ctx, constraints) {
            final isMobile = constraints.maxWidth <= 600;
            if (isMobile) {
              return ListView.separated(
                key: _practiceKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _topicsData.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final t = _topicsData[i];
                  final color = t['color'] as Color;
                  final id = t['id'] as String;
                  return _TopicCard(
                    title: t['title'] as String,
                    desc: t['desc'] as String,
                    icon: _topicIcons[id] ?? Icons.school_outlined,
                    color: color,
                    onTap: () => context.go('/practice?topic=$id'),
                  );
                },
              );
            }
            final cols = constraints.maxWidth > 850 ? 3 : 2;
            return GridView.builder(
              key: _practiceKey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: _topicsData.length,
              itemBuilder: (ctx, i) {
                final t = _topicsData[i];
                final color = t['color'] as Color;
                final id = t['id'] as String;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 300 + i * 50),
                  curve: Curves.easeOutCubic,
                  builder: (c, v, child) => Opacity(opacity: v, child: child),
                  child: _TopicCard(
                    title: t['title'] as String,
                    desc: t['desc'] as String,
                    icon: _topicIcons[id] ?? Icons.school_outlined,
                    color: color,
                    onTap: () => context.go('/practice?topic=$id'),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ─── Leaderboard sidebar card ──────────────────────────────────────────────
  Widget _buildLeaderboardCard(BuildContext context) {
    return _SidebarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFf59e0b), size: 20),
              const SizedBox(width: 8),
              Text('Top Students', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              const Icon(Icons.local_fire_department, color: Color(0xFFf59e0b), size: 16),
              const SizedBox(width: 4),
              Text('Streaks', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: context.read<FirestoreService>().watchTopStudents(limit: 5),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('No data yet', style: TextStyle(color: AppTheme.textMuted))),
                );
              }
              return Column(
                children: snap.data!.asMap().entries.map((e) {
                  final rank = e.key + 1;
                  final u = e.value;
                  return _LeaderboardRow(
                    rank: rank,
                    name: u['displayName'] ?? 'Student',
                    score: u['totalXp'] ?? 0,
                    streak: u['streak'] ?? 0,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.go('/leaderboard'),
              child: const Text('View Full Leaderboard'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Exam Mode card ────────────────────────────────────────────────────────
  Widget _buildExamModeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.timer_outlined, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text('Exam Mode', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          const Text(
            'Simulate real NSC conditions. Timed Paper 1 or Paper 2 with auto-submit.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Start Exam'),
              onPressed: () => context.go('/exam'),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Weak Areas card ───────────────────────────────────────────────────────
  Widget _buildWeakAreasCard(BuildContext context, UserProgress? progress) {
    final weakTopics = progress?.topics.entries
        .where((e) => e.value.questionsAttempted > 0 && (e.value.questionsCorrect / e.value.questionsAttempted) < 0.6)
        .toList() ?? [];

    return _SidebarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFef4444), size: 18),
            const SizedBox(width: 8),
            Text('Weak Areas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          if (weakTopics.isEmpty)
            const Text(
              'Complete some practice to see weak areas here.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            )
          else
            ...weakTopics.take(4).map((e) {
              final pct = (e.value.questionsCorrect / e.value.questionsAttempted * 100).toInt();
              return _WeakAreaRow(topic: e.key, accuracy: pct);
            }),
        ],
      ),
    );
  }

  // ─── Recommended Lessons card ──────────────────────────────────────────────
  Widget _buildRecommendedLessonsCard(BuildContext context, UserProgress? progress) {
    return _SidebarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.play_circle_outline, color: Color(0xFFef4444), size: 18),
            const SizedBox(width: 8),
            Text('Recommended Lessons', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 12),
          const Text(
            'Complete some practice to get personalised video recommendations.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }



  Widget _buildDailyChallenge(BuildContext context) {
    final dailyService = context.watch<DailyChallengeService>();
    final firestore = context.read<FirestoreService>();

    return StreamBuilder<UserProgress?>(
      stream: firestore.watchUserProgress(),
      builder: (context, snapshot) {
        final progress = snapshot.data;
        final now = DateTime.now();
        final hasDoneToday =
            progress?.lastDailyDate != null &&
            progress!.lastDailyDate!.year == now.year &&
            progress.lastDailyDate!.month == now.month &&
            progress.lastDailyDate!.day == now.day;

        if (hasDoneToday) return const SizedBox.shrink();

        return _SidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.bolt, color: Color(0xFFf59e0b), size: 20),
                    const SizedBox(width: 8),
                    Text('Daily Challenge',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf59e0b).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasDoneToday ? 'Done ✓' : 'New',
                      style: const TextStyle(
                        color: Color(0xFFf59e0b),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (dailyService.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (dailyService.currentQuestion != null) ...[
                // Question preview in a code-block style box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: AppTheme.primary, width: 4),
                    ),
                  ),
                  child: Text(
                    dailyService.currentQuestion!.question,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, height: 1.6),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Answer Now'),
                    onPressed: () => _showDailyDialog(context, dailyService, firestore),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf59e0b),
                    ),
                  ),
                ),
              ] else
                const Text('No challenge available today.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }


  void _showDailyDialog(
    BuildContext context,
    DailyChallengeService service,
    FirestoreService firestore,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer<DailyChallengeService>(
        builder: (context, svc, _) {
          final q = svc.currentQuestion;
          if (q == null) return const SizedBox.shrink();

          return AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text('Daily Challenge'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(q.question, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ...List.generate(q.options.length, (i) {
                  final isAnswered = svc.isAnswered;
                  final isCorrect = i == q.correctIndex;
                  final isSelected = i == svc.selectedOption;

                  Color btnColor = AppTheme.surface;
                  if (isAnswered) {
                    if (isCorrect) {
                      btnColor = AppTheme.success.withValues(alpha: 0.2);
                    } else if (isSelected) {
                      btnColor = AppTheme.error.withValues(alpha: 0.2);
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: isAnswered ? null : () => svc.submitAnswer(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAnswered && isCorrect
                                ? AppTheme.success
                                : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              String.fromCharCode(65 + i),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(q.options[i])),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            actions: [
              if (svc.isAnswered)
                TextButton(
                  onPressed: () {
                    final xp = svc.isCorrect! ? 20 : 0;
                    firestore
                        .updateTopicProgress(
                          topic: 'daily',
                          attempted: 1,
                          correct: svc.isCorrect! ? 1 : 0,
                          total: 1,
                          xpEarned: xp,
                        )
                        .then((_) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(firestore.uid)
                              .update({
                                'lastDailyDate': FieldValue.serverTimestamp(),
                              });
                        });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Finish'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBroadcastFeed() {
    final firestore = context.read<FirestoreService>();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.watchActiveBroadcasts(),
      builder: (context, snapshot) {
        final broadcasts = snapshot.data ?? [];
        if (broadcasts.isEmpty) return const SizedBox.shrink();

        return Column(
          children: broadcasts.map((b) {
            Color color;
            IconData icon;
            switch (b['type']) {
              case 'warning':
                color = AppTheme.warning;
                icon = Icons.warning_amber_rounded;
                break;
              case 'alert':
                color = AppTheme.error;
                icon = Icons.notification_important_rounded;
                break;
              default:
                color = AppTheme.primary;
                icon = Icons.info_outline_rounded;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b['title'] ?? 'Announcement',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b['body'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return _AnimateIn(
      delay: 900,
      child: Container(
        margin: const EdgeInsets.only(bottom: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Found a bug?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Help us improve the app.',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/support'),
              child: const Text(
                'HELP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _showReportModal(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              child: const Text(
                'REPORT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportModal(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Report an Issue',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please describe what happened.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'e.g., The calculus quiz crashed when I tapped finish...',
                  fillColor: AppTheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  await context.read<FirestoreService>().submitBugReport(
                    description: controller.text,
                    source: 'Dashboard FAB',
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted! Thank you.'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Submit Report',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

}

class _AnimateIn extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimateIn({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ──────────────── BADGES ────────────────
class _BadgesSection extends StatelessWidget {
  final UserProgress? progress;
  const _BadgesSection({this.progress});

  static const List<Map<String, Object>> _allBadges = [
    {
      'id': 'first_correct',
      'label': 'First Blood',
      'icon': Icons.emoji_events_rounded,
      'desc': 'Answer your first question correctly',
    },
    {
      'id': 'streak_3',
      'label': '3-Day Streak',
      'icon': Icons.local_fire_department_rounded,
      'desc': 'Maintain a 3-day streak',
    },
    {
      'id': 'streak_7',
      'label': 'Weekly Warrior',
      'icon': Icons.auto_awesome_rounded,
      'desc': 'Maintain a 7-day streak',
    },
    {
      'id': 'xp_100',
      'label': 'XP Hunter',
      'icon': Icons.star_border_rounded,
      'desc': 'Earn 100 XP',
    },
    {
      'id': 'xp_500',
      'label': 'XP Master',
      'icon': Icons.star_rounded,
      'desc': 'Earn 500 XP',
    },
    {
      'id': 'topics_3',
      'label': 'Explorer',
      'icon': Icons.explore_rounded,
      'desc': 'Practice 3 topics',
    },
    {
      'id': 'accuracy_80',
      'label': 'Sharpshooter',
      'icon': Icons.speed_rounded,
      'desc': '80% accuracy (10+ Qs)',
    },
    {
      'id': 'vault_5',
      'label': 'Growth Mindset',
      'icon': Icons.shield_rounded,
      'desc': '5 mistakes in Vault',
    },
  ];

  static List<Map<String, dynamic>> _computeBadges(UserProgress? p) {
    if (p == null) {
      return _allBadges.map((b) => {...b, 'earned': false}).toList();
    }

    final attempted = p.topics.values.fold<int>(
      0,
      (s, t) => s + t.questionsAttempted,
    );
    final correct = p.topics.values.fold<int>(
      0,
      (s, t) => s + t.questionsCorrect,
    );
    final accuracy = attempted > 0 ? correct / attempted : 0.0;
    final topicsPractised = p.topics.values
        .where((t) => t.questionsAttempted > 0)
        .length;

    return _allBadges.map((b) {
      bool earned = false;
      switch (b['id']) {
        case 'first_correct':
          earned = correct > 0;
          break;
        case 'streak_3':
          earned = p.streak >= 3;
          break;
        case 'streak_7':
          earned = p.streak >= 7;
          break;
        case 'xp_100':
          earned = p.totalXp >= 100;
          break;
        case 'xp_500':
          earned = p.totalXp >= 500;
          break;
        case 'topics_3':
          earned = topicsPractised >= 3;
          break;
        case 'accuracy_80':
          earned = accuracy >= 0.8 && attempted >= 10;
          break;
        case 'vault_5':
          earned = p.mistakeVault.length >= 5;
          break;
      }
      return {...b, 'earned': earned};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final badges = _computeBadges(progress);
    final earned = badges.where((b) => b['earned'] == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Badges', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '$earned / ${badges.length}',
                style: const TextStyle(
                  color: AppTheme.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: badges.map((b) {
              final isEarned = b['earned'] == true;
              final iconData = b['icon'] as IconData;
              return Tooltip(
                message: '${b['label']}: ${b['desc']}',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isEarned
                        ? AppTheme.warning.withValues(alpha: 0.15)
                        : AppTheme.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEarned
                          ? AppTheme.warning.withValues(alpha: 0.4)
                          : AppTheme.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        iconData,
                        color: isEarned
                            ? AppTheme.warning
                            : AppTheme.textMuted.withValues(alpha: 0.3),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isEarned
                              ? AppTheme.warning
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar Widget ────────────────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  const _SearchBar({required this.onSearch});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search topics, videos, formulas...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onSubmitted: widget.onSearch,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 20),
            color: AppTheme.primary,
            onPressed: () => widget.onSearch(_controller.text),
          ),
        ],
      ),
    );
  }
}

// ─── 4-Ring Stat Item ─────────────────────────────────────────────────────────
class _RingStatItem extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color ringColor;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;

  const _RingStatItem({
    required this.label,
    required this.value,
    required this.percent,
    required this.ringColor,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context2, v, ignored) => CustomPaint(
                    painter: _RingPainter(progress: v, color: ringColor),
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: AppTheme.textMuted, letterSpacing: 0.5)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 3;
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const startAngle = -1.5708;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, 6.2832, false, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, 6.2832 * progress, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Topic Card ───────────────────────────────────────────────────────────────
class _TopicCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopicCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
              ],
            ),
            const Spacer(),
            Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(desc,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ─── Sidebar Card wrapper ─────────────────────────────────────────────────────
class _SidebarCard extends StatelessWidget {
  final Widget child;
  const _SidebarCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

// ─── Leaderboard Row ──────────────────────────────────────────────────────────
class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final int streak;

  const _LeaderboardRow({
    required this.rank,
    required this.name,
    required this.score,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final medals = ['🥇', '🥈', '🥉'];
    final rankLabel = rank <= 3 ? medals[rank - 1] : '$rank';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(rankLabel, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),
          const SizedBox(width: 10),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$score XP', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 14)),
              Row(children: [
                const Icon(Icons.local_fire_department, size: 12, color: Color(0xFFf59e0b)),
                Text(' $streak', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Weak Area Row ────────────────────────────────────────────────────────────
class _WeakAreaRow extends StatelessWidget {
  final String topic;
  final int accuracy;

  const _WeakAreaRow({required this.topic, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final display = topic.replaceAll('_', ' ').split(' ').map((w) =>
        w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w).join(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFef4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber, color: Color(0xFFef4444), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(display, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('$accuracy% accuracy', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 60,
              height: 6,
              child: LinearProgressIndicator(
                value: accuracy / 100.0,
                backgroundColor: AppTheme.border,
                color: accuracy < 40 ? const Color(0xFFef4444) : const Color(0xFFf59e0b),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
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
    final auth = context.watch<AuthService>();
    final discovery = context.watch<DiscoveryService>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('TotalSkillz'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => context.push('/admin'),
              tooltip: 'Admin',
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) context.go('/login');
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<UserProgress?>(
            stream: context.read<FirestoreService>().watchUserProgress(),
            builder: (context, snap) {
              final progress = snap.data;
              final name = user?.displayName ?? 'Student';
              final firstName = name.split(' ').first;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Greeting
                        _AnimateIn(
                          delay: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $firstName 👋',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ready to ace Grade 12?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildDailyChallenge(context),
                        const SizedBox(height: 24),

                        _buildSectionHeader(
                          'Your Academy',
                          onSeeAll: () => context.push('/leaderboard'),
                        ),
                        const SizedBox(height: 16),

                        _buildBroadcastFeed(),
                        const SizedBox(height: 24),

                        // Stats Card
                        _AnimateIn(
                          delay: 100,
                          child: Container(
                            key: _statsKey,
                            child: Row(
                              children: [
                                _StatCard(
                                  label: 'XP Earned',
                                  value: '${progress?.totalXp ?? 0}',
                                  icon: Icons.star,
                                  color: AppTheme.warning,
                                ),
                                const SizedBox(width: 12),
                                _StatCard(
                                  label: 'Day Streak',
                                  value: '${progress?.streak ?? 0}',
                                  icon: Icons.local_fire_department,
                                  color: AppTheme.error,
                                ),
                                const SizedBox(width: 12),
                                _StatCard(
                                  label: 'Progress',
                                  value:
                                      '${((progress?.overallProgress ?? 0) * 100).toInt()}%',
                                  icon: Icons.trending_up,
                                  color: AppTheme.success,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Accuracy & Attempted Rings
                        _AnimateIn(
                          delay: 150,
                          child: _StatsRingsRow(progress: progress),
                        ),
                        const SizedBox(height: 16),

                        // Overall progress bar
                        _AnimateIn(
                          delay: 200,
                          child: _ProgressSection(progress: progress),
                        ),
                        const SizedBox(height: 20),

                        // Exam Countdown
                        _AnimateIn(
                          delay: 220,
                          child: _ExamCountdown(progress: progress),
                        ),
                        const SizedBox(height: 28),

                        _buildPremiumBanner(context),
                        const SizedBox(height: 28),

                        // Quick actions grid
                        _AnimateIn(
                          delay: 300,
                          child: Text(
                            'Learning Pathways',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: [
                            _QuickCard(
                              key: _practiceKey,
                              icon: Icons.quiz_outlined,
                              label: 'Practice',
                              subtitle: 'Topic quizzes',
                              color: AppTheme.primary,
                              onTap: () => context.push('/topics'),
                              delay: 400,
                            ),
                            _QuickCard(
                              key: _vaultKey,
                              icon: Icons.lock_reset_rounded,
                              label: 'Mistake Vault',
                              subtitle:
                                  '${progress?.mistakeVault.length ?? 0} items',
                              color: AppTheme.error,
                              onTap: () => context.push('/vault'),
                              delay: 500,
                            ),
                            _QuickCard(
                              key: _errorKey,
                              icon: Icons.search_off_rounded,
                              label: 'Spot the Error',
                              subtitle: 'Examiner logic',
                              color: AppTheme.success,
                              onTap: () => context.push('/examiner'),
                              delay: 600,
                            ),
                            _QuickCard(
                              icon: Icons.functions,
                              label: 'Formulas',
                              subtitle: 'Cheat sheet',
                              color: AppTheme.accent,
                              onTap: () => context.push('/formulas'),
                              delay: 700,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _AnimateIn(
                          delay: 800,
                          child: _QuickCard(
                            icon: Icons.picture_as_pdf_outlined,
                            label: 'Past Papers',
                            subtitle: 'Official Documents',
                            color: AppTheme.warning,
                            onTap: () => context.push('/vault'),
                            delay: 0,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Badges Section
                        _AnimateIn(
                          delay: 850,
                          child: _BadgesSection(progress: progress),
                        ),
                        const SizedBox(height: 24),
                        _buildSupportCard(context),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 1) context.push('/topics');
          if (i == 2) context.push('/formulas');
          if (i == 3) context.push('/vault');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.topic_outlined),
            label: 'Topics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.functions),
            label: 'Formulas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            label: 'Vault',
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

        if (hasDoneToday) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.success.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success),
                SizedBox(width: 12),
                Text(
                  'Daily Challenge Completed!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        if (dailyService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final q = dailyService.currentQuestion;
        if (q == null) return const SizedBox.shrink();

        return _QuickCard(
          label: 'Daily Challenge',
          subtitle: 'Boost your streak and earn 20 XP!',
          icon: Icons.bolt,
          color: Colors.amber,
          onTap: () {
            _showDailyDialog(context, dailyService, firestore);
          },
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

  Widget _buildPremiumBanner(BuildContext context) {
    return _AnimateIn(
      delay: 250,
      child: GestureDetector(
        onTap: () => context.push('/live-classes'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GO FOR DISTINCTION',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Book a Live Expert Session',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Direct 1-on-1 tutoring via Classroom.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.stars_rounded, color: Colors.white, size: 48),
            ],
          ),
        ),
      ),
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

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final UserProgress? progress;
  const _ProgressSection({this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = progress?.overallProgress ?? 0.0;
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
              Text(
                'Overall Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${(pct * 100).toInt()}%',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppTheme.surface2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _QuickCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.delay = 0,
  });

  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return _AnimateIn(
      delay: widget.delay,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered
                    ? widget.color.withValues(alpha: 0.5)
                    : AppTheme.border,
              ),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────── STATS RINGS ────────────────
class _StatsRingsRow extends StatelessWidget {
  final UserProgress? progress;
  const _StatsRingsRow({this.progress});

  @override
  Widget build(BuildContext context) {
    final attempted =
        progress?.topics.values.fold<int>(
          0,
          (s, t) => s + t.questionsAttempted,
        ) ??
        0;
    final correct =
        progress?.topics.values.fold<int>(
          0,
          (s, t) => s + t.questionsCorrect,
        ) ??
        0;
    final accuracy = attempted > 0 ? (correct / attempted * 100).round() : 0;
    final badgeCount = _BadgesSection._computeBadges(
      progress,
    ).where((b) => b['earned'] == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RingItem(
            label: 'Correct',
            value: correct,
            max: 50,
            color: AppTheme.success,
          ),
          _RingItem(
            label: 'Attempted',
            value: attempted,
            max: 100,
            color: AppTheme.primary,
          ),
          _RingItem(
            label: 'Accuracy',
            value: accuracy,
            max: 100,
            color: AppTheme.accent,
            suffix: '%',
          ),
          _RingItem(
            label: 'Badges',
            value: badgeCount,
            max: 8,
            color: AppTheme.warning,
          ),
        ],
      ),
    );
  }
}

class _RingItem extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final String suffix;
  const _RingItem({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: pct),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (ctx, val, _) => Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: val,
                  strokeWidth: 4,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text(
                  '$value$suffix',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

// ──────────────── EXAM COUNTDOWN ────────────────
class _ExamCountdown extends StatelessWidget {
  final UserProgress? progress;
  const _ExamCountdown({this.progress});

  @override
  Widget build(BuildContext context) {
    final examDate = progress?.settings.examDate;
    if (examDate == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Set your exam date in Settings to see a countdown.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/settings'),
              child: const Text(
                'SET',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final daysLeft = examDate.difference(DateTime.now()).inDays;
    final isPast = daysLeft < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPast
              ? [AppTheme.error.withValues(alpha: 0.15), AppTheme.surface]
              : [AppTheme.primary.withValues(alpha: 0.15), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast
              ? AppTheme.error.withValues(alpha: 0.3)
              : AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isPast ? AppTheme.error : AppTheme.primary).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  isPast ? '0' : '$daysLeft',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isPast ? AppTheme.error : AppTheme.primary,
                  ),
                ),
                Text(
                  'DAYS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isPast ? AppTheme.error : AppTheme.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPast ? 'Exam date has passed' : 'Until Final Exam',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${examDate.day}/${examDate.month}/${examDate.year}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.calendar_month_rounded,
            color: (isPast ? AppTheme.error : AppTheme.primary).withValues(
              alpha: 0.4,
            ),
            size: 32,
          ),
        ],
      ),
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
    if (p == null)
      return _allBadges.map((b) => {...b, 'earned': false}).toList();

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

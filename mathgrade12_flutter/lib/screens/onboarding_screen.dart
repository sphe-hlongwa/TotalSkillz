import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../services/firestore_service.dart';
import '../models/user_progress.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  
  // Personalization state
  double _targetMark = 75;
  final Set<String> _weakAreas = {};

  final List<String> _topics = [
    'Algebra', 'Functions', 'Calculus', 'Trigonometry', 
    'Sequences', 'Probability', 'Statistics', 'Geometry'
  ];

  static const _pages = [
    _OnboardPage(
      icon: Icons.school_rounded,
      color: AppTheme.primary,
      title: 'Master Grade 12 Maths',
      body: 'Interactive practice, smart review, and real NSC question banks — everything you need to ace your exams.',
    ),
    _OnboardPage(
      icon: Icons.functions_rounded,
      color: AppTheme.accent,
      title: 'All Formulas at Your Fingertips',
      body: 'Browse the complete Grade 12 formula sheet with beautifully rendered equations, sorted by topic.',
    ),
    _OnboardPage(
      icon: Icons.timer_rounded,
      color: AppTheme.success,
      title: 'Practice & Exam Mode',
      body: 'Drill individual topics or simulate a 45-minute timed exam. Track your progress every step of the way.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final firestore = context.read<FirestoreService>();
    final settings = UserSettings(
      theme: 'dark',
      reminders: true,
      dailyGoal: 100,
      targetMark: _targetMark.toInt(),
      weakAreas: _weakAreas.toList(),
    );
    
    await firestore.updateSettings(settings);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length + 1, // +1 for settings page
                itemBuilder: (_, i) {
                  if (i < _pages.length) return _buildPage(_pages[i]);
                  return _buildSettingsPage();
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length + 1, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _page < _pages.length
                  ? Row(children: [
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text('Skip'),
                      ),
                      const Spacer(),
                      GradientButton(
                        text: 'Next',
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        ),
                        icon: Icons.arrow_forward_rounded,
                      ),
                    ])
                  : GradientButton(
                      text: "Get Started",
                      onPressed: _completeOnboarding,
                      icon: Icons.rocket_launch_rounded,
                    ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: page.color.withValues(alpha: 0.15),
                  border: Border.all(color: page.color.withValues(alpha: 0.4), width: 2),
                ),
                child: Icon(page.icon, size: 56, color: page.color),
              ),
              const SizedBox(height: 48),
              Text(page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(page.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 16, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.settings_suggest_rounded, size: 64, color: AppTheme.primary),
          const SizedBox(height: 24),
          const Text('Personalize Your Path', 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Help us tailor the experience to your needs.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 40),

          // Target Mark Slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Target Mark', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${_targetMark.toInt()}%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Slider(
                value: _targetMark,
                min: 40,
                max: 100,
                divisions: 60,
                activeColor: AppTheme.primary,
                inactiveColor: AppTheme.surface2,
                onChanged: (v) => setState(() => _targetMark = v),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Weak Areas
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Focus Areas', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _topics.map((t) {
              final isSelected = _weakAreas.contains(t);
              return FilterChip(
                label: Text(t),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _weakAreas.add(t);
                    } else {
                      _weakAreas.remove(t);
                    }
                  });
                },
                selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _OnboardPage({required this.icon, required this.color, required this.title, required this.body});
}

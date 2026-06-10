import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum _PolicyTab { privacy, terms }

class PrivacyPolicyScreen extends StatefulWidget {
  final _PolicyTab initialTab;
  const PrivacyPolicyScreen({super.key, this.initialTab = _PolicyTab.privacy});
  const PrivacyPolicyScreen.terms({super.key}) : initialTab = _PolicyTab.terms;

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == _PolicyTab.terms ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Legal'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Terms of Use'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScrollablePage(_privacyPolicyContent()),
          _buildScrollablePage(_termsContent()),
        ],
      ),
    );
  }

  Widget _buildScrollablePage(List<_Section> sections) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      itemCount: sections.length,
      itemBuilder: (_, i) {
        final s = sections[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.isHeading) ...[
                Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.subtitle ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
                const Divider(height: 32, color: AppTheme.border),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                s.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        s.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSubtle,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  List<_Section> _privacyPolicyContent() => [
        _Section.heading(
          'Privacy Policy',
          subtitle: 'Last updated: June 2026',
        ),
        _Section(
          title: 'Who We Are',
          body:
              'TotalSkillz ("we", "us", "our") is an educational mobile application designed to help Grade 12 learners prepare for their National Senior Certificate (NSC) Mathematics examinations.\n\nData Controller: TotalSkillz\nContact: totalskillzclm@gmail.com',
        ),
        _Section(
          title: 'Information We Collect',
          body:
              'We collect the following personal information when you create an account or use the app:\n\n• Full name and display name\n• Email address\n• School name and province\n• Learning progress, quiz scores, XP, and streaks\n• Mistake Vault entries (questions you got wrong)\n• Bug reports and feedback you submit\n• App version and device information (for bug reports)\n• Account creation date and last active timestamp',
        ),
        _Section(
          title: 'How We Use Your Information',
          body:
              'Your information is used exclusively to:\n\n• Provide and personalise your learning experience\n• Display your progress, badges, and statistics\n• Show your ranking on the leaderboard (display name and XP only)\n• Improve the app based on bug reports\n• Send important app announcements (via in-app broadcast only)\n\nWe do NOT use your data for advertising, profiling, or any commercial purpose beyond the app itself.',
        ),
        _Section(
          title: 'Data Sharing',
          body:
              'We do not sell, rent, or share your personal information with any third parties, except:\n\n• Firebase (Google LLC) — our database and authentication provider, operating under Google\'s privacy policy and GDPR-compliant infrastructure\n• Sentry — anonymous crash reporting (no PII transmitted)\n\nYour email is never visible to other users. Only your display name and XP appear on the leaderboard.',
        ),
        _Section(
          title: 'Data Retention',
          body:
              'Your data is retained for as long as your account is active. You may delete your account at any time from Settings → Danger Zone → Delete Account. Upon deletion, all your personal data and progress are permanently removed from our systems within 30 days.',
        ),
        _Section(
          title: 'Children\'s Privacy (Under 18)',
          body:
              'TotalSkillz is intended for Grade 12 learners who are typically 17–19 years old. We do not knowingly collect data from children under 13 without verifiable parental consent.\n\nIf you are under 18, please ensure a parent or guardian is aware of your use of this application. If you believe a child under 13 has created an account without consent, contact us at totalskillzclm@gmail.com and we will promptly delete their account.',
        ),
        _Section(
          title: 'Your Rights Under POPIA',
          body:
              'Under the Protection of Personal Information Act (POPIA), South African residents have the right to:\n\n• Access the personal information we hold about you\n• Correct inaccurate information\n• Request deletion of your data\n• Object to processing of your data\n• Lodge a complaint with the Information Regulator of South Africa\n\nTo exercise any of these rights, contact us at totalskillzclm@gmail.com.',
        ),
        _Section(
          title: 'Security',
          body:
              'We use Firebase Authentication and Firestore with security rules to protect your data. All data is encrypted in transit (HTTPS/TLS) and at rest. We apply rate limiting and access controls to prevent unauthorised access.',
        ),
        _Section(
          title: 'Changes to This Policy',
          body:
              'We may update this Privacy Policy from time to time. Changes will be communicated via an in-app announcement. Continued use of the app after changes constitutes acceptance of the updated policy.',
        ),
        _Section(
          title: 'Contact Us',
          body:
              'For any privacy-related queries or concerns, contact:\n\nEmail: totalskillzclm@gmail.com\n\nWe aim to respond within 5 business days.',
        ),
      ];

  List<_Section> _termsContent() => [
        _Section.heading(
          'Terms of Use',
          subtitle: 'Last updated: June 2026',
        ),
        _Section(
          title: 'Acceptance of Terms',
          body:
              'By creating an account and using TotalSkillz, you agree to these Terms of Use. If you do not agree, please do not use the application.',
        ),
        _Section(
          title: 'Eligibility',
          body:
              'You must be at least 13 years old to use TotalSkillz. By registering, you confirm that you meet this requirement. Users under 18 should use the app with awareness and consent of a parent or guardian.',
        ),
        _Section(
          title: 'Permitted Use',
          body:
              'TotalSkillz is for personal, non-commercial educational use only. You agree not to:\n\n• Share your account credentials with others\n• Attempt to manipulate quiz scores, XP, or the leaderboard by any means other than legitimate use\n• Upload offensive, abusive, or inappropriate content (including display names)\n• Attempt to reverse-engineer, decompile, or tamper with the application\n• Use the app for any purpose other than personal learning',
        ),
        _Section(
          title: 'Live Class Sessions',
          body:
              'Live tutoring sessions (currently R200 for 2 hours) are arranged directly via WhatsApp and conducted over Google Classroom. These sessions are subject to availability.\n\nCancellation Policy: Sessions cancelled at least 24 hours in advance may be rescheduled at no additional cost. No-shows or cancellations with less than 24 hours\' notice forfeit the session fee. Refund requests are considered on a case-by-case basis — contact totalskillzclm@gmail.com.',
        ),
        _Section(
          title: 'Intellectual Property',
          body:
              'All content within TotalSkillz — including questions, solutions, masterclass material, and formula sheets — is the intellectual property of TotalSkillz. You may not reproduce, distribute, or sell any content from the app without express written permission.',
        ),
        _Section(
          title: 'Disclaimer of Warranties',
          body:
              'TotalSkillz is provided "as is" without warranties of any kind. We do not guarantee that the app will be error-free, uninterrupted, or that using it will result in any specific examination outcome. Practice results within the app do not constitute a guarantee of NSC performance.',
        ),
        _Section(
          title: 'Limitation of Liability',
          body:
              'To the maximum extent permitted by South African law, TotalSkillz shall not be liable for any indirect, incidental, or consequential damages arising from your use of the application, including but not limited to data loss or examination results.',
        ),
        _Section(
          title: 'Termination',
          body:
              'We reserve the right to suspend or terminate your account if you violate these Terms. You may delete your account at any time from Settings.',
        ),
        _Section(
          title: 'Governing Law',
          body:
              'These Terms are governed by the laws of the Republic of South Africa. Any disputes shall be subject to the jurisdiction of the South African courts.',
        ),
        _Section(
          title: 'Contact',
          body:
              'For any questions about these Terms, contact: totalskillzclm@gmail.com',
        ),
      ];
}

class _Section {
  final String title;
  final String body;
  final String? subtitle;
  final bool isHeading;

  const _Section({required this.title, required this.body})
      : subtitle = null,
        isHeading = false;

  const _Section.heading(this.title, {this.subtitle})
      : body = '',
        isHeading = true;
}

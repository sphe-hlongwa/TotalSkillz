import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Support & Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFAQSection(),
          const SizedBox(height: 32),
          _buildContactSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Icon(Icons.help_outline_rounded, size: 64, color: AppTheme.primary),
        SizedBox(height: 16),
        Text('How can we help?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Find answers to common questions or reach out to us.', 
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _FAQItem(
          question: 'Are these official NSC papers?',
          answer: 'Yes, all papers in The Vault are sourced from official National Senior Certificate (NSC) archives.',
        ),
        _FAQItem(
          question: 'How does the Mistake Vault work?',
          answer: 'Every question you get wrong in a quiz is saved. Redoing these helps you master the concepts you find difficult.',
        ),
        _FAQItem(
          question: 'Is the app free to use?',
          answer: 'The core features (practice, vault, formulas) are free. Expert Live Sessions are available at a fee.',
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          const Text('Still have questions?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Our experts are available via WhatsApp for direct support.', 
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat with Support'),
            onPressed: () async {
              final url = Uri.parse('https://wa.me/27678639760?text=Hello%20TotalSkillz%20Support');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: const TextStyle(fontSize: 13, color: AppTheme.textSubtle)),
          ),
        ],
      ),
    );
  }
}

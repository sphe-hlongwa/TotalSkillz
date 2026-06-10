import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/ts_text_field.dart';
import '../services/masterclass_service.dart';
import '../models/masterclass_model.dart';

class LiveClassesScreen extends StatefulWidget {
  const LiveClassesScreen({super.key});

  @override
  State<LiveClassesScreen> createState() => _LiveClassesScreenState();
}

class _LiveClassesScreenState extends State<LiveClassesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _topicsController = TextEditingController();
  String _subject = 'Gr12-Math-P1';
  String _tier = 'Free Trial';
  DateTime _preferredDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MasterclassService>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const _subjects = [
    {'value': 'Gr12-Math-P1', 'label': 'Grade 12 Mathematics (Paper 1)'},
    {'value': 'Gr12-Math-P2', 'label': 'Grade 12 Mathematics (Paper 2)'},
    {'value': 'Other', 'label': 'Other / Request Details Below'},
  ];

  static const _tiers = [
    {'value': 'Free Trial', 'label': 'Free Trial (First 2 lectures)'},
    {'value': 'Standard Paid', 'label': 'Standard Paid (R200/2hrs)'},
  ];

  String _generatePayload() {
    final dateStr = "${_preferredDate.day}/${_preferredDate.month}/${_preferredDate.year} at ${_preferredDate.hour}:${_preferredDate.minute.toString().padLeft(2, '0')}";
    
    return '''Hello, I would like to request a Live Class Session!

Name: ${_nameController.text}
Email: ${_emailController.text}
Subject: $_subject
Session Type: $_tier
Topics: ${_topicsController.text}
Preferred Time: $dateStr

${_tier == 'Standard Paid' ? 'Please let me know if this slot is available and send me the Google Classroom link & payment details!' : 'Please let me know if this slot is available and send me the Google Classroom link!'}''';
  }

  Future<void> _launchWhatsApp() async {
    final msg = Uri.encodeComponent(_generatePayload());
    final url = Uri.parse('https://wa.me/27678639760?text=$msg');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Mastery'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Workshop'),
            Tab(text: 'Book a Class'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkshopTab(),
          _buildBookingTab(),
        ],
      ),
    );
  }

  Widget _buildWorkshopTab() {
    final service = context.watch<MasterclassService>();
    if (service.isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: service.data.length,
      itemBuilder: (context, index) {
        final topic = service.topics[index];
        final items = service.data[topic]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(topic.toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13)),
            ),
            ...items.map((item) => _buildMasterclassCard(item)),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildMasterclassCard(MasterclassItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _buildMathText(item.question, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.warning, size: 16),
                    SizedBox(width: 8),
                    Text('EXPERT DERIVATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.warning)),
                  ],
                ),
                const SizedBox(height: 16),
                ...item.steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMathText(step.tex, style: const TextStyle(fontSize: 16, color: AppTheme.primary)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.textMuted),
                            const SizedBox(width: 8),
                            Expanded(child: Text(step.note, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.video_camera_front_outlined, size: 48, color: AppTheme.primary),
          const SizedBox(height: 16),
          const Text('Face-to-Face Learning', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Book a 1-on-1 session via Google Classroom for deep-dive learning.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const SizedBox(height: 32),
          TsTextField(controller: _nameController, label: 'Full Name', hint: 'Name Surname'),
          const SizedBox(height: 16),
          TsTextField(controller: _emailController, label: 'Contact Email', hint: 'student@example.com'),
          const SizedBox(height: 16),
          _buildDropdown(label: 'Grade & Subject', value: _subject, items: _subjects, onChanged: (val) => setState(() => _subject = val!)),
          const SizedBox(height: 16),
          _buildDropdown(label: 'Session Type', value: _tier, items: _tiers, onChanged: (val) => setState(() => _tier = val!)),
          const SizedBox(height: 16),
          TsTextField(controller: _topicsController, label: 'Topics', hint: 'E.g., Calc, Trig...', maxLines: 2),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Preferred Time', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text("${_preferredDate.day}/${_preferredDate.month} at ${_preferredDate.hour}:${_preferredDate.minute.toString().padLeft(2, '0')}", 
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.calendar_month, color: AppTheme.primary),
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _preferredDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
              if (date == null || !mounted) return;
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_preferredDate));
              if (time != null && mounted) setState(() => _preferredDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
            },
          ),
          const SizedBox(height: 32),
          GradientButton(text: 'Request via WhatsApp', onPressed: _launchWhatsApp, icon: Icons.chat_bubble_outline),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String label, required String value, required List<Map<String, String>> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              items: items.map((item) => DropdownMenuItem(value: item['value'], child: Text(item['label']!, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMathText(String text, {TextStyle? style}) {
    if (text.contains(r'\(') || text.contains(r'\[') || text.contains(r'\\') || text.contains(r'^') || text.contains(r'_') || text.contains(r'frac')) {
      final cleaned = text.replaceAll(r'\(', '').replaceAll(r'\)', '').replaceAll(r'\[', '').replaceAll(r'\]', '');
      return Math.tex(cleaned, textStyle: style ?? const TextStyle(fontSize: 15, color: AppTheme.text));
    }
    return Text(text, style: style ?? const TextStyle(fontSize: 15, color: AppTheme.text));
  }
}

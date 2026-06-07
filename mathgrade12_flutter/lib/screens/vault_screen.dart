import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../models/user_progress.dart';
import '../models/past_paper.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedYear = 'All';
  String _selectedProvince = 'All';
  String _selectedType = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final firestore = context.watch<FirestoreService>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('The Vault'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Review Mistakes'),
            Tab(text: 'Past Papers'),
          ],
        ),
      ),
      body: StreamBuilder<UserProgress?>(
        stream: firestore.watchUserProgress(),
        builder: (context, snapshot) {
          final progress = snapshot.data;
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildMistakeList(context, progress?.mistakeVault ?? []),
              _buildPaperList(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMistakeList(BuildContext context, List<MistakeItem> mistakes) {
    if (mistakes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 64, color: AppTheme.success.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Zero mistakes! You are on fire.', 
                style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
            const Text('Keep practicing to stay sharp.', 
                style: TextStyle(color: AppTheme.textSubtle, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mistakes.length,
      itemBuilder: (ctx, i) {
        final item = mistakes[i];
        final mastery = (item.streak / 3).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(item.questionText, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      _Badge(label: item.topic, color: AppTheme.primary),
                      const SizedBox(width: 8),
                      Text('Mastery: ${(mastery * 100).toInt()}%', 
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                onTap: () {
                  // Navigate to session
                },
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: LinearProgressIndicator(
                  value: mastery,
                  minHeight: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    mastery == 1.0 ? AppTheme.success : AppTheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaperList(BuildContext context) {
    final filteredPapers = _papers.where((p) {
      final yMatch = _selectedYear == 'All' || p.year == _selectedYear;
      final pMatch = _selectedProvince == 'All' || p.province == _selectedProvince;
      final tMatch = _selectedType == 'All' || p.type == _selectedType;
      final sMatch = _searchQuery.isEmpty || p.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return yMatch && pMatch && tMatch && sMatch;
    }).toList();

    return Column(
      children: [
        // Search and Filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search papers...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  fillColor: AppTheme.bg,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Year: $_selectedYear',
                      onTap: () => _showFilterDialog('Year', ['All', '2025', '2024', '2023', '2022', '2021', '2020'], _selectedYear, (v) => setState(() => _selectedYear = v)),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Province: $_selectedProvince',
                      onTap: () => _showFilterDialog('Province', ['All', 'NSC (National)', 'Gauteng', 'KZN', 'WC', 'EC', 'FS', 'MP', 'NW', 'LP', 'NC'], _selectedProvince, (v) => setState(() => _selectedProvince = v)),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Type: $_selectedType',
                      onTap: () => _showFilterDialog('Type', ['All', 'Paper 1', 'Paper 2', 'Memorial'], _selectedType, (v) => setState(() => _selectedType = v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: filteredPapers.isEmpty
              ? _buildEmptyPapers()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPapers.length,
                  itemBuilder: (ctx, i) {
                    final paper = filteredPapers[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: AppTheme.error, size: 20),
                        ),
                        title: Text(paper.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${paper.province} • ${paper.year}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_for_offline_outlined, color: AppTheme.primary),
                          onPressed: () => _openPdf(context, paper),
                        ),
                        onTap: () => _openPdf(context, paper),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyPapers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No papers match your search/filters.', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  void _showFilterDialog(String title, List<String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Filter by $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: options.map((opt) => ListTile(
                title: Text(opt),
                trailing: opt == current ? const Icon(Icons.check, color: AppTheme.primary) : null,
                onTap: () {
                  onSelect(opt);
                  Navigator.pop(ctx);
                },
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _openPdf(BuildContext context, PastPaper paper) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: AppTheme.error, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(paper.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${paper.province} • ${paper.year}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppTheme.surface2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_download_outlined, size: 48, color: AppTheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text('Simulating PDF Load...', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'This feature is a preview. In the production app, this will open a full high-fidelity PDF viewer with annotation tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text('Download for Offline'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${paper.title} saved to Offline Vault'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.text)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

const _papers = [
  // 2025 (Predicted/Sample)
  PastPaper(id: '2025-nsc-p1', title: 'NSC June 2025 P1', province: 'NSC (National)', year: '2025', type: 'Paper 1'),
  PastPaper(id: '2025-nsc-p2', title: 'NSC June 2025 P2', province: 'NSC (National)', year: '2025', type: 'Paper 2'),
  
  // 2024
  PastPaper(id: '2024-gp-trial-p1', title: 'Gauteng Trial 2024 P1', province: 'Gauteng', year: '2024', type: 'Paper 1'),
  PastPaper(id: '2024-gp-trial-p2', title: 'Gauteng Trial 2024 P2', province: 'Gauteng', year: '2024', type: 'Paper 2'),
  PastPaper(id: '2024-kzn-trial-p1', title: 'KZN Trial 2024 P1', province: 'KZN', year: '2024', type: 'Paper 1'),
  PastPaper(id: '2024-kzn-trial-p2', title: 'KZN Trial 2024 P2', province: 'KZN', year: '2024', type: 'Paper 2'),
  PastPaper(id: '2024-wc-trial-p1', title: 'WC Trial 2024 P1', province: 'WC', year: '2024', type: 'Paper 1'),
  PastPaper(id: '2024-fs-trial-p1', title: 'Free State Trial 2024 P1', province: 'FS', year: '2024', type: 'Paper 1'),
  PastPaper(id: '2024-ec-trial-p1', title: 'Eastern Cape Trial 2024 P1', province: 'EC', year: '2024', type: 'Paper 1'),
  
  // 2023
  PastPaper(id: '2023-nsc-final-p1', title: 'NSC Final 2023 P1', province: 'NSC (National)', year: '2023', type: 'Paper 1'),
  PastPaper(id: '2023-nsc-final-p2', title: 'NSC Final 2023 P2', province: 'NSC (National)', year: '2023', type: 'Paper 2'),
  PastPaper(id: '2023-gp-trial-p1', title: 'Gauteng Trial 2023 P1', province: 'Gauteng', year: '2023', type: 'Paper 1'),
  PastPaper(id: '2023-kzn-trial-p1', title: 'KZN Trial 2023 P1', province: 'KZN', year: '2023', type: 'Paper 1'),
  
  // 2022
  PastPaper(id: '2022-nsc-final-p1', title: 'NSC Final 2022 P1', province: 'NSC (National)', year: '2022', type: 'Paper 1'),
  PastPaper(id: '2022-nsc-final-p2', title: 'NSC Final 2022 P2', province: 'NSC (National)', year: '2022', type: 'Paper 2'),
  PastPaper(id: '2022-gp-trial-p1', title: 'Gauteng Trial 2022 P1', province: 'Gauteng', year: '2022', type: 'Paper 1'),
  
  // 2021
  PastPaper(id: '2021-nsc-final-p1', title: 'NSC Final 2021 P1', province: 'NSC (National)', year: '2021', type: 'Paper 1'),
  PastPaper(id: '2021-nsc-final-p2', title: 'NSC Final 2021 P2', province: 'NSC (National)', year: '2021', type: 'Paper 2'),
  
  // 2020
  PastPaper(id: '2020-nsc-final-p1', title: 'NSC Final 2020 P1', province: 'NSC (National)', year: '2020', type: 'Paper 1'),
  PastPaper(id: '2020-nsc-final-p2', title: 'NSC Final 2020 P2', province: 'NSC (National)', year: '2020', type: 'Paper 2'),
];

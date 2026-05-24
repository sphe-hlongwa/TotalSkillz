import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _filter = 'global';

  @override
  Widget build(BuildContext context) {
    final firestore = context.watch<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show scoring logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: firestore.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var users = snapshot.data ?? [];
                final currentUser = users.firstWhere((u) => u['uid'] == firestore.uid, orElse: () => {});
                
                // Filter
                if (_filter == 'province') {
                  final province = currentUser['settings']?['province'];
                  users = users.where((u) => u['settings']?['province'] == province).toList();
                } else if (_filter == 'school') {
                  final school = currentUser['settings']?['school'];
                  users = users.where((u) => u['settings']?['school'] == school).toList();
                }

                // Sort by XP (or streak ifXP is equal)
                users.sort((a, b) {
                  int xpA = (a['xp'] ?? a['totalXp'] ?? 0) as int;
                  int xpB = (b['xp'] ?? b['totalXp'] ?? 0) as int;
                  if (xpA != xpB) return xpB.compareTo(xpA);
                  int streakA = (a['streak'] ?? 0) as int;
                  int streakB = (b['streak'] ?? 0) as int;
                  return streakB.compareTo(streakA);
                });

                if (users.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (ctx, i) {
                    final user = users[i];
                    final isTopThree = i < 3;
                    final displayName = user['displayName']?.toString() ?? 'Anonymous';
                    final xp = (user['xp'] ?? user['totalXp'] ?? 0) as int;
                    final streak = (user['streak'] ?? 0) as int;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isTopThree ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isTopThree ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.border,
                        ),
                      ),
                      child: ListTile(
                        leading: _buildRankBadge(i + 1),
                        title: Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: isTopThree ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text('$xp XP • $streak Day Streak'),
                        trailing: isTopThree 
                          ? const Icon(Icons.emoji_events, color: Colors.amber)
                          : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _FilterChip(
            label: 'Global',
            isActive: _filter == 'global',
            onTap: () => setState(() => _filter = 'global'),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Province',
            isActive: _filter == 'province',
            onTap: () => setState(() => _filter = 'province'),
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'My School',
            isActive: _filter == 'school',
            onTap: () => setState(() => _filter = 'school'),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color bgColor = AppTheme.border;
    Color textColor = AppTheme.textMuted;

    if (rank == 1) {
      bgColor = Colors.amber;
      textColor = Colors.black;
    } else if (rank == 2) {
      bgColor = Colors.grey.shade400;
      textColor = Colors.black;
    } else if (rank == 3) {
      bgColor = Colors.brown.shade300;
      textColor = Colors.white;
    }

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        rank.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

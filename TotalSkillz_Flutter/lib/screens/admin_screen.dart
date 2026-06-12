import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String _userSearchQuery = '';

  // Broadcast Form State
  final _broadcastTitleController = TextEditingController();
  final _broadcastBodyController = TextEditingController();
  String _broadcastType = 'info';
  int _broadcastExpiry = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthService>();
    if (!auth.isAdmin) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final users = await context.read<FirestoreService>().getAllUsers();
    if (mounted)
      setState(() {
        _users = users;
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(child: Text('Access denied.')),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          title: const Text('Admin Console'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded)),
              Tab(text: 'Users', icon: Icon(Icons.people_rounded)),
              Tab(text: 'Bug Reports', icon: Icon(Icons.bug_report_rounded)),
              Tab(text: 'Broadcast', icon: Icon(Icons.campaign_rounded)),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildUsersTab(),
                  _buildReportsTab(),
                  _buildBroadcastTab(),
                ],
              ),
      ),
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildOverviewTab() {
    int totalXp = 0;
    int newUsersThisWeek = 0;
    final now = DateTime.now();

    for (var u in _users) {
      totalXp += ((u['xp'] ?? u['totalXp'] ?? 0) as num).toInt();
      if (u['createdAt'] != null) {
        try {
          final createdAt = (u['createdAt'] as dynamic).toDate() as DateTime;
          if (now.difference(createdAt).inDays <= 7) {
            newUsersThisWeek++;
          }
        } catch (_) {}
      }
    }
    final avgXp = _users.isEmpty ? 0 : (totalXp / _users.length).round();
    final adminsCount = _users.where((u) => u['role'] == 'admin').length;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            _AdminStat(
              label: 'Total Users',
              value: '${_users.length}',
              color: AppTheme.primary,
            ),
            const SizedBox(width: 16),
            _AdminStat(
              label: 'Admins',
              value: '$adminsCount',
              color: AppTheme.accent,
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Platform Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total XP Awarded',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$totalXp XP',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Average XP / User',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$avgXp XP',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Signups (7 Days)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '$newUsersThisWeek',
                    style: const TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = _users.where((u) {
      final name = u['displayName']?.toString().toLowerCase() ?? '';
      final email = u['email']?.toString().toLowerCase() ?? '';
      return name.contains(_userSearchQuery.toLowerCase()) ||
          email.contains(_userSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _userSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
              fillColor: AppTheme.surface,
              filled: true,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredUsers.length,
            itemBuilder: (ctx, i) {
              final u = filteredUsers[i];
              final displayName = u['displayName']?.toString() ?? 'Anonymous';
              final role = u['role'] ?? 'student';
              final isAdmin = role == 'admin';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          (isAdmin ? AppTheme.accent : AppTheme.primary)
                              .withValues(alpha: 0.1),
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: TextStyle(
                          color: isAdmin ? AppTheme.accent : AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            u['email']?.toString() ?? 'No email',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AdminUserActions(user: u, onUpdate: _loadData),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final firestore = context.watch<FirestoreService>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.watchBugReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return const Center(
            child: Text(
              'No bug reports found.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (ctx, i) {
            final r = reports[i];
            final isOpen = r['status'] == 'open';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOpen
                      ? AppTheme.error.withValues(alpha: 0.3)
                      : AppTheme.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(
                        label: r['status']?.toString().toUpperCase() ?? 'OPEN',
                        color: isOpen ? AppTheme.error : AppTheme.success,
                      ),
                      const Spacer(),
                      Text(
                        r['timestamp'] != null
                            ? DateFormat(
                                'dd MMM, HH:mm',
                              ).format((r['timestamp'] as dynamic).toDate())
                            : 'Recent',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Source: ${r['source'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r['description'] ?? 'No description provided.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSubtle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          isOpen
                              ? Icons.check_circle_outline
                              : Icons.replay_rounded,
                          size: 16,
                        ),
                        label: Text(isOpen ? 'Mark Resolved' : 'Reopen'),
                        style: TextButton.styleFrom(
                          foregroundColor: isOpen
                              ? AppTheme.success
                              : AppTheme.primary,
                        ),
                        onPressed: () => firestore.updateReportStatus(
                          r['id'],
                          isOpen ? 'resolved' : 'open',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBroadcastTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send App-Wide Announcement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'This message will be visible on all student dashboards.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 24),

          const Text(
            'Message Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TypeChoice(
                'info',
                'Information',
                AppTheme.primary,
                _broadcastType,
                (v) => setState(() => _broadcastType = v),
              ),
              const SizedBox(width: 8),
              _TypeChoice(
                'warning',
                'Warning',
                AppTheme.warning,
                _broadcastType,
                (v) => setState(() => _broadcastType = v),
              ),
              const SizedBox(width: 8),
              _TypeChoice(
                'alert',
                'Critical',
                AppTheme.error,
                _broadcastType,
                (v) => setState(() => _broadcastType = v),
              ),
            ],
          ),

          const SizedBox(height: 24),
          TextField(
            controller: _broadcastTitleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Server Maintenance Tomorrow',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _broadcastBodyController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Message Body',
              hintText: 'Provide details here...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Expires After (Days)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Slider(
            value: _broadcastExpiry.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$_broadcastExpiry days',
            onChanged: (v) => setState(() => _broadcastExpiry = v.toInt()),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'BROADCAST MESSAGE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              onPressed: _sendBroadcast,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendBroadcast() async {
    final title = _broadcastTitleController.text.trim();
    final body = _broadcastBodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      return;
    }

    try {
      await context.read<FirestoreService>().sendBroadcast(
        title: title,
        body: body,
        type: _broadcastType,
        expiryDays: _broadcastExpiry,
      );

      _broadcastTitleController.clear();
      _broadcastBodyController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Broadcast sent successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send broadcast.')),
        );
      }
    }
  }
}

class _AdminStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AdminStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUserActions extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUpdate;
  const _AdminUserActions({required this.user, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.admin_panel_settings_rounded, size: 20),
            title: Text('Toggle Admin'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          onTap: () async {
            final f = ctx.read<FirestoreService>();
            await f.toggleAdminStatus(user['uid'], user['isAdmin'] != true);
            onUpdate();
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.refresh_rounded, size: 20),
            title: Text('Reset Progress'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          onTap: () async {
            final f = ctx.read<FirestoreService>();
            await f.resetUserProgress(user['uid']);
            onUpdate();
          },
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.error,
              size: 20,
            ),
            title: Text(
              'Delete Account',
              style: TextStyle(color: AppTheme.error),
            ),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          onTap: () async {
            // Confirmation would be better here
            final f = ctx.read<FirestoreService>();
            await f.deleteUser(user['uid']);
            onUpdate();
          },
        ),
      ],
    );
  }
}

class _TypeChoice extends StatelessWidget {
  final String id;
  final String label;
  final Color color;
  final String current;
  final Function(String) onSelect;
  const _TypeChoice(
    this.id,
    this.label,
    this.color,
    this.current,
    this.onSelect,
  );

  @override
  Widget build(BuildContext context) {
    final active = id == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.1) : AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? color : AppTheme.border),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? color : AppTheme.textMuted,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
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
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

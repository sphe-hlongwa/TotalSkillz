import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/topics')) return 1;
    if (location.startsWith('/formulas')) return 2;
    if (location.startsWith('/vault')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/topics');
        break;
      case 2:
        context.go('/formulas');
        break;
      case 3:
        context.go('/vault');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 850;
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.bg,
      appBar: isWideScreen ? null : AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/logo.jpg', width: 28, height: 28, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text('TotalSkillz', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: AppTheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textMuted),
        actions: [
          _buildUserAvatar(),
          const SizedBox(width: 16),
        ],
      ),
      drawer: isWideScreen ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isWideScreen) _buildSidebar(context),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildBottomNav(currentIndex, context),
    );
  }

  Widget _buildBottomNav(int currentIndex, BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1626).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 24,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(0, Icons.home_outlined, 'Home', currentIndex, context),
                _buildBottomNavItem(1, Icons.topic_outlined, 'Topics', currentIndex, context),
                _buildBottomNavItem(2, Icons.functions, 'Formulas', currentIndex, context),
                _buildBottomNavItem(3, Icons.shield_outlined, 'Vault', currentIndex, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label, int currentIndex, BuildContext context) {
    final bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 44 : 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.secondary.withValues(alpha: 0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryLight : AppTheme.textMuted.withValues(alpha: 0.9),
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: isActive ? AppTheme.primaryLight : AppTheme.textMuted.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: () => context.push('/settings'),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.primary,
        child: const Text('US', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset('assets/logo.jpg', width: 32, height: 32, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  const Text('TotalSkillz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ],
              ),
            ),
            Expanded(child: _buildNavLinks(context)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildNavItem(context, icon: Icons.logout, label: 'Sign Out', onTap: () async {
                await context.read<AuthService>().signOut();
                if (context.mounted) context.go('/login');
              }, isDanger: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      color: AppTheme.surface,
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('assets/logo.jpg', width: 32, height: 32, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                const Text('TotalSkillz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ],
            ),
          ),
          Expanded(child: _buildNavLinks(context)),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: Row(
              children: [
                _buildUserAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('View Profile', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20, color: AppTheme.textMuted),
                  onPressed: () async {
                    await context.read<AuthService>().signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLinks(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildSectionTitle('Overview'),
        _buildNavItem(context, icon: Icons.grid_view_rounded, label: 'Dashboard', path: '/dashboard'),
        _buildNavItem(context, icon: Icons.person_outline, label: 'Identity & Bio', path: '/settings'),
        _buildNavItem(context, icon: Icons.shield_outlined, label: 'Security & Access', path: '/settings'),
        if (context.watch<AuthService>().isAdmin)
          _buildNavItem(context, icon: Icons.admin_panel_settings_outlined, label: 'Admin Point', path: '/admin', color: AppTheme.primary),
        
        _buildSectionTitle('Preferences'),
        _buildNavItem(context, icon: Icons.track_changes, label: 'Study Goals', path: '/settings'),

        _buildSectionTitle('Learning Tools'),
        _buildNavItem(context, icon: Icons.description_outlined, label: 'Quick Formulas', path: '/formulas'),
        _buildNavItem(context, icon: Icons.timer_outlined, label: 'Exam Mode', path: '/exam'),
        _buildNavItem(context, icon: Icons.video_camera_front_outlined, label: 'Live Classes', path: '/live-classes'),
        _buildNavItem(context, icon: Icons.search_off, label: 'Examiner Mode', path: '/examiner'),
        _buildNavItem(context, icon: Icons.security, label: 'Mistake Vault', path: '/vault'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, String? path, VoidCallback? onTap, Color? color, bool isDanger = false}) {
    final String location = GoRouterState.of(context).uri.path;
    final bool isActive = path != null && location.startsWith(path);
    final Color itemColor = color ?? (isDanger ? AppTheme.error : (isActive ? AppTheme.primary : AppTheme.textMuted));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap ?? () {
          if (path != null) context.go(path);
          if (Scaffold.of(context).isDrawerOpen) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: itemColor),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.primary : (isDanger ? AppTheme.error : AppTheme.text),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

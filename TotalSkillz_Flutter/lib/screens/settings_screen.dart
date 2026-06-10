import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../models/user_progress.dart';
import '../widgets/ts_text_field.dart';
import '../widgets/gradient_button.dart';
import '../widgets/bug_report_bottom_sheet.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  String _selectedProvince = 'Gauteng';
  double _dailyGoalXp = 50;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _schoolController = TextEditingController();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final firestore = context.read<FirestoreService>();
    final progress = await firestore.getUserProgress();
    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      setState(() {
        _nameController.text = user?.displayName ?? '';
        _schoolController.text = progress?.settings.school ?? '';
        _selectedProvince = progress?.settings.province ?? 'Gauteng';
        _dailyGoalXp = (progress?.settings.dailyGoalXp ?? 50).toDouble();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final firestore = context.read<FirestoreService>();
      final auth = FirebaseAuth.instance.currentUser;

      // Update Firebase Auth Display Name
      if (_nameController.text != auth?.displayName) {
        await auth?.updateDisplayName(_nameController.text);
      }

      // Update Firestore Settings
      await firestore.updateSettings(UserSettings(
        school: _schoolController.text,
        province: _selectedProvince,
        dailyGoalXp: _dailyGoalXp.toInt(),
        notificationsEnabled: true, // Default
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Account?'),
        content: const Text('This action is permanent and will erase all your progress, XP, and mistake vault. Are you absolutely sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final authService = context.read<AuthService>();
        await authService.deleteAccount();
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e. You may need to re-login to delete.'), backgroundColor: AppTheme.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Settings & Profile')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card
                  _buildProfileCard(),
                  const SizedBox(height: 32),

                  // Appearance Section
                  _buildSectionHeader('Appearance'),
                  const SizedBox(height: 16),
                  _buildThemeToggle(),
                  const SizedBox(height: 24),

                  // Support Section
                  _buildSectionHeader('Support'),
                  const SizedBox(height: 16),
                  _buildReportBugButton(),
                  const SizedBox(height: 40),

                  _buildSectionHeader('Personal Identity'),
                  const SizedBox(height: 16),
                  TsTextField(
                    controller: _nameController,
                    label: 'Display Name',
                    hint: 'Your student name',
                    validator: (v) => v!.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TsTextField(
                    controller: _schoolController,
                    label: 'School Name',
                    hint: 'e.g., Central High School',
                  ),
                  const SizedBox(height: 16),
                  _buildProvinceDropdown(),
                  
                  const SizedBox(height: 40),
                  _buildSectionHeader('Learning Goals'),
                  const SizedBox(height: 8),
                  Text('Daily XP Target: ${_dailyGoalXp.toInt()} XP', 
                    style: const TextStyle(color: AppTheme.textSubtle, fontSize: 13)),
                  Slider(
                    value: _dailyGoalXp,
                    min: 10,
                    max: 200,
                    divisions: 19,
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => _dailyGoalXp = v),
                  ),

                  const SizedBox(height: 40),
                  GradientButton(
                    text: 'Save Changes',
                    onPressed: _saveProfile,
                    loading: _isLoading,
                  ),

                  const SizedBox(height: 60),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 20),
                  _buildSectionHeader('Danger Zone', color: AppTheme.error),
                  const SizedBox(height: 8),
                  const Text('Permanent actions that cannot be undone.', 
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('DELETE ACCOUNT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.error,
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title, {Color color = AppTheme.primary}) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    const provinces = [
      'Gauteng', 'KZN', 'Western Cape', 'Eastern Cape', 
      'Free State', 'Limpopo', 'Mpumalanga', 'North West', 'Northern Cape'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Province', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProvince,
              isExpanded: true,
              dropdownColor: AppTheme.surface,
              items: provinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedProvince = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final userProgress = context.watch<FirestoreService>().userProgress;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primary,
              child: Text(
                userProgress?.displayName.isNotEmpty == true
                    ? userProgress!.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProgress?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProgress?.email ?? 'user@app.com',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    themeService.isDarkMode ? 'Dark Mode' : 'Light Mode',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: themeService.isDarkMode,
                activeThumbColor: AppTheme.primary,
                onChanged: (_) => themeService.toggleTheme(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportBugButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const BugReportBottomSheet(),
        ),
        icon: const Icon(Icons.bug_report_outlined),
        label: const Text('Report a Bug'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.warning,
          side: const BorderSide(color: AppTheme.warning),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

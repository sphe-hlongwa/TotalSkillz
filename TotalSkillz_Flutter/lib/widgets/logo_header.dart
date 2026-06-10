import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Logo + title header shown on auth screens
class LogoHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const LogoHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo circle
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.school,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/topics_screen.dart';
import '../screens/practice_screen.dart';
import '../screens/exam_screen.dart';
import '../screens/formula_screen.dart';
import '../screens/vault_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/support_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/auth/phone_auth_screen.dart';
import '../screens/live_classes_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/examiner_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/privacy_policy_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isAuth = user != null;
      final isOnAuthPage = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/phone-auth');

      if (!isAuth && !isOnAuthPage) return '/login';
      if (isAuth && isOnAuthPage) return '/dashboard';
      
      // Admin route guard
      if (state.matchedLocation.startsWith('/admin')) {
        if (user == null) return '/login';
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final isAdmin = doc.exists && doc.data()?['role'] == 'admin';
          if (!isAdmin) return '/dashboard';
        } catch (e) {
          return '/dashboard';
        }
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (ctx, _) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (ctx, _) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (ctx, _) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding', builder: (ctx, _) => const OnboardingScreen()),

      // Main app routes
      GoRoute(path: '/dashboard', builder: (ctx, _) => const DashboardScreen()),
      GoRoute(path: '/topics', builder: (ctx, _) => const TopicsScreen()),
      GoRoute(
        path: '/practice',
        builder: (ctx, state) {
          final topic = state.uri.queryParameters['topic'];
          return PracticeScreen(topic: topic);
        },
      ),
      GoRoute(
        path: '/exam',
        builder: (ctx, state) {
          final topic = state.uri.queryParameters['topic'];
          return ExamScreen(topic: topic);
        },
      ),
      GoRoute(path: '/formulas', builder: (ctx, _) => const FormulaScreen()),
      GoRoute(path: '/vault', builder: (ctx, _) => const VaultScreen()),
      GoRoute(path: '/live-classes', builder: (ctx, _) => const LiveClassesScreen()),
      GoRoute(path: '/leaderboard', builder: (ctx, _) => const LeaderboardScreen()),
      GoRoute(path: '/examiner', builder: (ctx, _) => const ExaminerScreen()),
      GoRoute(path: '/admin', builder: (ctx, _) => const AdminScreen()),
      GoRoute(path: '/support', builder: (ctx, _) => const SupportScreen()),
      GoRoute(path: '/settings', builder: (ctx, _) => const SettingsScreen()),
      GoRoute(path: '/phone-auth', builder: (ctx, _) => const PhoneAuthScreen()),
      GoRoute(path: '/privacy-policy', builder: (ctx, _) => const PrivacyPolicyScreen()),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}

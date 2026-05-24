import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/ts_text_field.dart';
import '../../widgets/logo_header.dart';
import '../../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePass = true;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await context.read<AuthService>().signInWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _errorMsg = _friendlyError(e.toString());
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() { _loading = true; _errorMsg = null; });
    try {
      final result = await context.read<AuthService>().signInWithGoogle();
      if (mounted && result != null) context.go('/dashboard');
    } catch (e) {
      setState(() => _errorMsg = 'Google sign-in failed. Try email instead.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String e) {
    if (e.contains('wrong-password') || e.contains('invalid-credential')) {
      return 'Invalid email or password.';
    }
    if (e.contains('user-not-found')) return 'No account found with this email.';
    if (e.contains('too-many-requests')) return 'Too many attempts. Try again later.';
    return 'Sign in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const LogoHeader(
                    title: 'TotalSkillz',
                    subtitle: 'Sign in to continue your learning journey',
                  ),
                  const SizedBox(height: 32),

                  // Google button
                  GoogleSignInButton(onTap: _loading ? null : _googleSignIn),
                  const SizedBox(height: 24),

                  // Divider
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 24),

                  // Email/password form
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TsTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'you@email.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TsTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: _obscurePass,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                      ),
                    ]),
                  ),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text('Forgot password?'),
                    ),
                  ),

                  // Error message
                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(_errorMsg!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  GradientButton(
                    text: 'Sign In',
                    onPressed: _loading ? null : _signIn,
                    loading: _loading,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 24),

                  // Switch to signup
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: const Text('Create account'),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/phone-auth'),
                    child: const Text('Sign in with Phone'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

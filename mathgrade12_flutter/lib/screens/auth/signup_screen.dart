import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/ts_text_field.dart';
import '../../widgets/logo_header.dart';
import '../../widgets/google_sign_in_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePass = true;
  String? _errorMsg;
  int _strengthScore = 0;  // 0-4

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _updateStrength(String val) {
    int score = 0;
    if (val.length >= 6) score++;
    if (val.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(val) && RegExp(r'[a-z]').hasMatch(val)) score++;
    if (RegExp(r'[0-9]').hasMatch(val) && RegExp(r'[^A-Za-z0-9]').hasMatch(val)) score++;
    setState(() => _strengthScore = score);
  }

  Color _strengthColor(int index) {
    if (_strengthScore == 0) return AppTheme.surface2;
    if (index >= _strengthScore) return AppTheme.surface2;
    switch (_strengthScore) {
      case 1: return AppTheme.error;
      case 2: return AppTheme.warning;
      case 3: return AppTheme.info;
      case 4: return AppTheme.success;
      default: return AppTheme.surface2;
    }
  }

  String get _strengthLabel {
    switch (_strengthScore) {
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return '';
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await context.read<AuthService>().signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
      if (mounted) context.go('/onboarding');
    } catch (e) {
      setState(() => _errorMsg = _friendlyError(e.toString()));
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
    if (e.contains('email-already-in-use')) return 'An account with this email already exists.';
    if (e.contains('weak-password')) return 'Password is too weak.';
    return 'Sign up failed. Please try again.';
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
                    title: 'Create account',
                    subtitle: 'Start mastering Grade 12 Mathematics today',
                  ),
                  const SizedBox(height: 32),

                  GoogleSignInButton(onTap: _loading ? null : _googleSignIn),
                  const SizedBox(height: 24),

                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TsTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'Your full name',
                        validator: (v) {
                          if (v == null || v.trim().length < 2) return 'Please enter your name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                        hint: 'At least 8 characters',
                        obscureText: _obscurePass,
                        onChanged: _updateStrength,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 8) return 'Minimum 8 characters required';
                          return null;
                        },
                      ),

                      // Password strength meter
                      if (_passCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          ...List.generate(4, (i) => Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 4,
                              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                              decoration: BoxDecoration(
                                color: _strengthColor(i),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          )),
                          const SizedBox(width: 8),
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: _strengthColor(0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                      ],
                    ]),
                  ),

                  const SizedBox(height: 8),

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
                    text: 'Create Account',
                    onPressed: _loading ? null : _signUp,
                    loading: _loading,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 24),

                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign in'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

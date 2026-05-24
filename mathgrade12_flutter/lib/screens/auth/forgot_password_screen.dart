import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/ts_text_field.dart';
import '../../widgets/logo_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await context.read<AuthService>().sendPasswordReset(_emailCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      setState(() => _errorMsg = 'Failed to send reset link. Check the email address.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              child: _sent ? _buildSuccess() : _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LogoHeader(
          title: 'Reset Password',
          subtitle: "Enter your email and we'll send you a reset link",
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: TsTextField(
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
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 12),
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
        ],
        const SizedBox(height: 24),
        GradientButton(
          text: 'Send Reset Link',
          onPressed: _loading ? null : _sendReset,
          loading: _loading,
          icon: Icons.send,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.go('/login'),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.mark_email_read_outlined, size: 72, color: AppTheme.success),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'A password reset link has been sent to ${_emailCtrl.text.trim()}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        GradientButton(
          text: 'Back to Login',
          onPressed: () => context.go('/login'),
          icon: Icons.arrow_back,
        ),
      ],
    );
  }
}

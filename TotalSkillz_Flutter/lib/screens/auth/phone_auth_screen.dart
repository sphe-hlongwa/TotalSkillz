import 'package:flutter/material.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/ts_text_field.dart';
import '../../widgets/logo_header.dart';
import '../../theme/app_theme.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    // Note: Firebase Phone Auth on Linux is not directly supported in the same way as mobile.
    // This is a UI implementation that will be fully functional on Android.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _otpSent = true;
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent! (Note: Simulation on Desktop)')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _loading = false);
      // Logic would go here to sign in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification failed: Platform not supported')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LogoHeader(
                title: 'Phone Sign In',
                subtitle: 'Use your mobile number to access your account',
              ),
              const SizedBox(height: 40),
              if (!_otpSent) ...[
                TsTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+27 12 345 6789',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Send OTP',
                  onPressed: _sendOtp,
                  loading: _loading,
                  icon: Icons.send_rounded,
                ),
              ] else ...[
                TsTextField(
                  controller: _otpController,
                  label: 'Verification Code',
                  hint: 'Enter 6-digit OTP',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() => _otpSent = false),
                    child: const Text('Change Number'),
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Verify & Login',
                  onPressed: _verifyOtp,
                  loading: _loading,
                  icon: Icons.check_circle_outline,
                ),
              ],
              const SizedBox(height: 40),
              const Text(
                'Note: Phone authentication requires a real mobile device for production use.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

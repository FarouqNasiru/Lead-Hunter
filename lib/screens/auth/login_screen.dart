import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onGoToSignup;
  final VoidCallback onForgotPassword;

  const LoginScreen({
    super.key,
    required this.onGoToSignup,
    required this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  bool _isLoading   = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; });

    // TODO: Replace with Firebase Auth call
    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() => _isLoading = false);
    // On success: context.go('/home')
    // On failure: setState(() => _errorMsg = e.message);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        body: Stack(
          children: [
            const GridBackground(),
            const GlowAccent(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(48),

                      // Logo + wordmark
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 0),
                        child: Row(
                          children: [
                            const AppLogo(size: 44),
                            const Gap(14),
                            Text(
                              'LeadHunter',
                              style: GoogleFonts.spaceMono(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(52),

                      // Headline
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back.',
                              style: GoogleFonts.spaceMono(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              'Your leads are waiting.',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(40),

                      // Error banner
                      if (_errorMsg != null) ...[
                        FadeSlideIn(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.error.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _errorMsg!,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppTheme.error,
                              ),
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],

                      // Email field
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 160),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Email'),
                            const Gap(8),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.dmSans(
                                color: AppTheme.textPrimary, fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'you@example.com',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter your email';
                                if (!v.contains('@')) return 'Enter a valid email';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const Gap(20),

                      // Password field
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _FieldLabel('Password'),
                                TextButton(
                                  onPressed: widget.onForgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            PasswordField(
                              controller: _passCtrl,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter your password';
                                if (v.length < 6) return 'Password too short';
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                          ],
                        ),
                      ),

                      const Gap(28),

                      // Login CTA
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 320),
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text('Sign in'),
                        ),
                      ),

                      const Gap(28),

                      // Divider
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 360),
                        child: const DividerWithText(text: 'or'),
                      ),

                      const Gap(20),

                      // Google button
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: GoogleSignInButton(
                          onPressed: () {
                            // TODO: implement Google sign-in
                          },
                        ),
                      ),

                      const Gap(40),

                      // Sign up link
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 440),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                              children: [
                                const TextSpan(text: "Don't have an account? "),
                                TextSpan(
                                  text: 'Create one',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = widget.onGoToSignup,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Gap(32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}
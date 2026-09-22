import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ForgotPasswordScreen({super.key, required this.onBack});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading  = false;
  bool _sent       = false;

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: FirebaseAuth.instance.sendPasswordResetEmail(email: _emailCtrl.text)
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() { _isLoading = false; _sent = true; });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(32),

                      // Back button
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.bgInput,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderDim),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppTheme.textSecondary,
                          ),
                        ),
                      ),

                      const Gap(40),

                      if (!_sent) ...[
                        FadeSlideIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reset password',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 26, fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Gap(10),
                              Text(
                                "Enter your email and we'll send you a reset link.",
                                style: GoogleFonts.dmSans(
                                  fontSize: 15, color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const Gap(40),
                              Text(
                                'Email',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13, fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const Gap(8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
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
                              const Gap(28),
                              ElevatedButton(
                                onPressed: _handleReset,
                                child: const Text('Send reset link'),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Success state
                        FadeSlideIn(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.greenGlow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.greenDim),
                                ),
                                child: const Icon(
                                  Icons.mark_email_read_outlined,
                                  color: AppTheme.green, size: 28,
                                ),
                              ),
                              const Gap(24),
                              Text(
                                'Check your inbox',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 24, fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Gap(12),
                              Text(
                                "We've sent a reset link to ${_emailCtrl.text}. Check your spam folder if you don't see it.",
                                style: GoogleFonts.dmSans(
                                  fontSize: 15, color: AppTheme.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                              const Gap(36),
                              ElevatedButton(
                                onPressed: widget.onBack,
                                child: const Text('Back to sign in'),
                              ),
                            ],
                          ),
                        ),
                      ],
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
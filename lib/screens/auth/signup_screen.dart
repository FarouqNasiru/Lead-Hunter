import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onGoToLogin;

  const SignupScreen({
    super.key,
    required this.onGoToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _isLoading      = false;
  bool _agreedToTerms  = false;
  String? _errorMsg;

  // Selected freelancer type
  String? _selectedRole;
  static const _roles = [
    'Web Developer',
    'Graphic Designer',
    'Copywriter',
    'Social Media Manager',
    'Photographer / Videographer',
    'SEO Specialist',
    'App Developer',
    'Translator',
    'Accountant / Bookkeeper',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      setState(() => _errorMsg = 'Please agree to the terms to continue.');
      return;
    }
    setState(() { _isLoading = true; _errorMsg = null; });

    // TODO: Replace with Firebase Auth createUserWithEmailAndPassword
    await Future.delayed(const Duration(milliseconds: 1400));

    setState(() => _isLoading = false);
    // On success: store role in Firestore, context.go('/home')
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
            // Green glow — bottom right this time for variety
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.green.withOpacity(0.12),
                      AppTheme.green.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(32),

                      // Back + Logo
                      FadeSlideIn(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: widget.onGoToLogin,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.bgInput,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.borderDim),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            const Gap(14),
                            const AppLogo(size: 36),
                          ],
                        ),
                      ),

                      const Gap(36),

                      // Headline
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start hunting\nleads today.',
                              style: GoogleFonts.spaceMono(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.greenGlow,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.greenDim.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    'FREE',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.green,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  '10 leads/month, no credit card',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Gap(32),

                      // Error banner
                      if (_errorMsg != null) ...[
                        Container(
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
                              fontSize: 13, color: AppTheme.error,
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],

                      // Full name
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: _FormField(
                          label: 'Full name',
                          child: TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            style: GoogleFonts.dmSans(
                              color: AppTheme.textPrimary, fontSize: 15,
                            ),
                            decoration: const InputDecoration(hintText: 'Jane Smith'),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Enter your name' : null,
                          ),
                        ),
                      ),

                      const Gap(18),

                      // Email
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 180),
                        child: _FormField(
                          label: 'Email',
                          child: TextFormField(
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
                        ),
                      ),

                      const Gap(18),

                      // Freelancer role picker
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: _FormField(
                          label: 'I am a',
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            hint: Text(
                              'Select your freelance field',
                              style: GoogleFonts.dmSans(
                                color: AppTheme.textHint, fontSize: 15,
                              ),
                            ),
                            dropdownColor: AppTheme.bgCard,
                            style: GoogleFonts.dmSans(
                              color: AppTheme.textPrimary, fontSize: 15,
                            ),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.bgInput,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.borderDim,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.borderDim,
                                ),
                              ),
                            ),
                            items: _roles
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedRole = v),
                            validator: (v) => v == null ? 'Select your field' : null,
                          ),
                        ),
                      ),

                      const Gap(18),

                      // Password
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 260),
                        child: _FormField(
                          label: 'Password',
                          child: PasswordField(
                            controller: _passCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter a password';
                              if (v.length < 8) return 'At least 8 characters';
                              return null;
                            },
                          ),
                        ),
                      ),

                      const Gap(18),

                      // Confirm password
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 300),
                        child: _FormField(
                          label: 'Confirm password',
                          child: PasswordField(
                            controller: _confirmCtrl,
                            hintText: 'Repeat your password',
                            onFieldSubmitted: (_) => _handleSignup(),
                            validator: (v) {
                              if (v != _passCtrl.text) return "Passwords don't match";
                              return null;
                            },
                          ),
                        ),
                      ),

                      const Gap(20),

                      // Terms checkbox
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 340),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _agreedToTerms
                                      ? AppTheme.green
                                      : AppTheme.bgInput,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _agreedToTerms
                                        ? AppTheme.green
                                        : AppTheme.borderDim,
                                    width: 1.5,
                                  ),
                                ),
                                child: _agreedToTerms
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: Color(0xFF080C08),
                                      )
                                    : null,
                              ),
                              const Gap(12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: AppTheme.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // TODO: open terms
                                          },
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: AppTheme.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            // TODO: open privacy policy
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Gap(28),

                      // Signup CTA
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 380),
                        child: ElevatedButton(
                          onPressed: _handleSignup,
                          child: const Text('Create free account'),
                        ),
                      ),

                      const Gap(28),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 400),
                        child: const DividerWithText(text: 'or'),
                      ),

                      const Gap(20),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 420),
                        child: GoogleSignInButton(
                          onPressed: () {
                            // TODO: Google sign-in
                          },
                        ),
                      ),

                      const Gap(32),

                      // Login link
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
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign in',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = widget.onGoToLogin,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Gap(40),
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

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const Gap(8),
        child,
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

enum _AuthView { login, signup, forgotPassword }

/// Coordinates the three auth screens with animated transitions.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  _AuthView _current = _AuthView.login;

  void _show(_AuthView view) => setState(() => _current = view);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: switch (_current) {
        _AuthView.login => LoginScreen(
            key: const ValueKey('login'),
            onGoToSignup: () => _show(_AuthView.signup),
            onForgotPassword: () => _show(_AuthView.forgotPassword),
          ),
        _AuthView.signup => SignupScreen(
            key: const ValueKey('signup'),
            onGoToLogin: () => _show(_AuthView.login),
          ),
        _AuthView.forgotPassword => ForgotPasswordScreen(
            key: const ValueKey('forgot'),
            onBack: () => _show(_AuthView.login),
          ),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_flow.dart';
import 'navigation/app_navigator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force dark status bar icons & transparent system bars
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // TODO: Add Firebase.initializeApp() here before runApp
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LeadHunterApp());
}

class LeadHunterApp extends StatelessWidget {
  const LeadHunterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeadHunter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Switch between AuthFlow() and AppNavigator() based on auth state
      // TODO: Use go_router + FirebaseAuth.authStateChanges() for real routing
      home: const AppNavigator(), // set to AuthFlow() to see login screens
    );
  }
}

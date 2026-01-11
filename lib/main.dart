import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = await PreferenceService.getInstance();
  final hasOnboarded = prefService.hasCompletedOnboarding();

  runApp(WallpaperApp(showOnboarding: !hasOnboarded));
}

class WallpaperApp extends StatelessWidget {
  const WallpaperApp({super.key, required this.showOnboarding});

  final bool showOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),
    );
  }
}

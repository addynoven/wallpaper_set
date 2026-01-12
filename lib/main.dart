import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'services/preference_service.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI to blend with app background
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent to show app background
      statusBarIconBrightness: Brightness.light, // White icons
      systemNavigationBarColor: Colors.black, // Match app background
      systemNavigationBarIconBrightness: Brightness.light, // White icons
    ),
  );

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
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: showOnboarding ? const WelcomeScreen() : const MainScreen(),
    );
  }
}

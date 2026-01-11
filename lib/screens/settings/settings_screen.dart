import 'package:flutter/material.dart';
import '../../services/preference_service.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.showAsGrid,
    required this.onLayoutToggled,
  });

  final bool showAsGrid;
  final ValueChanged<bool> onLayoutToggled;

  Future<void> _redoPreferences(BuildContext context) async {
    final prefService = await PreferenceService.getInstance();
    await prefService.resetOnboarding();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text(
              'Grid View',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Switch between grid and full screen view',
              style: TextStyle(color: Colors.grey),
            ),
            value: showAsGrid,
            onChanged: onLayoutToggled,
            secondary: const Icon(Icons.grid_view, color: Colors.white),
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.grey,
          ),
          const Divider(color: Colors.grey),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.white),
            title: const Text(
              'Redo Preferences',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Swipe through categories again to update your preferences',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
            onTap: () => _redoPreferences(context),
          ),
        ],
      ),
    );
  }
}

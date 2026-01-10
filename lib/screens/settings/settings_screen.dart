import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.showAsGrid,
    required this.onLayoutToggled,
  });

  final bool showAsGrid;
  final ValueChanged<bool> onLayoutToggled;

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
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../components/wallpaper_selection/action_button.dart';
import '../../components/wallpaper_selection/set_wallpaper_sheet.dart';

class WallpaperSelectionScreen extends StatelessWidget {
  const WallpaperSelectionScreen({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Column(
        children: [
          Expanded(child: _buildWallpaperPreview()),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildWallpaperPreview() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularActionButton(icon: Icons.download, label: 'Download'),
          CircularActionButton(
            icon: Icons.wallpaper,
            label: 'Set Wall',
            onTap: () => showSetWallpaperSheet(context, assetPath),
          ),
          CircularActionButton(icon: Icons.bookmark_border, label: 'Saved'),
        ],
      ),
    );
  }
}

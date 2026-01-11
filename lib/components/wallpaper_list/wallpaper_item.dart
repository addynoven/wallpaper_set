import 'package:flutter/material.dart';
import '../../screens/wallpaper_selection/wallpaper_selection_screen.dart';

class FullScreenWallpaperItem extends StatelessWidget {
  const FullScreenWallpaperItem({
    super.key,
    required this.assetPath,
    this.aspectRatio = 1.0,
  });

  final String assetPath;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openWallpaperSelection(context),
      child: SizedBox.expand(child: Image.asset(assetPath, fit: BoxFit.cover)),
    );
  }

  void _openWallpaperSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperSelectionScreen(
          assetPath: assetPath,
          aspectRatio: aspectRatio,
        ),
      ),
    );
  }
}

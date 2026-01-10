import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/wallpaper_data.dart';
import '../../components/wallpaper_list/wallpaper_item.dart';
import '../../screens/wallpaper_selection/wallpaper_selection_screen.dart';

class WallpaperListScreen extends StatelessWidget {
  const WallpaperListScreen({super.key, required this.showAsGrid});

  final bool showAsGrid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: showAsGrid ? _buildGridView() : _buildFullScreenPageView(),
    );
  }

  Widget _buildGridView() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: allWallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = allWallpapers[index];
        return WallpaperGridTile(
          assetPath: wallpaper.assetPath,
          aspectRatio: wallpaper.aspectRatio,
          onTap: () => _openWallpaperSelection(context, wallpaper.assetPath),
        );
      },
    );
  }

  Widget _buildFullScreenPageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: allWallpapers.length,
      itemBuilder: (context, index) {
        return FullScreenWallpaperItem(
          assetPath: allWallpapers[index].assetPath,
        );
      },
    );
  }

  void _openWallpaperSelection(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperSelectionScreen(assetPath: assetPath),
      ),
    );
  }
}

class WallpaperGridTile extends StatelessWidget {
  const WallpaperGridTile({
    super.key,
    required this.assetPath,
    required this.aspectRatio,
    required this.onTap,
  });

  final String assetPath;
  final double aspectRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

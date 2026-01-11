import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/wallpaper_data.dart';
import '../wallpaper_selection/wallpaper_selection_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key, required this.category});

  final WallpaperCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(category.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        padding: const EdgeInsets.all(8),
        itemCount: category.wallpapers.length,
        itemBuilder: (context, index) {
          final wallpaper = category.wallpapers[index];
          return _WallpaperTile(
            wallpaper: wallpaper,
            onTap: () => _openWallpaperSelection(context, wallpaper),
          );
        },
      ),
    );
  }

  void _openWallpaperSelection(BuildContext context, Wallpaper wallpaper) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperSelectionScreen(
          assetPath: wallpaper.assetPath,
          aspectRatio: wallpaper.aspectRatio,
        ),
      ),
    );
  }
}

class _WallpaperTile extends StatelessWidget {
  const _WallpaperTile({required this.wallpaper, required this.onTap});

  final Wallpaper wallpaper;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: wallpaper.aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(wallpaper.assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

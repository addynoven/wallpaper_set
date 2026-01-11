import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../services/database_service.dart';
import '../wallpaper_selection/wallpaper_selection_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _dbService = DatabaseService();
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  StreamSubscription<void>? _dbSubscription;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _dbSubscription = _dbService.onDatabaseChanged.listen((_) {
      _loadFavorites();
    });
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _dbService.getAllFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.favorite_border, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        final assetPath = favorite['asset_path'] as String;
        final aspectRatio = favorite['aspect_ratio'] as double;

        return GestureDetector(
          onTap: () => _openWallpaperSelection(context, assetPath, aspectRatio),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Hero(
              tag: assetPath, // Simple tag for now
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openWallpaperSelection(
    BuildContext context,
    String assetPath,
    double aspectRatio,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperSelectionScreen(
          assetPath: assetPath,
          aspectRatio: aspectRatio,
        ),
      ),
    );
    // Refresh list when returning, as item might have been unfavorited
    _loadFavorites();
  }
}

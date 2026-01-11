import 'package:flutter/material.dart';
import '../../components/wallpaper_selection/action_button.dart';
import '../../components/wallpaper_selection/set_wallpaper_sheet.dart';
import '../../components/wallpaper_selection/wallpaper_crop_editor.dart';
import '../../services/database_service.dart';

class WallpaperSelectionScreen extends StatefulWidget {
  const WallpaperSelectionScreen({
    super.key,
    required this.assetPath,
    this.aspectRatio = 1.0,
  });

  final String assetPath;
  final double aspectRatio;

  @override
  State<WallpaperSelectionScreen> createState() =>
      _WallpaperSelectionScreenState();
}

class _WallpaperSelectionScreenState extends State<WallpaperSelectionScreen> {
  bool _isFavorite = false;
  final _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await _dbService.isFavorite(widget.assetPath);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _dbService.toggleFavorite(
      widget.assetPath,
      widget.aspectRatio,
    );
    if (mounted) {
      setState(() {
        _isFavorite = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _openCropEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperCropEditor(assetPath: widget.assetPath),
      ),
    );
  }

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
          widget.assetPath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircularActionButton(
            icon: Icons.crop,
            label: 'Crop',
            onTap: _openCropEditor,
          ),
          CircularActionButton(
            icon: Icons.wallpaper,
            label: 'Set Wall',
            onTap: () => showSetWallpaperSheet(context, widget.assetPath),
          ),
          CircularActionButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            label: 'Favorite',
            onTap: _toggleFavorite,
          ),
        ],
      ),
    );
  }
}

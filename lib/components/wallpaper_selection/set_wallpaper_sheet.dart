import 'dart:ui';

import 'package:flutter/material.dart';
import '../../services/image_processing_service.dart';
import '../../services/wallpaper_service.dart';

void showSetWallpaperSheet(BuildContext context, String assetPath) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return _SetWallpaperSheetContent(assetPath: assetPath);
    },
  );
}

class _SetWallpaperSheetContent extends StatefulWidget {
  final String assetPath;

  const _SetWallpaperSheetContent({required this.assetPath});

  @override
  State<_SetWallpaperSheetContent> createState() =>
      _SetWallpaperSheetContentState();
}

class _SetWallpaperSheetContentState extends State<_SetWallpaperSheetContent> {
  WallpaperScaleMode _selectedScaleMode = WallpaperScaleMode.fill;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Center(
            child: Text(
              'Set Wallpaper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Scale mode selector
          const Text(
            'Fit Mode',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _buildScaleModeSelector(),
          const SizedBox(height: 20),

          // Destination options
          const Text(
            'Apply To',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),

          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            WallpaperDestinationOption(
              icon: Icons.home,
              title: 'Home Screen',
              onTap: () => _setWallpaper(context, _setHomeScreen),
            ),
            WallpaperDestinationOption(
              icon: Icons.lock,
              title: 'Lock Screen',
              onTap: () => _setWallpaper(context, _setLockScreen),
            ),
            WallpaperDestinationOption(
              icon: Icons.smartphone,
              title: 'Both Screens',
              onTap: () => _setWallpaper(context, _setBothScreens),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScaleModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: WallpaperScaleMode.values.map((mode) {
          final isSelected = mode == _selectedScaleMode;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedScaleMode = mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForMode(mode),
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLabelForMode(mode),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForMode(WallpaperScaleMode mode) {
    switch (mode) {
      case WallpaperScaleMode.fill:
        return Icons.crop_free;
      case WallpaperScaleMode.fit:
        return Icons.fit_screen;
      case WallpaperScaleMode.stretch:
        return Icons.open_in_full;
      case WallpaperScaleMode.center:
        return Icons.center_focus_strong;
    }
  }

  String _getLabelForMode(WallpaperScaleMode mode) {
    switch (mode) {
      case WallpaperScaleMode.fill:
        return 'Fill';
      case WallpaperScaleMode.fit:
        return 'Fit';
      case WallpaperScaleMode.stretch:
        return 'Stretch';
      case WallpaperScaleMode.center:
        return 'Center';
    }
  }

  Future<void> _setWallpaper(
    BuildContext context,
    Future<String?> Function() wallpaperOperation,
  ) async {
    setState(() => _isProcessing = true);

    final result = await wallpaperOperation();

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? 'Wallpaper set successfully!')),
      );
    }
  }

  Future<String?> _setHomeScreen() {
    final size = _getScreenSize();
    return WallpaperService.setHomeScreenWallpaper(
      widget.assetPath,
      screenWidth: size.width.toInt(),
      screenHeight: size.height.toInt(),
      scaleMode: _selectedScaleMode,
    );
  }

  Future<String?> _setLockScreen() {
    final size = _getScreenSize();
    return WallpaperService.setLockScreenWallpaper(
      widget.assetPath,
      screenWidth: size.width.toInt(),
      screenHeight: size.height.toInt(),
      scaleMode: _selectedScaleMode,
    );
  }

  Future<String?> _setBothScreens() {
    final size = _getScreenSize();
    return WallpaperService.setBothScreensWallpaper(
      widget.assetPath,
      screenWidth: size.width.toInt(),
      screenHeight: size.height.toInt(),
      scaleMode: _selectedScaleMode,
    );
  }

  Size _getScreenSize() {
    final view = PlatformDispatcher.instance.implicitView;
    if (view != null) {
      final physicalSize = view.physicalSize;
      return physicalSize;
    }
    // Fallback to a common resolution
    return const Size(1080, 1920);
  }
}

class WallpaperDestinationOption extends StatelessWidget {
  const WallpaperDestinationOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

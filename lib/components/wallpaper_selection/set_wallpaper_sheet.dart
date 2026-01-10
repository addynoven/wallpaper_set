import 'package:flutter/material.dart';
import '../../services/wallpaper_service.dart';

void showSetWallpaperSheet(BuildContext context, String assetPath) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WallpaperDestinationOption(
              icon: Icons.home,
              title: 'Home Screen',
              onTap: () => _setWallpaperAndClose(
                sheetContext,
                WallpaperService.setHomeScreenWallpaper(assetPath),
              ),
            ),
            WallpaperDestinationOption(
              icon: Icons.lock,
              title: 'Lock Screen',
              onTap: () => _setWallpaperAndClose(
                sheetContext,
                WallpaperService.setLockScreenWallpaper(assetPath),
              ),
            ),
            WallpaperDestinationOption(
              icon: Icons.smartphone,
              title: 'Both Screens',
              onTap: () => _setWallpaperAndClose(
                sheetContext,
                WallpaperService.setBothScreensWallpaper(assetPath),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _setWallpaperAndClose(
  BuildContext context,
  Future<String?> wallpaperOperation,
) async {
  Navigator.pop(context);
  final result = await wallpaperOperation;

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result ?? 'Wallpaper set successfully!')),
    );
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
      onTap: onTap,
    );
  }
}

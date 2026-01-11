import 'dart:math';

class Wallpaper {
  final String assetPath;
  final double aspectRatio;

  const Wallpaper({required this.assetPath, required this.aspectRatio});
}

class WallpaperCategory {
  final String id;
  final String name;
  final String emoji;
  final List<Wallpaper> wallpapers;

  const WallpaperCategory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.wallpapers,
  });

  String get thumbnailPath =>
      wallpapers.isNotEmpty ? wallpapers.first.assetPath : '';
  int get count => wallpapers.length;
}

// Helper to create a wallpaper with random aspect ratio
Wallpaper _wp(int index) {
  final randomGenerator = Random(index);
  final randomAspectRatio = 0.6 + (randomGenerator.nextDouble() * 0.5);
  return Wallpaper(
    assetPath: 'assets/images/img$index.png',
    aspectRatio: randomAspectRatio,
  );
}

// All wallpapers flat list (for backward compatibility)
final List<Wallpaper> allWallpapers = List.generate(82, (i) => _wp(i + 1));

// Organized categories
final List<WallpaperCategory> wallpaperCategories = [
  WallpaperCategory(
    id: 'anime',
    name: 'Anime',
    emoji: '🎌',
    wallpapers: [20, 21, 23, 24, 25, 43, 78, 79].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'bugcat_capoo',
    name: 'Bugcat Capoo',
    emoji: '🐱',
    wallpapers: [
      14,
      15,
      16,
      17,
      18,
      19,
      26,
      27,
      28,
      29,
    ].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'we_bare_bears',
    name: 'We Bare Bears',
    emoji: '🐻',
    wallpapers: [
      12,
      13,
      31,
      32,
      34,
      46,
      47,
      48,
      49,
    ].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'cute_animals',
    name: 'Cute Animals',
    emoji: '🐶',
    wallpapers: [
      7,
      8,
      11,
      22,
      33,
      44,
      62,
      63,
      65,
      67,
      70,
      71,
      72,
      73,
      80,
      81,
    ].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'kawaii_faces',
    name: 'Kawaii Faces',
    emoji: '😊',
    wallpapers: [1, 45, 50, 52, 53, 54, 56].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'cat_art',
    name: 'Cat Art',
    emoji: '🐈‍⬛',
    wallpapers: [41, 42, 55, 69, 74, 75].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'spongebob',
    name: 'SpongeBob',
    emoji: '🧽',
    wallpapers: [10, 57, 58, 59, 60].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'chibi_heroes',
    name: 'Chibi Heroes',
    emoji: '🦸',
    wallpapers: [35, 36, 77].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'pokemon',
    name: 'Pokemon',
    emoji: '⚡',
    wallpapers: [2, 3, 4, 5, 6].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'minimalist',
    name: 'Minimalist',
    emoji: '🌑',
    wallpapers: [37, 38, 39, 40, 51, 64, 76, 82].map((i) => _wp(i)).toList(),
  ),
  WallpaperCategory(
    id: 'ghibli_style',
    name: 'Ghibli Style',
    emoji: '🌿',
    wallpapers: [9, 61, 66].map((i) => _wp(i)).toList(),
  ),
];

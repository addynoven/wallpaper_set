import 'dart:math';

class Wallpaper {
  final String assetPath;
  final double aspectRatio;

  const Wallpaper({required this.assetPath, required this.aspectRatio});
}

final List<Wallpaper> allWallpapers = _generateWallpapers(totalCount: 82);

List<Wallpaper> _generateWallpapers({required int totalCount}) {
  return List.generate(totalCount, (index) {
    final randomGenerator = Random(index);
    final randomAspectRatio = 0.6 + (randomGenerator.nextDouble() * 0.5);

    return Wallpaper(
      assetPath: 'assets/images/img${index + 1}.png',
      aspectRatio: randomAspectRatio,
    );
  });
}

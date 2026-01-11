import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/wallpaper_data.dart';
import '../../services/preference_service.dart';
import '../../components/wallpaper_list/wallpaper_item.dart';
import '../../screens/wallpaper_selection/wallpaper_selection_screen.dart';

class WallpaperListScreen extends StatefulWidget {
  const WallpaperListScreen({super.key, required this.showAsGrid});

  final bool showAsGrid;

  @override
  State<WallpaperListScreen> createState() => _WallpaperListScreenState();
}

class _WallpaperListScreenState extends State<WallpaperListScreen> {
  List<Wallpaper> _sortedWallpapers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSortedWallpapers();
  }

  Future<void> _loadSortedWallpapers() async {
    final prefService = await PreferenceService.getInstance();
    final scores = prefService.getAllCategoryScores();

    final wallpapersWithScores = <MapEntry<Wallpaper, int>>[];

    for (final category in wallpaperCategories) {
      final score = scores[category.id] ?? 0;
      for (final wallpaper in category.wallpapers) {
        wallpapersWithScores.add(MapEntry(wallpaper, score));
      }
    }

    wallpapersWithScores.sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _sortedWallpapers = wallpapersWithScores.map((e) => e.key).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: widget.showAsGrid ? _buildGridView() : _buildFullScreenPageView(),
    );
  }

  Widget _buildGridView() {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      itemCount: _sortedWallpapers.length,
      itemBuilder: (context, index) {
        final wallpaper = _sortedWallpapers[index];
        return AnimatedWallpaperTile(
          index: index,
          assetPath: wallpaper.assetPath,
          aspectRatio: wallpaper.aspectRatio,
          onTap: () => _openWallpaperSelection(
            context,
            wallpaper.assetPath,
            wallpaper.aspectRatio,
          ),
        );
      },
    );
  }

  Widget _buildFullScreenPageView() {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _sortedWallpapers.length,
      itemBuilder: (context, index) {
        return FullScreenWallpaperItem(
          assetPath: _sortedWallpapers[index].assetPath,
          aspectRatio: _sortedWallpapers[index].aspectRatio,
        );
      },
    );
  }

  void _openWallpaperSelection(
    BuildContext context,
    String assetPath,
    double aspectRatio,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WallpaperSelectionScreen(
              assetPath: assetPath,
              aspectRatio: aspectRatio,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

// Animated grid tile with staggered fade-in and scale
class AnimatedWallpaperTile extends StatefulWidget {
  const AnimatedWallpaperTile({
    super.key,
    required this.index,
    required this.assetPath,
    required this.aspectRatio,
    required this.onTap,
  });

  final int index;
  final String assetPath;
  final double aspectRatio;
  final VoidCallback onTap;

  @override
  State<AnimatedWallpaperTile> createState() => _AnimatedWallpaperTileState();
}

class _AnimatedWallpaperTileState extends State<AnimatedWallpaperTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Staggered delay based on index
    Future.delayed(Duration(milliseconds: (widget.index % 10) * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: _TapAnimationWrapper(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Hero(
              tag: widget.assetPath,
              child: Image.asset(widget.assetPath, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}

// Tap animation wrapper for press feedback
class _TapAnimationWrapper extends StatefulWidget {
  const _TapAnimationWrapper({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_TapAnimationWrapper> createState() => _TapAnimationWrapperState();
}

class _TapAnimationWrapperState extends State<_TapAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

// Keep for backward compatibility
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

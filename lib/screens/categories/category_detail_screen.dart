import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/wallpaper_data.dart';
import '../wallpaper_selection/wallpaper_selection_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key, required this.category});

  final WallpaperCategory category;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Animated App Bar
          SliverAppBar(
            backgroundColor: Colors.black,
            floating: true,
            pinned: true,
            expandedHeight: 100,
            leading: _AnimatedBackButton(controller: _controller),
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Text(
                      widget.category.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Wallpaper count badge
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _AnimatedBadge(
                controller: _controller,
                count: widget.category.count,
              ),
            ),
          ),

          // Wallpaper grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: widget.category.wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = widget.category.wallpapers[index];
                return _AnimatedWallpaperTile(
                  index: index,
                  controller: _controller,
                  wallpaper: wallpaper,
                  onTap: () => _openWallpaperSelection(context, wallpaper),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _openWallpaperSelection(BuildContext context, Wallpaper wallpaper) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondary) =>
            WallpaperSelectionScreen(
              assetPath: wallpaper.assetPath,
              aspectRatio: wallpaper.aspectRatio,
            ),
        transitionsBuilder: (context, animation, secondary, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
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

// Animated back button
class _AnimatedBackButton extends StatelessWidget {
  const _AnimatedBackButton({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final animation =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0, 0.4, curve: Curves.easeOutCubic),
          ),
        );

    return SlideTransition(
      position: animation,
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

// Animated count badge
class _AnimatedBadge extends StatelessWidget {
  const _AnimatedBadge({required this.controller, required this.count});

  final AnimationController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(scale: animation.value, child: child),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 16),
              const SizedBox(width: 6),
              Text(
                '$count wallpapers',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Animated wallpaper tile with staggered entrance
class _AnimatedWallpaperTile extends StatefulWidget {
  const _AnimatedWallpaperTile({
    required this.index,
    required this.controller,
    required this.wallpaper,
    required this.onTap,
  });

  final int index;
  final AnimationController controller;
  final Wallpaper wallpaper;
  final VoidCallback onTap;

  @override
  State<_AnimatedWallpaperTile> createState() => _AnimatedWallpaperTileState();
}

class _AnimatedWallpaperTileState extends State<_AnimatedWallpaperTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _tapAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _tapAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final delay = (widget.index % 6) * 0.08;
    final entranceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(
          (0.3 + delay).clamp(0, 1),
          (0.7 + delay).clamp(0, 1),
          curve: Curves.easeOutBack,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: entranceAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: entranceAnimation.value.clamp(0, 1),
          child: Transform.scale(
            scale: 0.8 + (0.2 * entranceAnimation.value),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _tapController.forward(),
        onTapUp: (_) {
          _tapController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _tapController.reverse(),
        child: AnimatedBuilder(
          animation: _tapAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _tapAnimation.value, child: child);
          },
          child: AspectRatio(
            aspectRatio: widget.wallpaper.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Hero(
                tag: widget.wallpaper.assetPath,
                child: Image.asset(
                  widget.wallpaper.assetPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

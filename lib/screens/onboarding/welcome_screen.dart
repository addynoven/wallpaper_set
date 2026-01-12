import 'package:flutter/material.dart';
import '../../data/wallpaper_data.dart';
import 'preferences_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller1; // Fast (left column)
  late AnimationController _controller2; // Medium (middle column)
  late AnimationController _controller3; // Slow (right column)

  // Split wallpapers into 3 columns
  late List<String> _column1;
  late List<String> _column2;
  late List<String> _column3;

  @override
  void initState() {
    super.initState();

    // Distribute wallpapers across columns
    final allPaths = allWallpapers.map((w) => w.assetPath).toList();
    _column1 = [];
    _column2 = [];
    _column3 = [];

    for (int i = 0; i < allPaths.length; i++) {
      if (i % 3 == 0) {
        _column1.add(allPaths[i]);
      } else if (i % 3 == 1) {
        _column2.add(allPaths[i]);
      } else {
        _column3.add(allPaths[i]);
      }
    }

    // Different speeds for parallax effect
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Fast
    )..repeat();

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35), // Medium
    )..repeat();

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50), // Slow
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Animated Hero Grid (Background) - 3 columns with different speeds
          Positioned.fill(
            child: ClipRect(
              child: Opacity(
                opacity: 0.6,
                child: Row(
                  children: [
                    // Left column - fastest
                    Expanded(
                      child: _InfiniteScrollColumn(
                        controller: _controller1,
                        images: _column1,
                        scrollUp: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Middle column - medium speed
                    Expanded(
                      child: _InfiniteScrollColumn(
                        controller: _controller2,
                        images: _column2,
                        scrollUp: false, // Scroll down for variety
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right column - slowest
                    Expanded(
                      child: _InfiniteScrollColumn(
                        controller: _controller3,
                        images: _column3,
                        scrollUp: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  const Text(
                    "Premium wallpapers for your phone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const PreferencesSelectionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single column of images that scrolls infinitely
class _InfiniteScrollColumn extends StatelessWidget {
  const _InfiniteScrollColumn({
    required this.controller,
    required this.images,
    required this.scrollUp,
  });

  final AnimationController controller;
  final List<String> images;
  final bool scrollUp;

  @override
  Widget build(BuildContext context) {
    // Duplicate the list enough to fill more than 2x screen height
    final extendedImages = [...images, ...images, ...images, ...images];

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // Calculate offset based on animation value
            // We move by the height of one set of images to create seamless loop
            final totalHeight = constraints.maxHeight * 2;
            final offset = scrollUp
                ? -controller.value * totalHeight
                : controller.value * totalHeight - totalHeight;

            return Transform.translate(offset: Offset(0, offset), child: child);
          },
          child: OverflowBox(
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: Column(
              children: extendedImages.map((imagePath) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 0.7, // Taller images for wallpaper feel
                      child: Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

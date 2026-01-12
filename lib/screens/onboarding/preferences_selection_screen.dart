import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../data/wallpaper_data.dart';
import '../../services/preference_service.dart';
import '../main_screen.dart';

class PreferencesSelectionScreen extends StatefulWidget {
  const PreferencesSelectionScreen({super.key});

  @override
  State<PreferencesSelectionScreen> createState() =>
      _PreferencesSelectionScreenState();
}

class _PreferencesSelectionScreenState
    extends State<PreferencesSelectionScreen> {
  final CardSwiperController _controller = CardSwiperController();
  PreferenceService? _prefService;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _prefService = await PreferenceService.getInstance();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final category = wallpaperCategories[previousIndex];
    final liked = direction == CardSwiperDirection.right;

    _prefService?.saveCategoryPreference(category.id, liked: liked);

    setState(() {
      _currentIndex = currentIndex ?? wallpaperCategories.length;
    });
  }

  void _onEnd() async {
    await _prefService?.setOnboardingComplete();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'What do you like?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Swipe right to like, left to skip',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentIndex + 1} / ${wallpaperCategories.length}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Swipe Cards
            Expanded(
              child: CardSwiper(
                controller: _controller,
                cardsCount: wallpaperCategories.length,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(0, 40.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                onSwipe: (prevIndex, currIndex, direction) {
                  _onSwipe(prevIndex, currIndex, direction);
                  return true;
                },
                onEnd: _onEnd,
                cardBuilder: (context, index, x, y) {
                  return _buildCard(
                    wallpaperCategories[index],
                    (x as num).toDouble(),
                  );
                },
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.close,
                    color: Colors.red,
                    onTap: () => _controller.swipe(CardSwiperDirection.left),
                  ),
                  _ActionButton(
                    icon: Icons.favorite,
                    color: Colors.green,
                    onTap: () => _controller.swipe(CardSwiperDirection.right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(WallpaperCategory category, double percentThresholdX) {
    final isLiking = percentThresholdX > 0;
    final isDisliking = percentThresholdX < 0;
    final opacity = percentThresholdX.abs().clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(category.thumbnailPath, fit: BoxFit.cover),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Like/Dislike indicator
            if (isLiking)
              Container(
                color: Colors.green.withValues(alpha: opacity * 0.5),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white.withValues(alpha: opacity),
                    size: 100,
                  ),
                ),
              ),
            if (isDisliking)
              Container(
                color: Colors.red.withValues(alpha: opacity * 0.5),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withValues(alpha: opacity),
                    size: 100,
                  ),
                ),
              ),

            // Category info
            Positioned(
              left: 20,
              right: 20,
              bottom: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.count} wallpapers',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}

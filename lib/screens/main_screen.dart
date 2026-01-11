import 'package:flutter/material.dart';
import 'wallpaper_list/wallpaper_list_screen.dart';
import 'categories/categories_screen.dart';
import 'favorites/favorites_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int selectedTabIndex = 0;
  bool useGridLayout = true;

  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;

  @override
  void initState() {
    super.initState();
    _iconControllers = List.generate(
      4,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _iconAnimations = _iconControllers.map((c) {
      return Tween<double>(
        begin: 1,
        end: 1.2,
      ).animate(CurvedAnimation(parent: c, curve: Curves.elasticOut));
    }).toList();

    // Animate initially selected tab
    _iconControllers[selectedTabIndex].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void handleLayoutToggle(bool showGrid) {
    setState(() {
      useGridLayout = showGrid;
    });
  }

  void handleTabSelection(int index) {
    if (index != selectedTabIndex) {
      _iconControllers[selectedTabIndex].reverse();
      _iconControllers[index].forward();
      setState(() {
        selectedTabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: IndexedStack(
            key: ValueKey(selectedTabIndex),
            index: selectedTabIndex,
            children: [
              WallpaperListScreen(showAsGrid: useGridLayout),
              const CategoriesScreen(),
              const FavoritesScreen(),
              SettingsScreen(
                showAsGrid: useGridLayout,
                onLayoutToggled: handleLayoutToggle,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AnimatedNavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: 'Home',
                  isSelected: selectedTabIndex == 0,
                  animation: _iconAnimations[0],
                  onTap: () => handleTabSelection(0),
                ),
                _AnimatedNavItem(
                  icon: Icons.category_outlined,
                  selectedIcon: Icons.category,
                  label: 'Categories',
                  isSelected: selectedTabIndex == 1,
                  animation: _iconAnimations[1],
                  onTap: () => handleTabSelection(1),
                ),
                _AnimatedNavItem(
                  icon: Icons.favorite_outline,
                  selectedIcon: Icons.favorite,
                  label: 'Favorites',
                  isSelected: selectedTabIndex == 2,
                  animation: _iconAnimations[2],
                  onTap: () => handleTabSelection(2),
                ),
                _AnimatedNavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: selectedTabIndex == 3,
                  animation: _iconAnimations[3],
                  onTap: () => handleTabSelection(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  const _AnimatedNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.animation,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Animation<double> animation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.scale(scale: animation.value, child: child);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? Colors.white : Colors.grey,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

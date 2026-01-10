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

class _MainScreenState extends State<MainScreen> {
  int selectedTabIndex = 0;
  bool useGridLayout = true;

  void handleLayoutToggle(bool showGrid) {
    setState(() {
      useGridLayout = showGrid;
    });
  }

  void handleTabSelection(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTabIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: handleTabSelection,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

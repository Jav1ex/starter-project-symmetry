import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/home_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/saved_screen.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/screens/search_screen.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/profile_screen.dart';
import 'package:news_app_clean_architecture/shared/presentation/widgets/brand/brand_bar.dart';

/// The four tabs behind the bottom bar. Pages live in an [IndexedStack] so
/// switching keeps each tab's scroll position and there is no slide.
class HomeShellScreen extends StatefulWidget {
  final int initialTab;

  const HomeShellScreen({super.key, this.initialTab = 0});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late int _index = widget.initialTab.clamp(0, _tabs.length - 1);

  @override
  void didUpdateWidget(HomeShellScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _index = widget.initialTab.clamp(0, _tabs.length - 1);
  }

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search'),
    (icon: Icons.bookmark_outline_rounded, activeIcon: Icons.bookmark_rounded, label: 'Saved'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SafeArea(bottom: false, child: BrandBar()),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [HomeScreen(), SearchScreen(), SavedScreen(), ProfileScreen()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

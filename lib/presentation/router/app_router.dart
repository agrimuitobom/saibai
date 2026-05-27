import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/pest_checker/pest_checker_screen.dart';
import '../screens/crop_encyclopedia/crop_encyclopedia_screen.dart';
import '../screens/blog/blog_screen.dart';
import '../screens/blog/blog_profile_screen.dart';
import '../screens/task/task_screen.dart';
import '../screens/settings/settings_screen.dart';

/// アプリのナビゲーション設定
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/home':
        return MaterialPageRoute(
          builder: (_) => const MainNavigationShell(),
        );
      case '/pest-checker':
        return MaterialPageRoute(
          builder: (_) => const PestCheckerScreen(),
        );
      case '/crop-encyclopedia':
        return MaterialPageRoute(
          builder: (_) => const CropEncyclopediaScreen(),
        );
      case '/crop-encyclopedia/detail':
        final crop = settings.arguments;
        if (crop != null) {
          return MaterialPageRoute(
            builder: (_) => CropDetailScreen(crop: crop as dynamic),
          );
        }
        return _errorRoute();
      case '/blog':
        return MaterialPageRoute(builder: (_) => const BlogScreen());
      case '/blog/profile':
        return MaterialPageRoute(
          builder: (_) => const BlogProfileScreen(),
        );
      case '/task':
        return MaterialPageRoute(builder: (_) => const TaskScreen());
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('ページが見つかりません')),
      ),
    );
  }
}

/// メインナビゲーション（ボトムナビゲーションバー 6項目）
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PestCheckerScreen(),
    CropEncyclopediaScreen(),
    BlogScreen(),
    TaskScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFFFAF7F2),
        indicatorColor: const Color(0xFFD4E8B8),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco),
            label: '病害虫',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: '作物図鑑',
          ),
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'ブログ',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'タスク',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

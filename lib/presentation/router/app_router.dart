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

/// メインナビゲーション（ボトムナビゲーションバー）
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  /// ナビゲーション先の画面リスト
  final List<Widget> _screens = const [
    HomeScreen(),
    PestCheckerScreen(),
    CropEncyclopediaScreen(),
    BlogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bug_report_outlined),
            activeIcon: Icon(Icons.bug_report),
            label: '病害虫',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: '作物図鑑',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'ブログ',
          ),
        ],
      ),
    );
  }
}

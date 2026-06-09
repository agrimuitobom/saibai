import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/task/task_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/growing_crops/growing_crops_screen.dart';
import '../screens/pest_checker/pest_checker_screen.dart';
import '../screens/crop_encyclopedia/crop_list_screen.dart';
import '../screens/crop_encyclopedia/crop_detail_screen.dart';
import '../screens/blog/blog_screen.dart';
import '../screens/blog/blog_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'main_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/pest',
            builder: (context, state) => const PestCheckerScreen(),
          ),
          GoRoute(
            path: '/crops',
            builder: (context, state) => const CropListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CropDetailScreen(cropId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/blog',
            builder: (context, state) => const BlogScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const BlogProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/task',
            builder: (context, state) => const TaskScreen(),
            routes: [
              GoRoute(
                path: 'calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
              GoRoute(
                path: 'growing',
                builder: (context, state) => const GrowingCropsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

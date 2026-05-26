import 'package:flutter/material.dart';

/// アプリ全体のカラーパレット（アースカラーテーマ）
class AppColors {
  AppColors._();

  // プライマリカラー（モスグリーン系）
  static const Color primary = Color(0xFF5A7A3A);
  static const Color primaryLight = Color(0xFF7EA853);
  static const Color primaryDark = Color(0xFF3D5729);
  static const Color primaryContainer = Color(0xFFD4E8B8);

  // セカンダリカラー（ウッドブラウン系）
  static const Color secondary = Color(0xFF8B6340);
  static const Color secondaryLight = Color(0xFFB5845A);
  static const Color secondaryDark = Color(0xFF5E4029);
  static const Color secondaryContainer = Color(0xFFEDD9C4);

  // 背景・サーフェス（ベージュ系）
  static const Color background = Color(0xFFF5F0E8);
  static const Color surface = Color(0xFFFAF7F2);
  static const Color surfaceVariant = Color(0xFFEDE8DF);

  // テキスト
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF2D2417);
  static const Color onSurface = Color(0xFF3D3026);
  static const Color onSurfaceVariant = Color(0xFF6B5E4E);

  // エラー・警告
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFE07B39);
  static const Color success = Color(0xFF4CAF50);

  // ステータスカラー（病害虫チェッカー用）
  static const Color pestDanger = Color(0xFFE53935);
  static const Color pestWarning = Color(0xFFFF8F00);
  static const Color pestSafe = Color(0xFF43A047);

  // 天気ウィジェット
  static const Color weatherSunny = Color(0xFFFFB300);
  static const Color weatherCloudy = Color(0xFF90A4AE);
  static const Color weatherRainy = Color(0xFF42A5F5);

  // カード・ボーダー
  static const Color cardBorder = Color(0xFFD4C9B8);
  static const Color divider = Color(0xFFE0D8CC);
  static const Color shadow = Color(0x1A6B5E4E);

  // スプラッシュグラジエント（ホーム画面）
  static const Color splashGradientStart = Color(0xFF7EA853);
  static const Color splashGradientEnd = Color(0xFF4A7A2A);
}

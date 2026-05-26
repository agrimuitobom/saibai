import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// アプリ全体のテキストスタイル定義
class AppTextStyles {
  AppTextStyles._();

  // 丸みを帯びた読みやすいフォント（Noto Sans JP）
  static TextStyle get _base => GoogleFonts.notoSansJp();

  // 見出し系
  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        height: 1.2,
      );

  static TextStyle get headlineLarge => _base.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        height: 1.3,
      );

  static TextStyle get headlineMedium => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.onBackground,
        height: 1.3,
      );

  static TextStyle get headlineSmall => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onBackground,
        height: 1.4,
      );

  // 本文系
  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.6,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
        height: 1.6,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        height: 1.5,
      );

  // ラベル・キャプション
  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.5,
      );

  // ボタン
  static TextStyle get button => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSecondary => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: 0.5,
      );
}

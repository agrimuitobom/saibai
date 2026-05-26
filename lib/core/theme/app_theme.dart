import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// アプリのテーマ設定（アースカラー・ナチュラルデザイン）
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        background: AppColors.background,
        onBackground: AppColors.onBackground,
        error: AppColors.error,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.cardBorder,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // フォント設定（丸みを帯びた読みやすいNoto Sans JP）
      textTheme: GoogleFonts.notoSansJpTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
        ),
        headlineLarge: GoogleFonts.notoSansJp(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
        ),
        headlineMedium: GoogleFonts.notoSansJp(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.onBackground,
        ),
        headlineSmall: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackground,
        ),
        bodyLarge: GoogleFonts.notoSansJp(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.notoSansJp(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
        ),
        bodySmall: GoogleFonts.notoSansJp(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSansJp(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      // AppBar スタイル
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansJp(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      // カードスタイル（大きめの角丸）
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // 入力フィールドスタイル
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.notoSansJp(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      // ElevatedButton スタイル
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // OutlinedButton スタイル
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // BottomNavigationBar スタイル
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // FloatingActionButton スタイル
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: CircleBorder(),
      ),
      // Divider スタイル
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      // Chip スタイル
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.notoSansJp(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

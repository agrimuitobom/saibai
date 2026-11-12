import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'presentation/router/app_router.dart';

class VegeGroApp extends ConsumerWidget {
  const VegeGroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'ベジグロ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      builder: (context, child) => _PhoneFrame(child: child!),
      locale: const Locale('ja'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('ja'),
        Locale('en'),
      ],
    );
  }
}

/// スマホ向けレイアウトなので、パソコンやタブレットなどの広い画面では
/// 画面いっぱいに引き伸ばさず、スマホ幅で中央に表示する。
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  static const double _maxWidth = 480;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= _maxWidth) return child;
    return ColoredBox(
      color: AppColors.frameBackground,
      child: Center(
        child: Container(
          width: _maxWidth,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Color(0x33000000), blurRadius: 24),
            ],
          ),
          // 中の画面には、枠の幅を画面幅として伝える
          child: MediaQuery(
            data: media.copyWith(size: Size(_maxWidth, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}

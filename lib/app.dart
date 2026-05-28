import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/router/app_router.dart';

/// アプリケーションのルートウィジェット
class VejiGroApp extends StatelessWidget {
  const VejiGroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'ベジグロ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // 日本語ロケール設定
        locale: const Locale('ja', 'JP'),
        supportedLocales: const [
          Locale('ja', 'JP'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          // MaterialLocalizations.delegate,
          // CupertinoLocalizations.delegate,
          // GlobalMaterialLocalizations.delegate,
          // GlobalCupertinoLocalizations.delegate,
          // GlobalWidgetsLocalizations.delegate,
        ],
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

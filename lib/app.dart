import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/settings_provider.dart';


/// PrivacyCam App / PrivacyCam 应用
/// 
/// The root widget of the application.
/// Configures theme, routing, and provides the Riverpod scope.
/// 
/// 应用的根组件。
/// 配置主题、路由，并提供 Riverpod 作用域。

class PrivacyCamApp extends ConsumerWidget {
  const PrivacyCamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    Locale? locale;
    switch (settings.language) {
      case AppLanguage.system:
        locale = null;
        break;
      case AppLanguage.zh:
        // Use only the language code to match our ARB files: zh / en.
        locale = const Locale('zh');
        break;
      case AppLanguage.en:
        locale = const Locale('en');
        break;
    }

    return MaterialApp(
      // App Info / 应用信息
      title: 'PrivacyCam',
      debugShowCheckedModeBanner: false,

      // Theme Configuration / 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme / 跟随系统主题

      // Localization Configuration / 本地化配置
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Home Page / 首页
      home: const HomePage(),
    );
  }
}


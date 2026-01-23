import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

/// PrivacyCam App / PrivacyCam 应用
/// 
/// The root widget of the application.
/// Configures theme, routing, and provides the Riverpod scope.
/// 
/// 应用的根组件。
/// 配置主题、路由，并提供 Riverpod 作用域。

class PrivacyCamApp extends StatelessWidget {
  const PrivacyCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Info / 应用信息
      title: 'PrivacyCam',
      debugShowCheckedModeBanner: false,

      // Theme Configuration / 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme / 跟随系统主题

      // Home Page / 首页
      home: const HomePage(),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Main Entry Point / 主入口
/// 
/// The entry point of the PrivacyCam application.
/// Wraps the app with ProviderScope for Riverpod state management.
/// 
/// PrivacyCam 应用的入口点。
/// 使用 ProviderScope 包裹应用以启用 Riverpod 状态管理。

void main() {
  // Ensure Flutter bindings are initialized
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with Riverpod
  // 使用 Riverpod 运行应用
  runApp(
    const ProviderScope(
      child: PrivacyCamApp(),
    ),
  );
}

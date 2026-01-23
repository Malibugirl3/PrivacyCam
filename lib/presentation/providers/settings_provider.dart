import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置状态模型
class SettingsState {
  final bool useCloud;
  final String serverUrl;

  const SettingsState({
    this.useCloud = true,
    this.serverUrl = 'http://10.0.2.2:5000',
  });

  /// 复制并修改
  SettingsState copyWith({
    bool? useCloud,
    String? serverUrl,
  }) {
    return SettingsState(
      useCloud: useCloud ?? this.useCloud,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }
}

/// 设置状态管理器
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  /// 设置处理模式
  void setUseCloud(bool value) {
    state = state.copyWith(useCloud: value);
  }

  /// 设置服务器地址
  void setServerUrl(String url) {
    state = state.copyWith(serverUrl: url);
  }
}

/// 全局 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
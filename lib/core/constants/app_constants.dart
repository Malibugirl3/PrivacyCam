/// App Constants / 应用常量
/// 
/// Contains all constant values used throughout the app.
/// 包含应用中使用的所有常量值。

class AppConstants {
  // Prevent instantiation / 防止实例化
  AppConstants._();

  // App Info / 应用信息
  static const String appName = 'PrivacyCam';
  static const String appNameCn = '朋友圈隐形衣';
  static const String appVersion = '1.0.0';

  // API Endpoints / API 端点
  static const String baseUrl = 'https://api.privacycam.com';
  static const String protectEndpoint = '/api/v1/protect';

  // Image Settings / 图片设置
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 90;

  // Protection Levels / 保护等级
  static const double protectionLow = 0.3;
  static const double protectionMedium = 0.5;
  static const double protectionHigh = 0.8;

  // Timeouts / 超时设置
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
}


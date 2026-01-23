import '../domain/models/protect_result.dart';
import '../domain/services/image_protect_service.dart';
import '../infrastructure/local/mock_protect_impl.dart';

/// Protect Manager / 保护管理器
///
/// 管理云端和本地保护服务的切换。
/// Manages switching between cloud and local protection services.

class ProtectManager {
  /// 本地服务（目前使用 Mock 实现）
  final ImageProtectService _localService = MockProtectImpl();

  /// 云端服务（暂未实现）
  ImageProtectService? _cloudService;

  /// 当前使用的服务名称
  String get currentServiceName => _cloudService?.serviceName ?? _localService.serviceName;

  /// 设置云端服务
  void setCloudService(ImageProtectService service) {
    _cloudService = service;
  }

  /// 执行保护
  ///
  /// 优先使用云端服务，不可用时降级到本地。
  Future<ProtectResult> protect({
    required String imagePath,
    required double protectionLevel,
    bool preferCloud = true,
  }) async {
    // 如果优先云端且云端可用
    if (preferCloud && _cloudService != null) {
      final isCloudAvailable = await _cloudService!.isAvailable();
      if (isCloudAvailable) {
        return _cloudService!.protect(
          imagePath: imagePath,
          protectionLevel: protectionLevel,
        );
      }
    }

    // 降级到本地服务
    return _localService.protect(
      imagePath: imagePath,
      protectionLevel: protectionLevel,
    );
  }

  /// 检查云端服务是否可用
  Future<bool> isCloudAvailable() async {
    if (_cloudService == null) return false;
    return _cloudService!.isAvailable();
  }
}
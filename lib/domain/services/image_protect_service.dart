import '../models/protect_result.dart';

/// Image Protect Service Interface / 图片保护服务接口
///
/// 定义图片保护的核心能力，由云端或本地实现。
/// Defines the core image protection capability, implemented by cloud or local.

abstract class ImageProtectService {
  /// 对图片应用隐私保护
  ///
  /// [imagePath] - 原始图片路径
  /// [protectionLevel] - 保护强度 (0-100)
  ///
  /// 返回 [ProtectResult] 包含处理结果
  Future<ProtectResult> protect({
    required String imagePath,
    required double protectionLevel,
  });

  /// 检查服务是否可用
  Future<bool> isAvailable();

  /// 获取服务名称（用于显示）
  String get serviceName;
}
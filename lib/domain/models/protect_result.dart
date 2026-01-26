/// Protect Result / 保护结果
///
/// 包含保护处理后的结果信息。
/// Contains the result information after protection processing.

class ProtectResult {
  /// 是否成功
  final bool success;

  /// 处理后的图片路径
  final String? protectedImagePath;

  /// 错误信息（如果失败）
  final String? errorMessage;

  /// 处理耗时（毫秒）
  final int processingTimeMs;

  /// 使用的保护强度
  final double protectionLevel;

  /// 任务 ID
  final String? taskId;

  const ProtectResult({
    required this.success,
    this.protectedImagePath,
    this.errorMessage,
    this.processingTimeMs = 0,
    this.protectionLevel = 0,
    this.taskId,
  });

  /// 创建成功结果
  factory ProtectResult.success({
    required String imagePath,
    required int processingTimeMs,
    required double protectionLevel,
    String? taskId,
  }) {
    return ProtectResult(
      success: true,
      protectedImagePath: imagePath,
      processingTimeMs: processingTimeMs,
      protectionLevel: protectionLevel,
      taskId: taskId,
    );
  }

  /// 创建失败结果
  factory ProtectResult.failure(String error, {String? taskId}) {
    return ProtectResult(
      success: false,
      errorMessage: error,
      taskId: taskId,
    );
  }
}
import 'dart:io';
import 'dart:math';
// import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../domain/models/protect_result.dart';
import '../../domain/services/image_protect_service.dart';

/// Mock Protect Implementation / 模拟保护实现
///
/// 使用简单的像素扰动模拟对抗扰动效果。
/// Uses simple pixel perturbation to simulate adversarial perturbation.

class MockProtectImpl implements ImageProtectService {
  @override
  String get serviceName => '本地处理（模拟）';

  @override
  Future<bool> isAvailable() async => true;

    @override
  Future<ProtectResult> protect({
    required String imagePath,
    required double protectionLevel,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 1. 读取原始图片
      final bytes = await File(imagePath).readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        return ProtectResult.failure('无法解码图片');
      }

      // 2. 应用扰动效果
      final protectedImage = _applyPerturbation(
        originalImage,
        protectionLevel / 100, // 转换为 0-1 范围
      );

      // 3. 保存处理后的图片
      final outputPath = await _saveImage(protectedImage);

      stopwatch.stop();

      return ProtectResult.success(
        imagePath: outputPath,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        protectionLevel: protectionLevel,
      );
    } catch (e) {
      stopwatch.stop();
      return ProtectResult.failure('处理失败: $e');
    }
  }
    /// 应用像素扰动（模拟对抗扰动效果）
  img.Image _applyPerturbation(img.Image image, double strength) {
    final random = Random();
    final result = img.Image.from(image);

    // 扰动强度：0-25 的噪点范围
    final noiseRange = (strength * 25).toInt();

    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final pixel = result.getPixel(x, y);

        // 获取原始颜色值
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // 添加随机扰动
        if (noiseRange > 0) {
          r = _clamp(r + random.nextInt(noiseRange * 2) - noiseRange);
          g = _clamp(g + random.nextInt(noiseRange * 2) - noiseRange);
          b = _clamp(b + random.nextInt(noiseRange * 2) - noiseRange);
        }

        // 设置新像素
        result.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }

    return result;
  }

  /// 限制值在 0-255 范围内
  int _clamp(int value) {
    if (value < 0) return 0;
    if (value > 255) return 255;
    return value;
  }

    /// 保存处理后的图片到临时目录
  Future<String> _saveImage(img.Image image) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/protected_$timestamp.jpg';

    final jpgBytes = img.encodeJpg(image, quality: 90);
    await File(outputPath).writeAsBytes(jpgBytes);

    return outputPath;
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/protect_result.dart';
import '../../domain/services/image_protect_service.dart';

/// Cloud Protect Implementation / 云端保护实现
///
/// 通过 HTTP API 调用云端算法服务。
/// Calls cloud algorithm service via HTTP API.

class CloudProtectImpl implements ImageProtectService {
  /// API 基础地址（待算法组提供）
  final String baseUrl;

  /// API 密钥（如果需要）
  final String? apiKey;

  /// HTTP 客户端
  late final Dio _dio;

  CloudProtectImpl({
    required this.baseUrl,
    this.apiKey,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      },
    ));
  }

  @override
  String get serviceName => '云端处理';

    @override
  Future<bool> isAvailable() async {
    try {
      // 尝试请求健康检查接口
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

    @override
  Future<ProtectResult> protect({
    required String imagePath,
    required double protectionLevel,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 1. 准备上传文件
      final file = File(imagePath);
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
        'protection_level': protectionLevel,
      });

      // 2. 发送请求
      final response = await _dio.post(
        '/api/v1/protect',  // 待算法组确认
        data: formData,
      );

      // 3. 处理响应
      if (response.statusCode == 200) {
        final data = response.data;
        
        // 假设返回 Base64 编码的图片
        // 具体格式需要根据算法组 API 调整
        final String? base64Image = data['protected_image'];
        
        if (base64Image != null) {
          final outputPath = await _saveBase64Image(base64Image);
          stopwatch.stop();
          
          return ProtectResult.success(
            imagePath: outputPath,
            processingTimeMs: stopwatch.elapsedMilliseconds,
            protectionLevel: protectionLevel,
          );
        }
      }

      stopwatch.stop();
      return ProtectResult.failure('服务器返回异常');
    } on DioException catch (e) {
      stopwatch.stop();
      return ProtectResult.failure('网络错误: ${e.message}');
    } catch (e) {
      stopwatch.stop();
      return ProtectResult.failure('处理失败: $e');
    }
  }

    /// 保存 Base64 图片到本地
  Future<String> _saveBase64Image(String base64String) async {
    final bytes = base64Decode(base64String);
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/cloud_protected_$timestamp.jpg';

    await File(outputPath).writeAsBytes(bytes);
    return outputPath;
  }
}
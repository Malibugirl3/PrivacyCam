import 'dart:io';

import 'package:flutter/foundation.dart';  // 为了使用 debugPrint
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/models/protect_result.dart';
import '../../domain/services/image_protect_service.dart';
import '../../domain/models/evalution_result.dart';
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
    String? taskId;

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
      final response = await _retry(
        action: () => _dio.post(
          '/api/v1/protect',
          data: formData,
        ),
        maxRetries: 3,
        delay: const Duration(seconds: 2),
      );

      // 3. 处理响应
      if (response.statusCode == 200) {
        final data = response.data;
        
        
        // image_url
        final String? imageUrl = data['image_url'];
        taskId = data['task_id'];
        
        if(imageUrl != null) {
          final outputPath = await _downloadImage(imageUrl);
          stopwatch.stop();

          return ProtectResult.success(
            imagePath: outputPath,
            processingTimeMs: stopwatch.elapsedMilliseconds,
            protectionLevel: protectionLevel,
            taskId: taskId,
          );
        }
      }

      stopwatch.stop();
      return ProtectResult.failure('服务器返回异常', taskId: taskId);
    } on DioException catch (e) {
      stopwatch.stop();
      
      // 根据错误类型提供更详细的信息
      String errorMsg;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMsg = '连接超时，请检查网络';
          break;
        case DioExceptionType.sendTimeout:
          errorMsg = '发送超时，图片可能太大';
          break;
        case DioExceptionType.receiveTimeout:
          errorMsg = '接收超时，服务器处理中';
          break;
        case DioExceptionType.connectionError:
          errorMsg = '无法连接服务器';
          break;
        case DioExceptionType.badResponse:
          errorMsg = '服务器错误: ${e.response?.statusCode}';
          break;
        default:
          // 打印详细调试信息
          debugPrint('DioException type: ${e.type}');
          debugPrint('DioException error: ${e.error}');
          debugPrint('DioException message: ${e.message}');
          errorMsg = '网络错误 (${e.type.name}): ${e.error ?? e.message ?? "未知"}';
      }
      
      return ProtectResult.failure(errorMsg, taskId: taskId);
    } catch (e) {
      stopwatch.stop();
      return ProtectResult.failure('处理失败: $e', taskId: taskId);
    }
  }

  /// 保存 Base64 图片到本地 旧版，已弃用
  // Future<String> _saveBase64Image(String base64String) async {
  //   final bytes = base64Decode(base64String);
  //   final tempDir = await getTemporaryDirectory();
  //   final timestamp = DateTime.now().millisecondsSinceEpoch;
  //   final outputPath = '${tempDir.path}/cloud_protected_$timestamp.png';

  //   await File(outputPath).writeAsBytes(bytes);
  //   return outputPath;
  // }

  /// 带重试的异步操作
  Future<T> _retry<T>({
    required Future<T> Function() action,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await action();
      } catch (e) {
        debugPrint('操作失败，第 ${i + 1}/${maxRetries} 次: $e');
        if (i == maxRetries - 1) rethrow;  // 最后一次失败，抛出异常
        await Future.delayed(delay * (i + 1));  // 递增延迟
      }
    }
    throw Exception('重试失败');
  }

  /// 从服务器下载图片到本地
  Future<String> _downloadImage(String imageUrl) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tempDir.path}/cloud_protected_$timestamp.jpg';
    
    // 带重试的下载
    await _retry(
      action: () async {
        final response = await _dio.get<List<int>>(
          imageUrl,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );
        await File(outputPath).writeAsBytes(response.data!);
      },
      maxRetries: 3,
      delay: const Duration(seconds: 1),
    );
    
    return outputPath;
  }
    

  Future<EvaluationResult?> getEvaluationResult(String taskId) async {
    try {
      final response = await _dio.get('/api/v1/result/$taskId');
      
      if (response.statusCode == 200) {
        return EvaluationResult.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      // 404 表示任务不存在
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
}
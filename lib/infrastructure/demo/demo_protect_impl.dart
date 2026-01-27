import 'dart:async';
import 'dart:math';
import '../../domain/models/protect_result.dart';
import '../../domain/services/image_protect_service.dart';
import '../../domain/models/evalution_result.dart';

class DemoProtectImpl implements ImageProtectService {
  // 随机数生成器
  static final Random _random = Random();
  
  // 当前选中的数据集索引（每次 protect 时随机选择）
  static int _currentDataSetIndex = 0;
  
  @override
  String get serviceName => 'Demo 模式';

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProtectResult> protect({
    required String imagePath,
    required double protectionLevel,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    // 随机选择一个数据集
    _currentDataSetIndex = _random.nextInt(_demoDataSets.length);
    
    // 模拟处理延迟（5-8秒随机，更真实）
    final delaySeconds = 5 + _random.nextInt(4);
    await Future.delayed(Duration(seconds: delaySeconds));
    
    stopwatch.stop();
    
    // 生成唯一的 taskId
    final taskId = 'demo-task-${DateTime.now().millisecondsSinceEpoch}';
    
    return ProtectResult.success(
      imagePath: imagePath,  // 返回原图
      processingTimeMs: stopwatch.elapsedMilliseconds,
      protectionLevel: protectionLevel,
      taskId: taskId,
    );
  }

  /// 获取评估结果（返回随机选中的预设数据）
  Future<EvaluationResult?> getEvaluationResult(String taskId) async {
    // 模拟网络延迟（1-2秒）
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(700)));
    
    // 获取当前选中的数据集
    final dataSet = _demoDataSets[_currentDataSetIndex];
    
    return EvaluationResult(
      taskId: taskId,
      status: EvaluationStatus.completed,
      qualityMetrics: dataSet.qualityMetrics,
      diffMetrics: dataSet.diffMetrics,
    );
  }
}

/// Demo 数据集模型
class _DemoDataSet {
  final List<EvaluationMetric> qualityMetrics;
  final List<EvaluationMetric> diffMetrics;
  
  const _DemoDataSet({
    required this.qualityMetrics,
    required this.diffMetrics,
  });
}

/// 预设的多套 Demo 数据
const List<_DemoDataSet> _demoDataSets = [
  // ===== 数据集 1: 优秀效果 (综合评分 ~85) =====
  _DemoDataSet(
    qualityMetrics: [
      EvaluationMetric(
        key: 'psnr',
        name: 'PSNR',
        value: '42.3',
        description: '峰值信噪比，越高图像质量越好',
      ),
      EvaluationMetric(
        key: 'ssim',
        name: 'SSIM',
        value: '0.96',
        description: '结构相似性，越接近1越相似',
      ),
      EvaluationMetric(
        key: 'msssim',
        name: 'MS-SSIM',
        value: '0.97',
        description: '多尺度结构相似性',
      ),
      EvaluationMetric(
        key: 'clip_similarity',
        name: 'CLIP 相似度',
        value: '0.88',
        description: '视觉语义相似度',
      ),
      EvaluationMetric(
        key: 'clip_distance',
        name: 'CLIP 距离',
        value: '0.52',
        description: 'AI 特征空间距离，越大防护越强',
      ),
      EvaluationMetric(
        key: 'ai_perturb_score',
        name: 'AI 扰动分数',
        value: '0.85',
        description: '对 AI 模型的干扰程度',
      ),
    ],
    diffMetrics: [
      EvaluationMetric(
        key: 'mean_abs_diff',
        name: '平均绝对差',
        value: '0.008',
        description: '像素平均变化量',
      ),
      EvaluationMetric(
        key: 'l2_diff',
        name: 'L2 范数',
        value: '0.018',
        description: '欧氏距离',
      ),
      EvaluationMetric(
        key: 'linf_diff',
        name: 'L∞ 范数',
        value: '0.062',
        description: '最大像素变化',
      ),
    ],
  ),
  
  // ===== 数据集 2: 良好效果 (综合评分 ~75) =====
  _DemoDataSet(
    qualityMetrics: [
      EvaluationMetric(
        key: 'psnr',
        name: 'PSNR',
        value: '38.7',
        description: '峰值信噪比，越高图像质量越好',
      ),
      EvaluationMetric(
        key: 'ssim',
        name: 'SSIM',
        value: '0.91',
        description: '结构相似性，越接近1越相似',
      ),
      EvaluationMetric(
        key: 'msssim',
        name: 'MS-SSIM',
        value: '0.93',
        description: '多尺度结构相似性',
      ),
      EvaluationMetric(
        key: 'clip_similarity',
        name: 'CLIP 相似度',
        value: '0.82',
        description: '视觉语义相似度',
      ),
      EvaluationMetric(
        key: 'clip_distance',
        name: 'CLIP 距离',
        value: '0.45',
        description: 'AI 特征空间距离，越大防护越强',
      ),
      EvaluationMetric(
        key: 'ai_perturb_score',
        name: 'AI 扰动分数',
        value: '0.76',
        description: '对 AI 模型的干扰程度',
      ),
    ],
    diffMetrics: [
      EvaluationMetric(
        key: 'mean_abs_diff',
        name: '平均绝对差',
        value: '0.015',
        description: '像素平均变化量',
      ),
      EvaluationMetric(
        key: 'l2_diff',
        name: 'L2 范数',
        value: '0.028',
        description: '欧氏距离',
      ),
      EvaluationMetric(
        key: 'linf_diff',
        name: 'L∞ 范数',
        value: '0.085',
        description: '最大像素变化',
      ),
    ],
  ),
  
  // ===== 数据集 3: 中等效果 (综合评分 ~68) =====
  _DemoDataSet(
    qualityMetrics: [
      EvaluationMetric(
        key: 'psnr',
        name: 'PSNR',
        value: '35.2',
        description: '峰值信噪比，越高图像质量越好',
      ),
      EvaluationMetric(
        key: 'ssim',
        name: 'SSIM',
        value: '0.87',
        description: '结构相似性，越接近1越相似',
      ),
      EvaluationMetric(
        key: 'msssim',
        name: 'MS-SSIM',
        value: '0.89',
        description: '多尺度结构相似性',
      ),
      EvaluationMetric(
        key: 'clip_similarity',
        name: 'CLIP 相似度',
        value: '0.79',
        description: '视觉语义相似度',
      ),
      EvaluationMetric(
        key: 'clip_distance',
        name: 'CLIP 距离',
        value: '0.38',
        description: 'AI 特征空间距离，越大防护越强',
      ),
      EvaluationMetric(
        key: 'ai_perturb_score',
        name: 'AI 扰动分数',
        value: '0.69',
        description: '对 AI 模型的干扰程度',
      ),
    ],
    diffMetrics: [
      EvaluationMetric(
        key: 'mean_abs_diff',
        name: '平均绝对差',
        value: '0.022',
        description: '像素平均变化量',
      ),
      EvaluationMetric(
        key: 'l2_diff',
        name: 'L2 范数',
        value: '0.038',
        description: '欧氏距离',
      ),
      EvaluationMetric(
        key: 'linf_diff',
        name: 'L∞ 范数',
        value: '0.105',
        description: '最大像素变化',
      ),
    ],
  ),
  
  // ===== 数据集 4: 高防护效果 (综合评分 ~80) =====
  _DemoDataSet(
    qualityMetrics: [
      EvaluationMetric(
        key: 'psnr',
        name: 'PSNR',
        value: '40.1',
        description: '峰值信噪比，越高图像质量越好',
      ),
      EvaluationMetric(
        key: 'ssim',
        name: 'SSIM',
        value: '0.94',
        description: '结构相似性，越接近1越相似',
      ),
      EvaluationMetric(
        key: 'msssim',
        name: 'MS-SSIM',
        value: '0.95',
        description: '多尺度结构相似性',
      ),
      EvaluationMetric(
        key: 'clip_similarity',
        name: 'CLIP 相似度',
        value: '0.84',
        description: '视觉语义相似度',
      ),
      EvaluationMetric(
        key: 'clip_distance',
        name: 'CLIP 距离',
        value: '0.58',
        description: 'AI 特征空间距离，越大防护越强',
      ),
      EvaluationMetric(
        key: 'ai_perturb_score',
        name: 'AI 扰动分数',
        value: '0.82',
        description: '对 AI 模型的干扰程度',
      ),
    ],
    diffMetrics: [
      EvaluationMetric(
        key: 'mean_abs_diff',
        name: '平均绝对差',
        value: '0.011',
        description: '像素平均变化量',
      ),
      EvaluationMetric(
        key: 'l2_diff',
        name: 'L2 范数',
        value: '0.023',
        description: '欧氏距离',
      ),
      EvaluationMetric(
        key: 'linf_diff',
        name: 'L∞ 范数',
        value: '0.072',
        description: '最大像素变化',
      ),
    ],
  ),
  
  // ===== 数据集 5: 平衡效果 (综合评分 ~72) =====
  _DemoDataSet(
    qualityMetrics: [
      EvaluationMetric(
        key: 'psnr',
        name: 'PSNR',
        value: '36.8',
        description: '峰值信噪比，越高图像质量越好',
      ),
      EvaluationMetric(
        key: 'ssim',
        name: 'SSIM',
        value: '0.89',
        description: '结构相似性，越接近1越相似',
      ),
      EvaluationMetric(
        key: 'msssim',
        name: 'MS-SSIM',
        value: '0.91',
        description: '多尺度结构相似性',
      ),
      EvaluationMetric(
        key: 'clip_similarity',
        name: 'CLIP 相似度',
        value: '0.81',
        description: '视觉语义相似度',
      ),
      EvaluationMetric(
        key: 'clip_distance',
        name: 'CLIP 距离',
        value: '0.41',
        description: 'AI 特征空间距离，越大防护越强',
      ),
      EvaluationMetric(
        key: 'ai_perturb_score',
        name: 'AI 扰动分数',
        value: '0.73',
        description: '对 AI 模型的干扰程度',
      ),
    ],
    diffMetrics: [
      EvaluationMetric(
        key: 'mean_abs_diff',
        name: '平均绝对差',
        value: '0.018',
        description: '像素平均变化量',
      ),
      EvaluationMetric(
        key: 'l2_diff',
        name: 'L2 范数',
        value: '0.032',
        description: '欧氏距离',
      ),
      EvaluationMetric(
        key: 'linf_diff',
        name: 'L∞ 范数',
        value: '0.092',
        description: '最大像素变化',
      ),
    ],
  ),
];

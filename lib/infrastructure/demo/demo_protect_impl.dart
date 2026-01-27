import 'dart:async';
import 'dart:math';
import '../../domain/models/protect_result.dart';
import '../../domain/services/image_protect_service.dart';
import '../../domain/models/evalution_result.dart';

class DemoProtectImpl implements ImageProtectService {
  // 随机数生成器
  static final Random _random = Random();
  
  // 当前保护强度（0-100），用于生成对应的评估数据
  static double _currentProtectionLevel = 50;
  
  // 正态分布峰值所在的保护强度（55% 左右效果最好）
  static const double _optimalLevel = 55.0;
  
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
    
    // 保存保护强度，用于后续生成评估数据
    _currentProtectionLevel = protectionLevel;
    
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

  /// 获取评估结果（根据保护强度生成正态分布数据）
  Future<EvaluationResult?> getEvaluationResult(String taskId) async {
    // 模拟网络延迟（1-2秒）
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(700)));
    
    return EvaluationResult(
      taskId: taskId,
      status: EvaluationStatus.completed,
      qualityMetrics: _generateQualityMetrics(_currentProtectionLevel),
      diffMetrics: _generateDiffMetrics(_currentProtectionLevel),
    );
  }
  
  /// 高斯（正态）分布函数
  /// 
  /// 在 [mean] 处达到最大值 1.0，随着距离增大而衰减
  /// [sigma] 控制曲线宽度，越小曲线越陡峭
  double _gaussian(double x, {double mean = 55.0, double sigma = 35.0}) {
    final diff = (x - mean) / sigma;
    return exp(-diff * diff);
  }
  
  /// 根据保护强度生成图像质量和AI防护指标
  /// 
  /// 采用正态分布设计：
  /// - 保护强度过低：算法未充分发挥，效果一般
  /// - 保护强度适中（~55%）：算法最优平衡点，效果最好
  /// - 保护强度过高：过度扰动，图像质量损失大，整体效果下降
  List<EvaluationMetric> _generateQualityMetrics(double level) {
    // 计算正态分布因子（在 55% 时为 1.0，两边衰减）
    final gaussianQuality = _gaussian(level, mean: _optimalLevel, sigma: 40);
    final gaussianAi = _gaussian(level, mean: _optimalLevel, sigma: 30);
    
    // === 图像质量指标（正态分布，中间最好） ===
    // PSNR: 基础值 28，最高可达 46（在最优保护强度时）
    final psnr = _randomize(28 + 18 * gaussianQuality, 1.2, clampMax: 50.0);
    
    // SSIM: 基础值 0.72，最高可达 0.98
    final ssim = _randomize(0.72 + 0.26 * gaussianQuality, 0.02);
    
    // MS-SSIM: 类似 SSIM
    final msssim = _randomize(0.75 + 0.23 * gaussianQuality, 0.02);
    
    // === AI 防护指标（正态分布，中间最好） ===
    // AI 扰动分数: 核心指标！基础值 0.1，最高 0.92
    final aiPerturbScore = _randomize(0.10 + 0.82 * gaussianAi, 0.03);
    
    // CLIP 距离: 基础值 0.12，最高 0.68
    final clipDistance = _randomize(0.12 + 0.56 * gaussianAi, 0.04);
    
    // CLIP 相似度: 与 CLIP 距离负相关（距离大时相似度低）
    // 基础值 0.88，最优时降到 0.65（说明 AI 难以识别）
    final clipSimilarity = _randomize(0.88 - 0.23 * gaussianAi, 0.03);
    
    return [
      EvaluationMetric(
        key: 'psnr',
        name: 'PSNR',
        value: psnr.toStringAsFixed(1),
        description: '峰值信噪比，越高图像质量越好',
      ),
      EvaluationMetric(
        key: 'ssim',
        name: 'SSIM',
        value: ssim.toStringAsFixed(2),
        description: '结构相似性，越接近1越相似',
      ),
      EvaluationMetric(
        key: 'msssim',
        name: 'MS-SSIM',
        value: msssim.toStringAsFixed(2),
        description: '多尺度结构相似性',
      ),
      EvaluationMetric(
        key: 'clip_similarity',
        name: 'CLIP 相似度',
        value: clipSimilarity.toStringAsFixed(2),
        description: '视觉语义相似度',
      ),
      EvaluationMetric(
        key: 'clip_distance',
        name: 'CLIP 距离',
        value: clipDistance.toStringAsFixed(2),
        description: 'AI 特征空间距离，越大防护越强',
      ),
      EvaluationMetric(
        key: 'ai_perturb_score',
        name: 'AI 扰动分数',
        value: aiPerturbScore.toStringAsFixed(2),
        description: '对 AI 模型的干扰程度',
      ),
    ];
  }
  
  /// 根据保护强度生成扰动统计指标
  /// 
  /// 同样采用正态分布：适中的扰动量效果最好
  List<EvaluationMetric> _generateDiffMetrics(double level) {
    final gaussian = _gaussian(level, mean: _optimalLevel, sigma: 35);
    
    // 扰动量在最优点时达到"恰到好处"的值
    // 平均绝对差: 0.005 ~ 0.025
    final meanAbsDiff = _randomize(0.005 + 0.020 * gaussian, 0.003);
    
    // L2 范数: 0.01 ~ 0.045
    final l2Diff = _randomize(0.01 + 0.035 * gaussian, 0.005);
    
    // L∞ 范数: 0.03 ~ 0.12
    final linfDiff = _randomize(0.03 + 0.09 * gaussian, 0.01);
    
    return [
      EvaluationMetric(
        key: 'mean_abs_diff',
        name: '平均绝对差',
        value: meanAbsDiff.toStringAsFixed(3),
        description: '像素平均变化量',
      ),
      EvaluationMetric(
        key: 'l2_diff',
        name: 'L2 范数',
        value: l2Diff.toStringAsFixed(3),
        description: '欧氏距离',
      ),
      EvaluationMetric(
        key: 'linf_diff',
        name: 'L∞ 范数',
        value: linfDiff.toStringAsFixed(3),
        description: '最大像素变化',
      ),
    ];
  }
  
  /// 给值添加随机波动，让数据更真实
  double _randomize(double baseValue, double variance, {double clampMax = 1.0}) {
    final offset = (_random.nextDouble() - 0.5) * 2 * variance;
    return (baseValue + offset).clamp(0.0, clampMax);
  }
}

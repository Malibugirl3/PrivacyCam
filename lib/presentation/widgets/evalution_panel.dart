import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/evalution_result.dart';
import '../../infrastructure/cloud/cloud_protect_impl.dart';
import 'metric_card.dart';

class EvaluationPanel extends StatefulWidget {
  final String? taskId;
  final String baseUrl;  // API 基础地址
  
  const EvaluationPanel({
    super.key,
    this.taskId,
    required this.baseUrl,
  });
  
  @override
  State<EvaluationPanel> createState() => _EvaluationPanelState();
}

class _EvaluationPanelState extends State<EvaluationPanel> {
  // 状态
  EvaluationResult? _result;
  bool _isLoading = true;
  String? _error;
  
  // 轮询
  Timer? _pollingTimer;
  late final CloudProtectImpl _api;
  
  // 分组折叠状态
  final Map<String, bool> _groupExpanded = {
    'quality': true,     // 图像质量 - 默认展开
    'ai': true,          // AI 防护 - 默认展开
    'diff': false,       // 扰动统计 - 默认收起
  };
  
  @override
  void initState() {
    super.initState();
    _api = CloudProtectImpl(baseUrl: widget.baseUrl);
    if (widget.taskId != null) {
      _startPolling();
    } else {
      // 没有 taskId，显示"本地处理，无评估数据"
      setState(() {
        _isLoading = false;
        _error = '本地处理模式，暂无评估数据';
      });
    }
  }
  
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  
  // 轮询方法和 UI 构建方法
    void _startPolling() {
    // 立即执行一次
    _fetchResult();
    
    // 每 2 秒轮询一次
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchResult();
    });
  }

  Future<void> _fetchResult() async {
    if (widget.taskId == null) return;
    
    try {
      final result = await _api.getEvaluationResult(widget.taskId!);
      
      if (result == null) {
        // 任务不存在
        _pollingTimer?.cancel();
        setState(() {
          _isLoading = false;
          _error = '任务不存在';
        });
        return;
      }
      
      if (result.isCompleted) {
        // 完成，停止轮询
        _pollingTimer?.cancel();
        setState(() {
          _result = result;
          _isLoading = false;
        });
      } else if (result.status == EvaluationStatus.failed) {
        // 失败，停止轮询
        _pollingTimer?.cancel();
        setState(() {
          _isLoading = false;
          _error = result.error ?? '评估失败';
        });
      }
      // pending/running 继续轮询，不更新 UI
      
    } catch (e) {
      // 网络错误，继续轮询（可能是暂时性的）
      debugPrint('Polling error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.analytics_outlined, 
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '保护效果评估',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 内容区域
          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else
            _buildResultContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            '正在评估保护效果...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isInfo = _error == '本地处理模式，暂无评估数据';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInfo 
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, 
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (widget.taskId != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _startPolling();
              },
              child: const Text('重试'),
            ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    if (_result == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        // 综合评分（顶部）
        _buildOverallScore(),
        
        const SizedBox(height: 16),
        
        // 图像质量组
        _buildMetricGroup(
          title: '📸 图像质量',
          groupKey: 'quality',
          metrics: _getQualityMetrics(),
        ),
        
        // AI 防护组
        _buildMetricGroup(
          title: '🤖 AI 防护效果',
          groupKey: 'ai',
          metrics: _getAiMetrics(),
        ),
        
        // 扰动统计组
        _buildMetricGroup(
          title: '📊 扰动统计',
          groupKey: 'diff',
          metrics: _result!.diffMetrics,
        ),
      ],
    );
  }

  // 获取图像质量指标
  List<EvaluationMetric> _getQualityMetrics() {
    return _result!.qualityMetrics
        .where((m) => ['psnr', 'ssim', 'msssim'].contains(m.key))
        .toList();
  }

  // 获取 AI 防护指标
  List<EvaluationMetric> _getAiMetrics() {
    return _result!.qualityMetrics
        .where((m) => ['clip_similarity', 'clip_distance', 'ai_perturb_score'].contains(m.key))
        .toList();
  }

  Widget _buildOverallScore() {
    final score = _calculateOverallScore();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '综合评分',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '${value.toInt()}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
          Text(
            _getScoreDescription(score),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateOverallScore() {
    if (_result == null) return 0;
    
    double psnr = 0, ssim = 0, aiScore = 0;
    
    for (final m in _result!.qualityMetrics) {
      switch (m.key) {
        case 'psnr':
          psnr = m.normalizedValue;
          break;
        case 'ssim':
          ssim = m.normalizedValue;
          break;
        case 'ai_perturb_score':
          aiScore = m.normalizedValue;
          break;
      }
    }
    
    // 权重：图像质量 40% + 结构相似 30% + AI防护 30%
    return (psnr * 0.4 + ssim * 0.3 + aiScore * 0.3) * 100;
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return '保护效果优秀';
    if (score >= 60) return '保护效果良好';
    if (score >= 40) return '保护效果一般';
    return '保护效果较弱';
  }

  Widget _buildMetricGroup({
    required String title,
    required String groupKey,
    required List<EvaluationMetric> metrics,
  }) {
    final isExpanded = _groupExpanded[groupKey] ?? true;
    
    return Column(
      children: [
        // 分组标题（可点击折叠）
        GestureDetector(
          onTap: () {
            setState(() {
              _groupExpanded[groupKey] = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  ' (${metrics.length}项)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        
        // 指标卡片列表
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: metrics.asMap().entries.map((entry) {
              return MetricCard(
                metric: entry.value,
                animationIndex: entry.key,
              );
            }).toList(),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
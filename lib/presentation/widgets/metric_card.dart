import 'package:flutter/material.dart';
import '../../domain/models/evalution_result.dart';

class MetricCard extends StatefulWidget {
  final EvaluationMetric metric;
  final int animationIndex;  // 用于依次动画
  final bool animate;        // 是否启用入场动画
  
  const MetricCard({
    super.key,
    required this.metric,
    this.animationIndex = 0,
    this.animate = true,
  });
  
  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> {
  bool _isExpanded = false;  // 是否展开显示描述
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        // 卡片容器样式
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：名称 + 数值 + 百分比
            _buildHeader(),
            
            const SizedBox(height: 8),
            
            // 第二行：进度条
            _buildProgressBar(),
            
            // 第三行：中文描述（可展开）
            _buildDescription(),
          ],
        ),
      ),
    );
  }
  
  // ... 子组件方法
  Widget _buildHeader() {
    return Row(
      children: [
        // 指标英文名
        Text(
          widget.metric.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        // 数值（带单位）
        Text(
          _getDisplayValue(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        // 百分比
        Text(
          '${(widget.metric.normalizedValue * 100).toInt()}%',
          style: TextStyle(
            color: _getProgressColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getDisplayValue() {
    final value = widget.metric.value;
    switch (widget.metric.key) {
      case 'psnr':
        return '$value dB';
      default:
        return value;
    }
  }


  Widget _buildProgressBar() {
    final progress = widget.metric.normalizedValue;
    final color = _getProgressColor();
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: Duration(milliseconds: 600 + widget.animationIndex * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor() {
    final value = widget.metric.normalizedValue;
    if (value >= 0.7) {
      return Colors.green;
    } else if (value >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }


  Widget _buildDescription() {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),  // 收起时：空
      secondChild: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          _getChineseDescription(),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      crossFadeState: _isExpanded 
          ? CrossFadeState.showSecond 
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 200),
    );
  }

  String _getChineseDescription() {
    const descMap = {
      'psnr': '峰值信噪比，衡量图像质量，越高越好，>30dB 人眼难察觉',
      'ssim': '结构相似性，范围 [0,1]，越接近 1 越相似',
      'msssim': '多尺度结构相似性，更符合人眼感知',
      'clip_similarity': 'AI 语义理解的一致性，越高越相似',
      'clip_distance': '语义特征差异，越接近 0 越相似',
      'ai_perturb_score': '对 AI 的干扰程度，越高保护效果越强',
      'mean_abs_diff': '像素平均差异，反映扰动强度',
      'l2_diff': '均方根误差，反映整体能量',
      'linf_diff': '最大单点差异，反映局部强度',
    };
    return descMap[widget.metric.key] ?? widget.metric.description;
  }
}
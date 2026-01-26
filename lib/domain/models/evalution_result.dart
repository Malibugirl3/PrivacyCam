class EvaluationMetric {
  final String key;
  final String name;
  final String value;
  final String description;

  const EvaluationMetric({
    required this.key,
    required this.name,
    required this.value,
    required this.description,
  });

  factory EvaluationMetric.fromJson(Map<String, dynamic> json) {
    return EvaluationMetric(
      key: json['key'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
      description: json['description'] as String,
    );
  }

  double get numericValue => double.tryParse(value) ?? 0.0;

  double get normalizedValue {
    switch (key) {
      case 'psnr':
        // PSNR: 20-50 映射到 0-1
        return ((numericValue - 20) / 30).clamp(0.0, 1.0);
      case 'ssim':
      case 'msssim':
      case 'clip_similarity':
        // 已经是 0-1 范围
        return numericValue.clamp(0.0, 1.0);
      case 'ai_perturb_score':
        // 0-1，越高越好
        return numericValue.clamp(0.0, 1.0);
      case 'clip_distance':
      case 'mean_abs_diff':
      case 'l2_diff':
      case 'linf_diff':
        // 这些是"越小越好"，需要反转
        return (1.0 - numericValue).clamp(0.0, 1.0);
      default:
        return numericValue.clamp(0.0, 1.0);
    }
  }
}


enum EvaluationStatus {
  pending,
  running,
  completed,
  failed,
}

class EvaluationResult {
  final String taskId;
  final EvaluationStatus status;
  final List<EvaluationMetric> qualityMetrics;
  final List<EvaluationMetric> diffMetrics;
  final String? error;


  const EvaluationResult({
    required this.taskId,
    required this.status,
    this.qualityMetrics = const [],
    this.diffMetrics = const [],
    this.error,
  });

  /// 从 API 响应解析
  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = EvaluationStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => EvaluationStatus.pending,
    );

    List<EvaluationMetric> parseMetrics(List<dynamic>? list) {
      if(list == null) return [];
      return list
      .map((item) => EvaluationMetric.fromJson(item as Map<String, dynamic>))
      .toList();
    }

    final result = json['result'] as Map<String, dynamic>?;

    return EvaluationResult(
      taskId: json['task_id'] as String,
      status:status,
      qualityMetrics: parseMetrics(result?['quality_metrics'] as List<dynamic>?),
      diffMetrics: parseMetrics(result?['diff_metrics'] as List<dynamic>?),
      error: json['error'] as String?,
    );
  }

  bool get isCompleted => status ==EvaluationStatus.completed;

  bool get isLoading =>
    status == EvaluationStatus.pending || 
    status == EvaluationStatus.running;
}
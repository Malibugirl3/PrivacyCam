enum PortraitRiskLevel { low, medium, high }

class PortraitRiskResult {
  const PortraitRiskResult({
    required this.faceCount,
    required this.score,
    required this.level,
    required this.summary,
    required this.recommendation,
  });

  final int faceCount;
  final int score;
  final PortraitRiskLevel level;
  final String summary;
  final String recommendation;

  static PortraitRiskLevel levelFromScore(int score) {
    if (score >= 70) return PortraitRiskLevel.high;
    if (score >= 40) return PortraitRiskLevel.medium;
    return PortraitRiskLevel.low;
  }
}

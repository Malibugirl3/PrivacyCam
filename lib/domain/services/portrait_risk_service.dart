import '../models/portrait_risk_result.dart';

abstract class PortraitRiskService {
  Future<PortraitRiskResult> analyze(String imagePath);
}

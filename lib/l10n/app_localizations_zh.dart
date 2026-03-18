// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settingsTitle => '设置';

  @override
  String get previewTitle => '预览';

  @override
  String get portraitRiskTitle => '人像风险';

  @override
  String get protectionStrength => '防护强度';

  @override
  String get startProtection => '开始防护';

  @override
  String get scanningPortraitRisk => '正在扫描人像风险…';

  @override
  String get retry => '重试';

  @override
  String facesDetected(int count) {
    return '检测到人脸：$count';
  }

  @override
  String recommendationPrefix(String text) {
    return '建议：$text';
  }

  @override
  String get processingFailed => '处理失败';

  @override
  String get noRiskResult => '没有风险结果。';

  @override
  String faceScanFailed(String error) {
    return '人脸扫描失败：$error';
  }

  @override
  String get noClearFaceSummary => '未检测到清晰人脸。';

  @override
  String detectedFacesSummary(int count) {
    return '检测到$count张人脸。';
  }

  @override
  String get recommendationLow => '保持当前防护强度或在分享前稍微提高。';

  @override
  String get recommendationMedium => '在分享前使用中等或更高的扰动。';

  @override
  String get recommendationHigh => '使用高强度扰动并避免分享原图。';

  @override
  String get riskLevelLow => '低';

  @override
  String get riskLevelMedium => '中';

  @override
  String get riskLevelHigh => '高';

  @override
  String get protectionLevelDescriptionNone => '无扰动。';

  @override
  String get protectionLevelDescriptionLight => '轻微扰动，对画质影响较小。';

  @override
  String get protectionLevelDescriptionBalanced => '平衡画质与防护。';

  @override
  String get protectionLevelDescriptionStrong => '强防护，可能影响画质。';

  @override
  String get protectionLevelDescriptionMax => '最大防护。';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';
}

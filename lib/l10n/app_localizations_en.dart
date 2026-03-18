// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get previewTitle => 'Preview';

  @override
  String get portraitRiskTitle => 'Portrait Risk';

  @override
  String get protectionStrength => 'Protection Strength';

  @override
  String get startProtection => 'Start Protection';

  @override
  String get scanningPortraitRisk => 'Scanning portrait risk…';

  @override
  String get retry => 'Retry';

  @override
  String facesDetected(int count) {
    return 'Faces detected: $count';
  }

  @override
  String recommendationPrefix(String text) {
    return 'Recommendation: $text';
  }

  @override
  String get processingFailed => 'Processing failed';

  @override
  String get noRiskResult => 'No risk result.';

  @override
  String faceScanFailed(String error) {
    return 'Face scan failed: $error';
  }

  @override
  String get noClearFaceSummary => 'No clear face detected in this image.';

  @override
  String detectedFacesSummary(int count) {
    return 'Detected $count face(s) in this image.';
  }

  @override
  String get recommendationLow =>
      'Keep current protection level or increase slightly before sharing.';

  @override
  String get recommendationMedium =>
      'Use medium or higher perturbation before sharing.';

  @override
  String get recommendationHigh =>
      'Use high perturbation and avoid sharing the original image.';

  @override
  String get riskLevelLow => 'LOW';

  @override
  String get riskLevelMedium => 'MEDIUM';

  @override
  String get riskLevelHigh => 'HIGH';

  @override
  String get protectionLevelDescriptionNone => 'No perturbation.';

  @override
  String get protectionLevelDescriptionLight =>
      'Light perturbation, minor visual impact.';

  @override
  String get protectionLevelDescriptionBalanced =>
      'Balanced quality and protection.';

  @override
  String get protectionLevelDescriptionStrong =>
      'Strong protection, possible quality impact.';

  @override
  String get protectionLevelDescriptionMax => 'Maximum protection.';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageEnglish => 'English';
}

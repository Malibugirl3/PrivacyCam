import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @previewTitle.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get previewTitle;

  /// No description provided for @portraitRiskTitle.
  ///
  /// In zh, this message translates to:
  /// **'人像风险'**
  String get portraitRiskTitle;

  /// No description provided for @protectionStrength.
  ///
  /// In zh, this message translates to:
  /// **'防护强度'**
  String get protectionStrength;

  /// No description provided for @startProtection.
  ///
  /// In zh, this message translates to:
  /// **'开始防护'**
  String get startProtection;

  /// No description provided for @scanningPortraitRisk.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描人像风险…'**
  String get scanningPortraitRisk;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @facesDetected.
  ///
  /// In zh, this message translates to:
  /// **'检测到人脸：{count}'**
  String facesDetected(int count);

  /// No description provided for @recommendationPrefix.
  ///
  /// In zh, this message translates to:
  /// **'建议：{text}'**
  String recommendationPrefix(String text);

  /// No description provided for @processingFailed.
  ///
  /// In zh, this message translates to:
  /// **'处理失败'**
  String get processingFailed;

  /// No description provided for @noRiskResult.
  ///
  /// In zh, this message translates to:
  /// **'没有风险结果。'**
  String get noRiskResult;

  /// No description provided for @faceScanFailed.
  ///
  /// In zh, this message translates to:
  /// **'人脸扫描失败：{error}'**
  String faceScanFailed(String error);

  /// No description provided for @noClearFaceSummary.
  ///
  /// In zh, this message translates to:
  /// **'未检测到清晰人脸。'**
  String get noClearFaceSummary;

  /// No description provided for @detectedFacesSummary.
  ///
  /// In zh, this message translates to:
  /// **'检测到{count}张人脸。'**
  String detectedFacesSummary(int count);

  /// No description provided for @recommendationLow.
  ///
  /// In zh, this message translates to:
  /// **'保持当前防护强度或在分享前稍微提高。'**
  String get recommendationLow;

  /// No description provided for @recommendationMedium.
  ///
  /// In zh, this message translates to:
  /// **'在分享前使用中等或更高的扰动。'**
  String get recommendationMedium;

  /// No description provided for @recommendationHigh.
  ///
  /// In zh, this message translates to:
  /// **'使用高强度扰动并避免分享原图。'**
  String get recommendationHigh;

  /// No description provided for @riskLevelLow.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get riskLevelLow;

  /// No description provided for @riskLevelMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get riskLevelMedium;

  /// No description provided for @riskLevelHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get riskLevelHigh;

  /// No description provided for @protectionLevelDescriptionNone.
  ///
  /// In zh, this message translates to:
  /// **'无扰动。'**
  String get protectionLevelDescriptionNone;

  /// No description provided for @protectionLevelDescriptionLight.
  ///
  /// In zh, this message translates to:
  /// **'轻微扰动，对画质影响较小。'**
  String get protectionLevelDescriptionLight;

  /// No description provided for @protectionLevelDescriptionBalanced.
  ///
  /// In zh, this message translates to:
  /// **'平衡画质与防护。'**
  String get protectionLevelDescriptionBalanced;

  /// No description provided for @protectionLevelDescriptionStrong.
  ///
  /// In zh, this message translates to:
  /// **'强防护，可能影响画质。'**
  String get protectionLevelDescriptionStrong;

  /// No description provided for @protectionLevelDescriptionMax.
  ///
  /// In zh, this message translates to:
  /// **'最大防护。'**
  String get protectionLevelDescriptionMax;

  /// No description provided for @languageTitle.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEnglish;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

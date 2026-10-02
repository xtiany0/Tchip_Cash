// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Tchip\u202F!';

  @override
  String get navHome => 'Home';

  @override
  String get navOperations => 'Transactions';

  @override
  String get navReport => 'Report';

  @override
  String get navPlans => 'Plans';

  @override
  String get navSettings => 'Settings';

  @override
  String get navAddCash => 'Add a cash expense';

  @override
  String get navMainLabel => 'Main navigation';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get splashTagline => 'Your money, under control.';

  @override
  String get splashLoading => 'Loading your transactions…';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get screenDay => 'Today';

  @override
  String get screenAddCash => 'Cash expense';

  @override
  String get screenPlan => 'Plan';

  @override
  String get comingSoon => 'Screen under construction';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageAuto => 'Automatic';

  @override
  String settingsLanguageAutoSub(String language) {
    return 'Phone language ($language)';
  }

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String settingsFormatHint(String amount, String date) {
    return 'Amounts and dates follow the chosen language: $amount · $date.';
  }

  @override
  String amountF(String amount) {
    return '$amount F';
  }
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Tchip\u202F!';

  @override
  String get navHome => 'Accueil';

  @override
  String get navOperations => 'Opérations';

  @override
  String get navReport => 'Bilan';

  @override
  String get navPlans => 'Plans';

  @override
  String get navSettings => 'Réglages';

  @override
  String get navAddCash => 'Ajouter une dépense en espèces';

  @override
  String get navMainLabel => 'Navigation principale';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get splashTagline => 'Tes finances sous contrôle.';

  @override
  String get splashLoading => 'Chargement de tes opérations…';

  @override
  String get homeSettingsTooltip => 'Réglages';

  @override
  String get screenDay => 'Aujourd\'hui';

  @override
  String get screenAddCash => 'Dépense en espèces';

  @override
  String get screenPlan => 'Plan';

  @override
  String get comingSoon => 'Écran en construction';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageAuto => 'Automatique';

  @override
  String settingsLanguageAutoSub(String language) {
    return 'Langue du téléphone ($language)';
  }

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String settingsFormatHint(String amount, String date) {
    return 'Montants et dates suivent la langue choisie : $amount · $date.';
  }

  @override
  String amountF(String amount) {
    return '$amount F';
  }
}

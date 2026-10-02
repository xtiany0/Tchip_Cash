import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language chosen in Settings. [auto] follows the phone language.
enum LanguageChoice {
  auto,
  fr,
  en;

  Locale? get locale => switch (this) {
    auto => null,
    fr => const Locale('fr'),
    en => const Locale('en'),
  };
}

/// Overridden in main() once SharedPreferences is loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

class LanguageNotifier extends Notifier<LanguageChoice> {
  static const _key = 'language';

  @override
  LanguageChoice build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_key);
    return LanguageChoice.values.asNameMap()[saved] ?? LanguageChoice.auto;
  }

  Future<void> set(LanguageChoice choice) async {
    state = choice;
    await ref.read(sharedPreferencesProvider).setString(_key, choice.name);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, LanguageChoice>(
  LanguageNotifier.new,
);

const supportedLanguageCodes = {'fr', 'en'};

/// Picks the first phone locale the app supports, French otherwise.
Locale resolveDeviceLocale(List<Locale>? deviceLocales) {
  for (final l in deviceLocales ?? const <Locale>[]) {
    if (supportedLanguageCodes.contains(l.languageCode)) {
      return Locale(l.languageCode);
    }
  }
  return const Locale('fr');
}

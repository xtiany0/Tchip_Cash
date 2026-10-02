import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/settings/language_setting.dart';
import 'l10n/gen/app_localizations.dart';
import 'theme/tchip_theme.dart';

class TchipApp extends ConsumerWidget {
  const TchipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: TchipTheme.dark,
      darkTheme: TchipTheme.dark,
      themeMode: ThemeMode.dark,
      locale: language.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: (locales, _) => resolveDeviceLocale(locales),
      routerConfig: appRouter,
    );
  }
}

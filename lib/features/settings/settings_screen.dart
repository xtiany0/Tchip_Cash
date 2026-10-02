import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/tchip_format.dart';
import '../../core/settings/language_setting.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../theme/tchip_theme.dart';
import '../../widgets/placeholder_screen.dart';

/// Settings. Language section only for now; operators and data come in week 3.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    final choice = ref.watch(languageProvider);
    final deviceLocale = resolveDeviceLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
    final deviceName = deviceLocale.languageCode == 'en'
        ? l.languageEnglish
        : l.languageFrench;

    final options = [
      (LanguageChoice.auto, l.settingsLanguageAuto, l.settingsLanguageAutoSub(deviceName)),
      (LanguageChoice.fr, l.languageFrench, null),
      (LanguageChoice.en, l.languageEnglish, null),
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TchipSpacing.screen,
            TchipSpacing.xxl,
            TchipSpacing.screen,
            TchipSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                TchipIconButton(
                  icon: Icons.chevron_left,
                  label: l.back,
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: TchipSpacing.md),
                Expanded(child: Text(l.navSettings, style: TchipText.titleSmall)),
              ],
            ),
            const SizedBox(height: 22),
            Text(l.settingsLanguage.toUpperCase(), style: TchipText.overline),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: TchipColors.card,
                borderRadius: TchipRadii.all(TchipRadii.xl),
                border: Border.all(color: TchipColors.border),
              ),
              child: RadioGroup<LanguageChoice>(
                groupValue: choice,
                onChanged: (v) {
                  if (v != null) ref.read(languageProvider.notifier).set(v);
                },
                child: Column(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                          color: TchipColors.border,
                        ),
                      RadioListTile<LanguageChoice>(
                        value: options[i].$1,
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        minTileHeight: 56,
                        title: Text(options[i].$2, style: TchipText.body),
                        subtitle: options[i].$3 == null
                            ? null
                            : Text(options[i].$3!, style: TchipText.caption),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.settingsFormatHint(
                f.amount(12500),
                f.dayShort(DateTime(2026, 10, 12)),
              ),
              style: TchipText.caption,
            ),
          ],
        ),
      ),
    );
  }
}

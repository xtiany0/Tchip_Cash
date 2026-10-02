import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/tchip_format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../theme/tchip_theme.dart';
import '../../widgets/placeholder_screen.dart';
import '../../widgets/tchip_logo.dart';

/// Home. For now only the header; the plan card, today card and latest
/// operations come in week 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TchipSpacing.screen,
            28,
            TchipSpacing.screen,
            TchipSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TchipLogo(),
                      const SizedBox(height: 2),
                      Text(
                        f.dayLong(DateTime.now()),
                        style: TchipText.caption.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                TchipIconButton(
                  icon: Icons.settings_outlined,
                  label: l.homeSettingsTooltip,
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: TchipSpacing.section),
            InkWell(
              onTap: () => context.go('/home/day'),
              borderRadius: TchipRadii.all(TchipRadii.card),
              child: Ink(
                padding: const EdgeInsets.all(TchipSpacing.lg),
                decoration: BoxDecoration(
                  color: TchipColors.card,
                  borderRadius: TchipRadii.all(TchipRadii.card),
                  border: Border.all(color: TchipColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(l.screenDay, style: TchipText.bodyStrong)),
                    const Icon(Icons.chevron_right, color: TchipColors.yellow),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                l.comingSoon,
                style: TchipText.body.copyWith(color: TchipColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

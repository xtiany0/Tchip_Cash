import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/tchip_theme.dart';

/// Temporary screen body until the real screen is built.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.leading = PlaceholderLeading.none,
    this.actions = const [],
  });

  final String title;
  final PlaceholderLeading leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
                if (leading != PlaceholderLeading.none) ...[
                  TchipIconButton(
                    icon: leading == PlaceholderLeading.close
                        ? Icons.close
                        : Icons.chevron_left,
                    label: leading == PlaceholderLeading.close ? l.close : l.back,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: TchipSpacing.md),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: leading == PlaceholderLeading.none
                        ? TchipText.title
                        : TchipText.titleSmall,
                  ),
                ),
                ...actions,
              ],
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                l.comingSoon,
                textAlign: TextAlign.center,
                style: TchipText.body.copyWith(color: TchipColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PlaceholderLeading { none, back, close }

/// Square 44 px icon button with border, as in the maquette, with a 48 dp
/// touch target and an accessibility label.
class TchipIconButton extends StatelessWidget {
  const TchipIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: SizedBox(
          width: TchipSpacing.touch,
          height: TchipSpacing.touch,
          child: Center(
            child: Material(
              color: TchipColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: TchipRadii.all(TchipRadii.md),
                side: const BorderSide(color: TchipColors.border),
              ),
              child: InkWell(
                onTap: onPressed,
                customBorder: RoundedRectangleBorder(
                  borderRadius: TchipRadii.all(TchipRadii.md),
                ),
                child: SizedBox(
                  width: TchipSpacing.iconButton,
                  height: TchipSpacing.iconButton,
                  child: Icon(icon, size: 20, color: TchipColors.textSoft),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/tchip_format.dart';
import '../../core/settings/onboarding_setting.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../sms/sms_permission.dart';
import '../../theme/tchip_theme.dart';
import '../../widgets/tchip_logo.dart';

/// Welcome screen (maquette/Onboarding.dc.html): explains what Tchip reads,
/// then asks for the SMS permission or lets the user start without it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  SmsPermissionResult? _result;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back from the system settings: continue if the permission is now on.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (_result != SmsPermissionResult.blocked) return;
    ref.read(smsPermissionProvider).status().then((r) {
      if (!mounted) return;
      if (r == SmsPermissionResult.granted) {
        _finish(smsEnabled: true);
      } else {
        setState(() => _result = r);
      }
    });
  }

  Future<void> _allowSms() async {
    final permission = ref.read(smsPermissionProvider);
    if (_result == SmsPermissionResult.blocked) {
      await permission.openSystemSettings();
      return;
    }
    setState(() => _busy = true);
    final r = await permission.request();
    if (!mounted) return;
    if (r == SmsPermissionResult.granted) {
      await _finish(smsEnabled: true);
    } else {
      setState(() {
        _busy = false;
        _result = r;
      });
    }
  }

  Future<void> _finish({required bool smsEnabled}) async {
    await ref
        .read(onboardingProvider.notifier)
        .complete(smsEnabled: smsEnabled);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final blocked = _result == SmsPermissionResult.blocked;

    return Scaffold(
      body: SafeArea(
        // Fills the screen when it fits, scrolls on small screens or with
        // a large system font; buttons stay at the bottom.
        child: CustomScrollView(
          slivers: [
            // Padding inside the sliver: a SliverPadding around it would add
            // its height on top of the viewport and push the buttons off screen.
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: TchipLogo(size: 26),
                    ),
                    const SizedBox(height: 28),
                    const _SampleCard(),
                    const SizedBox(height: 28),
                    Text(l.onboardingTitle, style: TchipText.display),
                    const SizedBox(height: 10),
                    Text(
                      l.onboardingBody,
                      style: TchipText.body.copyWith(
                        color: TchipColors.textMuted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Feature(
                      icon: Icons.lock_outline,
                      strong: l.onboardingLocalStrong,
                      text: l.onboardingLocalRest,
                    ),
                    const SizedBox(height: 14),
                    _Feature(
                      icon: Icons.notes,
                      text: l.onboardingOnlyOperators,
                    ),
                    const Spacer(),
                    const SizedBox(height: 28),
                    if (_result != null) ...[
                      _Notice(
                        text: blocked
                            ? l.onboardingBlocked
                            : l.onboardingDenied,
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed: _busy ? null : _allowSms,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: TchipColors.onYellow,
                              ),
                            )
                          : Text(
                              blocked
                                  ? l.onboardingOpenSettings
                                  : l.onboardingAllowSms,
                              textAlign: TextAlign.center,
                            ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _finish(smsEnabled: false),
                      child: Text(
                        l.onboardingWithoutSms,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Raw SMS bubble turning into a sorted Tchip operation.
class _SampleCard extends StatelessWidget {
  const _SampleCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);

    return Container(
      padding: const EdgeInsets.all(TchipSpacing.xl),
      decoration: BoxDecoration(
        color: TchipColors.card,
        borderRadius: TchipRadii.all(TchipRadii.sheet),
        border: Border.all(color: TchipColors.border),
      ),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // No LayoutBuilder here: SliverFillRemaining needs intrinsic sizes.
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.86,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: TchipColors.bubble,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Text(
                  l.onboardingSampleSms(
                    f.amount(1500),
                    f.amount(50),
                    f.amount(23450),
                  ),
                  style: TchipText.caption.copyWith(
                    fontSize: 13,
                    height: 1.45,
                    color: TchipColors.textSoft,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: TchipColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.onboardingArrow, style: TchipText.caption),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: TchipColors.yellowLight,
                borderRadius: TchipRadii.all(TchipRadii.xl),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.onboardingSampleTitle,
                          style: TchipText.bodyStrong.copyWith(
                            color: TchipColors.onYellow,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.onboardingSampleMeta(f.amount(50)),
                          style: TchipText.caption.copyWith(
                            color: TchipColors.onYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f.signed(-1500),
                    style: TchipText.amount(16, color: TchipColors.onYellow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text, this.strong});

  final IconData icon;
  final String? strong;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = TchipText.bodySmall.copyWith(
      color: TchipColors.textSoft,
      height: 1.45,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: TchipColors.yellowTint,
            borderRadius: TchipRadii.all(TchipRadii.sm),
          ),
          child: Icon(icon, size: 18, color: TchipColors.yellow),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: style,
              children: [
                if (strong != null)
                  TextSpan(
                    text: '$strong ',
                    style: const TextStyle(
                      color: TchipColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TchipColors.yellowTint,
        borderRadius: TchipRadii.all(TchipRadii.lg),
        border: Border.all(color: TchipColors.yellowDashed),
      ),
      child: Text(text, style: TchipText.bodySmall.copyWith(height: 1.4)),
    ),
  );
}

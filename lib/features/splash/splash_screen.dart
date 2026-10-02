import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../providers/bootstrap_provider.dart';
import '../../theme/tchip_theme.dart';

/// Animated splash, as in maquette/Splash.dc.html:
/// - letters T c h i p fade in one by one (0.35 s each, 80 ms apart, rise 14 px);
/// - the yellow "!" drops 60 px at 0.5 s and bounces twice (0.6 s);
/// - the tagline fades in at 1.1 s and stays;
/// - while data is loading, a domino wave tilts each glyph 16° to the right
///   (pivot bottom right), 100 ms apart, every 1.8 s, starting at 1.8 s.
/// Leaves for home as soon as the intro has played and data is ready.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _glyphs = ['T', 'c', 'h', 'i', 'p'];
  static const _introDuration = Duration(milliseconds: 1700);
  static const _dominoStart = Duration(milliseconds: 1800);
  static const _dominoPeriod = Duration(milliseconds: 1800);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _introDuration,
  );
  late final AnimationController _domino = AnimationController(
    vsync: this,
    duration: _dominoPeriod,
  );

  bool _introDone = false;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _intro.forward().whenComplete(() {
      _introDone = true;
      _maybeLeave();
    });
    Future<void>.delayed(_dominoStart, () {
      if (mounted && !_left && !_reduceMotion) _domino.repeat();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotion) {
      _intro.value = 1;
      _introDone = true;
    }
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _maybeLeave() {
    if (_left || !_introDone || !mounted) return;
    if (!ref.read(bootstrapProvider).hasValue) return;
    _left = true;
    _domino.stop();
    context.go('/home');
  }

  @override
  void dispose() {
    _intro.dispose();
    _domino.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(bootstrapProvider, (_, next) {
      if (next.hasValue) _maybeLeave();
    });
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: TchipColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: TchipSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Semantics(
                        label: l.appName,
                        excludeSemantics: true,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_intro, _domino]),
                          builder: (context, _) => _wordmark(),
                        ),
                      ),
                    ),
                    const SizedBox(height: TchipSpacing.xl),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _intro,
                        curve: const Interval(
                          1100 / 1700,
                          1,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          l.splashTagline,
                          textAlign: TextAlign.center,
                          style: TchipText.body.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: TchipColors.textSoft,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: TchipSpacing.xxl,
              right: TchipSpacing.xxl,
              bottom: 64,
              child: Text(
                l.splashLoading,
                textAlign: TextAlign.center,
                style: TchipText.caption.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wordmark() {
    final ms = _intro.value * _introDuration.inMilliseconds;
    final style = TchipText.title.copyWith(
      fontSize: 64,
      letterSpacing: -1.9,
      height: 1.1,
    );

    final children = <Widget>[];
    for (var i = 0; i < _glyphs.length; i++) {
      final t = ((ms - i * 80) / 350).clamp(0.0, 1.0);
      final e = Curves.easeOut.transform(t);
      children.add(
        _tilt(
          i,
          Opacity(
            opacity: e,
            child: Transform.translate(
              offset: Offset(0, 14 * (1 - e)),
              child: Text(_glyphs[i], style: style),
            ),
          ),
        ),
      );
    }
    children.add(const SizedBox(width: 14));

    final bang = _bang(((ms - 500) / 600).clamp(0.0, 1.0));
    children.add(
      _tilt(
        _glyphs.length,
        Opacity(
          opacity: bang.opacity,
          child: Transform.translate(
            offset: Offset(0, bang.dy),
            child: Text(
              '!',
              style: style.copyWith(color: TchipColors.yellow),
            ),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: children,
    );
  }

  /// Keyframes of the "!" drop: 0 % (-60, hidden), 40 % (0, visible),
  /// 60 % (-16), 80 % (0), 90 % (-4), 100 % (0). Ease-out on each segment.
  static ({double opacity, double dy}) _bang(double t) {
    if (t <= 0) return (opacity: 0, dy: -60);
    const stops = [0.0, 0.4, 0.6, 0.8, 0.9, 1.0];
    const ys = [-60.0, 0.0, -16.0, 0.0, -4.0, 0.0];
    var seg = 0;
    while (seg < stops.length - 2 && t > stops[seg + 1]) {
      seg++;
    }
    final local = Curves.easeOut.transform(
      ((t - stops[seg]) / (stops[seg + 1] - stops[seg])).clamp(0.0, 1.0),
    );
    final dy = ys[seg] + (ys[seg + 1] - ys[seg]) * local;
    final opacity = seg == 0 ? local : 1.0;
    return (opacity: opacity, dy: dy);
  }

  /// Domino tilt for glyph [index]: 0 → 16° at 12 % of the period,
  /// back to 0 at 26 %, then still. Each glyph is 100 ms behind the previous.
  Widget _tilt(int index, Widget child) {
    if (!_domino.isAnimating) return child;
    final periodMs = _dominoPeriod.inMilliseconds;
    final phaseMs =
        (_domino.value * periodMs - index * 100) % periodMs;
    final p = phaseMs / periodMs;
    double deg;
    if (p < 0.12) {
      deg = 16 * Curves.easeInOut.transform(p / 0.12);
    } else if (p < 0.26) {
      deg = 16 * (1 - Curves.easeInOut.transform((p - 0.12) / 0.14));
    } else {
      deg = 0;
    }
    return Transform.rotate(
      angle: deg * math.pi / 180,
      alignment: const Alignment(0.7, 0.9),
      child: child,
    );
  }
}

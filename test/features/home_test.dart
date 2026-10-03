import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tchip/app.dart';
import 'package:tchip/core/settings/language_setting.dart';
import 'package:tchip/data/sample/sample_data.dart';
import 'package:tchip/providers/home_provider.dart';

class _Fixed extends SampleScenarioNotifier {
  _Fixed(this.scenario);
  final SampleScenario scenario;

  @override
  SampleScenario build() => scenario;
}

/// Spaces as the formatter writes them (narrow no-break) → plain spaces.
String _plain(String s) => s.replaceAll(RegExp('[  ]'), ' ');

Finder _textPlain(String text) => find.byWidgetPredicate(
  (w) => w is Text && w.data != null && _plain(w.data!) == text,
);

Future<void> _pump(
  WidgetTester tester, {
  SampleScenario scenario = SampleScenario.ok,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  SharedPreferences.setMockInitialValues({
    'language': 'fr',
    'onboarding_done': true,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sampleScenarioProvider.overrideWith(() => _Fixed(scenario)),
        // Monday 12 October 2026, as in the maquette.
        nowProvider.overrideWithValue(() => DateTime(2026, 10, 12, 9, 45)),
      ],
      child: const TchipApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('OK state', (tester) async {
    await _pump(tester);
    expect(find.text('Lundi 12 octobre'), findsOneWidget);
    expect(find.text('Semaine de cours'), findsOneWidget);
    expect(_textPlain('Plan du 12 au 18 oct.'), findsOneWidget);
    expect(find.text('Dans le budget'), findsOneWidget);
    expect(_textPlain('6 200 F'), findsOneWidget);
    expect(_textPlain('Il te reste 13 800 F pour 6 jours.'), findsOneWidget);
    expect(_textPlain('Reste 1 300 F'), findsOneWidget);
    expect(_textPlain('+85 000 F'), findsOneWidget);
    expect(_textPlain('1 250 F'), findsOneWidget);
    expect(find.text('Retrait'), findsOneWidget);
    expect(_textPlain('frais 300 F'), findsOneWidget);
  });

  testWidgets('80 % alert state', (tester) async {
    await _pump(tester, scenario: SampleScenario.warning);
    expect(_textPlain('82 % du plafond'), findsOneWidget);
    expect(_textPlain('Plus que 3 600 F pour 6 jours.'), findsOneWidget);
  });

  testWidgets('over state', (tester) async {
    await _pump(tester, scenario: SampleScenario.over);
    expect(find.text('Plafond dépassé'), findsOneWidget);
    expect(
      _textPlain('Tu as dépassé le plafond du plan de 1 300 F.'),
      findsOneWidget,
    );
  });

  testWidgets('today card opens the day screen', (tester) async {
    await _pump(tester);
    await tester.tap(find.text("Aujourd'hui"));
    await tester.pumpAndSettle();
    // Day screen placeholder has a back button.
    expect(find.byTooltip('Retour'), findsOneWidget);
  });

  testWidgets('"Tout voir" opens operations', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Tout voir'));
    await tester.pumpAndSettle();
    expect(find.text('Dernières opérations'), findsNothing);
  });

  for (final (size, scale) in [
    (const Size(320, 640), 1.3),
    (const Size(844, 390), 1.3),
    (const Size(1194, 834), 1.0),
    (const Size(1194, 834), 1.3),
  ]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()} '
        'font ${(scale * 100).round()} %', (tester) async {
      await _pump(tester, size: size, textScale: scale);
      expect(tester.takeException(), isNull);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tchip/app.dart';
import 'package:tchip/core/settings/language_setting.dart';

Future<void> _pumpHome(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({
    'language': 'fr',
    'onboarding_done': true,
  });
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TchipApp(),
    ),
  );
  // Splash intro and simulated loading.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets('phone ${width.toInt()} dp: bottom bar sits at the bottom', (
      tester,
    ) async {
      const height = 844.0;
      await _pumpHome(tester, Size(width, height));

      final navTop = tester.getTopLeft(find.text('Accueil')).dy;
      expect(navTop, greaterThan(height - 120));
      // Home content is visible above the bar.
      expect(tester.getTopLeft(find.byTooltip('Réglages')).dy, lessThan(120));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tablet landscape uses the side rail', (tester) async {
    await _pumpHome(tester, const Size(1194, 834));
    final navLeft = tester.getTopLeft(find.text('Accueil')).dx;
    expect(navLeft, lessThan(96));
    expect(tester.takeException(), isNull);
  });
}

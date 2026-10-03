import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tchip/app.dart';
import 'package:tchip/core/settings/language_setting.dart';
import 'package:tchip/sms/sms_permission.dart';

class _FakePermission extends SmsPermission {
  _FakePermission(this.answers);

  /// Successive answers to request().
  final List<SmsPermissionResult> answers;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<SmsPermissionResult> request() async => answers[requests++];

  @override
  Future<SmsPermissionResult> status() async => answers.last;

  @override
  Future<bool> openSystemSettings() async {
    settingsOpened++;
    return true;
  }
}

Future<SharedPreferences> _pump(
  WidgetTester tester,
  _FakePermission permission, {
  Size size = const Size(390, 844),
  Map<String, Object> prefs = const {'language': 'fr'},
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        smsPermissionProvider.overrideWithValue(permission),
      ],
      child: const TchipApp(),
    ),
  );
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  return sp;
}

/// Scrolls the button into view first: on small screens it is below the fold.
Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first launch shows the welcome screen', (tester) async {
    await _pump(tester, _FakePermission([SmsPermissionResult.granted]));
    expect(find.text('Sache enfin où part ton argent MoMo.'), findsOneWidget);
    expect(find.text('Autoriser la lecture des SMS'), findsOneWidget);
  });

  testWidgets('granting SMS goes home and remembers the choice', (
    tester,
  ) async {
    final p = _FakePermission([SmsPermissionResult.granted]);
    final sp = await _pump(tester, p);

    await _tap(tester, 'Autoriser la lecture des SMS');

    expect(p.requests, 1);
    expect(find.text('Accueil'), findsOneWidget);
    expect(sp.getBool('onboarding_done'), isTrue);
    expect(sp.getBool('sms_enabled'), isTrue);
  });

  testWidgets('starting without SMS goes home without asking', (tester) async {
    final p = _FakePermission([SmsPermissionResult.granted]);
    final sp = await _pump(tester, p);

    await _tap(tester, 'Commencer sans les SMS');

    expect(p.requests, 0);
    expect(find.text('Accueil'), findsOneWidget);
    expect(sp.getBool('onboarding_done'), isTrue);
    expect(sp.getBool('sms_enabled'), isFalse);
  });

  testWidgets('denied permission stays on screen with an explanation', (
    tester,
  ) async {
    final p = _FakePermission([
      SmsPermissionResult.denied,
      SmsPermissionResult.granted,
    ]);
    await _pump(tester, p);

    await _tap(tester, 'Autoriser la lecture des SMS');
    expect(find.textContaining('Permission refusée'), findsOneWidget);
    expect(find.text('Accueil'), findsNothing);

    // Second try succeeds.
    await _tap(tester, 'Autoriser la lecture des SMS');
    expect(find.text('Accueil'), findsOneWidget);
  });

  testWidgets('blocked permission offers the phone settings', (tester) async {
    final p = _FakePermission([SmsPermissionResult.blocked]);
    await _pump(tester, p);

    await _tap(tester, 'Autoriser la lecture des SMS');
    expect(find.textContaining('bloquée'), findsOneWidget);

    await _tap(tester, 'Ouvrir les réglages du téléphone');
    expect(p.settingsOpened, 1);
  });

  testWidgets('second launch skips the welcome screen', (tester) async {
    await _pump(
      tester,
      _FakePermission([SmsPermissionResult.granted]),
      prefs: {'language': 'fr', 'onboarding_done': true},
    );
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Autoriser la lecture des SMS'), findsNothing);
  });

  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()} '
        'with 130 % font', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(
        tester,
        _FakePermission([SmsPermissionResult.granted]),
        size: size,
      );
      expect(tester.takeException(), isNull);
      // Buttons reachable by scrolling.
      await tester.scrollUntilVisible(
        find.text('Commencer sans les SMS'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Commencer sans les SMS'), findsOneWidget);
    });
  }

  testWidgets('English texts', (tester) async {
    await _pump(
      tester,
      _FakePermission([SmsPermissionResult.granted]),
      prefs: {'language': 'en'},
    );
    expect(find.text('Allow SMS reading'), findsOneWidget);
    expect(find.text('Start without SMS'), findsOneWidget);
  });
}

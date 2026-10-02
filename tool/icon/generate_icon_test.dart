// Renders the launcher icon sources with the real Geist font.
// Run: flutter test tool/icon/generate_icon_test.dart
// Then: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchip/theme/tchip_colors.dart';

const _size = 1024.0;

Future<void> _loadGeist() async {
  final loader = FontLoader('Geist')
    ..addFont(
      Future.value(
        ByteData.view(
          File('assets/fonts/Geist-Bold.ttf').readAsBytesSync().buffer,
        ),
      ),
    );
  await loader.load();
}

/// "T!" in Geist Bold: white T, yellow "!".
/// [scale] is the glyph height relative to the canvas.
Widget _mark(double scale) => Center(
  child: Text.rich(
    TextSpan(
      style: TextStyle(
        fontFamily: 'Geist',
        fontWeight: FontWeight.w700,
        fontSize: _size * scale,
        height: 1,
        letterSpacing: -_size * scale * 0.02,
        color: TchipColors.text,
      ),
      children: const [
        TextSpan(text: 'T'),
        TextSpan(text: '!', style: TextStyle(color: TchipColors.yellow)),
      ],
    ),
    textDirection: TextDirection.ltr,
  ),
);

Future<void> _render(WidgetTester tester, Widget child, String path) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox(width: _size, height: _size, child: child),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render launcher icon sources', (tester) async {
    await _loadGeist();
    tester.view.physicalSize = const Size(_size, _size);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Legacy icon (Android 7): full square, the launcher applies its own mask.
    await _render(
      tester,
      ColoredBox(color: TchipColors.background, child: _mark(0.50)),
      'assets/icon/icon.png',
    );

    // Adaptive foreground (Android 8+): transparent. flutter_launcher_icons
    // insets it by 16 %, so the mark ends up about the same size as on the
    // legacy icon and stays inside the 66 % safe zone of every launcher mask.
    await _render(tester, _mark(0.56), 'assets/icon/foreground.png');
  });
}

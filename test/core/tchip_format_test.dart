import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tchip/core/format/tchip_format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr');
    await initializeDateFormatting('en');
  });

  final fr = TchipFormat(const Locale('fr'));
  final en = TchipFormat(const Locale('en'));
  String plain(String s) => s.replaceAll(RegExp('[\u00A0\u202F]'), ' ');

  test('amounts follow the locale', () {
    expect(plain(fr.amount(12500)), '12 500 F');
    expect(plain(en.amount(12500)), '12,500 F');
  });

  test('signed amounts use a real minus sign', () {
    expect(plain(fr.signed(-1500)), '\u22121 500 F');
    expect(plain(fr.signed(20000)), '+20 000 F');
  });

  test('long day is capitalized', () {
    final d = DateTime(2026, 10, 12);
    expect(fr.dayLong(d), 'Lundi 12 octobre');
    expect(en.dayLong(d), 'Monday, October 12');
  });
}

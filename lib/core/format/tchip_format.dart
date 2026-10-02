import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware formatting of amounts and dates.
/// French: "12 500 F", "Lundi 12 octobre". English: "12,500 F", "Monday, October 12".
class TchipFormat {
  TchipFormat(this.locale)
    : _number = NumberFormat.decimalPattern(locale.toLanguageTag());

  factory TchipFormat.of(BuildContext context) =>
      TchipFormat(Localizations.localeOf(context));

  final Locale locale;
  final NumberFormat _number;

  String get _tag => locale.toLanguageTag();

  /// Number only, with the locale grouping separator.
  String number(int value) => _number.format(value);

  /// Amount in FCFA: "12 500 F".
  String amount(int value) => '${number(value)}\u00A0F';

  /// Signed amount with a real minus sign (U+2212): "−1 500 F", "+20 000 F".
  String signed(int value) {
    if (value == 0) return amount(0);
    final sign = value < 0 ? '\u2212' : '+';
    return '$sign${amount(value.abs())}';
  }

  /// "Lundi 12 octobre" / "Monday, October 12".
  String dayLong(DateTime d) => _capitalize(
    locale.languageCode == 'fr'
        ? DateFormat('EEEE d MMMM', _tag).format(d)
        : DateFormat.MMMMEEEEd(_tag).format(d),
  );

  /// "12 oct." / "Oct 12".
  String dayShort(DateTime d) => DateFormat.MMMd(_tag).format(d);

  /// "09:40".
  String time(DateTime d) => DateFormat.Hm(_tag).format(d);

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

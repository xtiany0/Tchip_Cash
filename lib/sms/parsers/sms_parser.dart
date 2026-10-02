import '../../data/models/transaction.dart';

/// Turns one operator SMS into a [Transaction], or null when the SMS is not
/// a transaction this parser knows (OTP, promo, balance check…).
abstract class SmsParser {
  const SmsParser();

  Operator get operator;

  Transaction? parse(String body);
}

/// Shared helpers for operator parsers.
abstract final class ParseUtils {
  /// "12 500", "12500", "3 300" (any space kind) → 12500.
  static int amount(String s) =>
      int.parse(s.replaceAll(RegExp(r'\s'), ''));

  /// Collapses runs of spaces and trims.
  static String name(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// "2026-09-30 08:12:37" → DateTime (local time).
  static DateTime isoDateTime(String s) => DateTime.parse(s.replaceFirst(' ', 'T'));

  /// "11/08/2026 13:07:15" → DateTime (local time).
  static DateTime frDateTime(String date, String time) {
    final d = date.split('/').map(int.parse).toList();
    final t = time.split(':').map(int.parse).toList();
    return DateTime(d[2], d[1], d[0], t[0], t[1], t.length > 2 ? t[2] : 0);
  }
}

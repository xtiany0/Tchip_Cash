import '../../data/models/transaction.dart';
import 'sms_parser.dart';

/// Moov Money Bénin. Known formats (2026):
///   Vous avez envoye 3 000 FCFA à l'Agent NAME 229… le 11/08/2026 13:07:15. FRAIS: 125 FCFA.
///   Nouveau solde : compte Principal est de 210 FCFA. Réf: …
///   Vous avez recu 3 300 FCFA le 09/08/2026 18:41:26 de NAME  229…. Motif: '' … ''
///   Solde : 3 335 FCFA. Ref : …
/// Sending to an agent is a cash withdrawal; sending to a person is a transfer.
class MoovParser extends SmsParser {
  const MoovParser();

  @override
  Operator get operator => Operator.moov;

  static const _amount = r'(\d[\d\s]*)\s*FCFA';
  static const _date = r'(\d{2}/\d{2}/\d{4})\s+(\d{2}:\d{2}(?::\d{2})?)';

  static final _sent = RegExp(
    r'Vous avez envoy[eé]\s+' +
        _amount +
        r"\s+[àa]\s+(l['’]Agent\s+)?(.+?)\s+(\d{8,13})\s+le\s+" +
        _date,
    caseSensitive: false,
  );
  static final _received = RegExp(
    'Vous avez re[çc]u\\s+$_amount\\s+le\\s+$_date\\s+de\\s+(.+?)\\s+(\\d{8,13})',
    caseSensitive: false,
  );
  static final _fee = RegExp('FRAIS\\s*:\\s*$_amount', caseSensitive: false);
  static final _balance = RegExp(
    '(?:Nouveau solde[^:]*:[^0-9]*|Solde\\s*:\\s*)$_amount',
    caseSensitive: false,
  );
  static final _ref = RegExp(r'R[ée]f\s*:\s*(\d+)', caseSensitive: false);

  @override
  Transaction? parse(String body) {
    final DateTime date;
    final int amount;
    final TransactionType type;
    final String counterparty;
    final String phone;

    final sent = _sent.firstMatch(body);
    final received = sent == null ? _received.firstMatch(body) : null;
    if (sent != null) {
      amount = ParseUtils.amount(sent.group(1)!);
      type = sent.group(2) != null
          ? TransactionType.withdrawal
          : TransactionType.send;
      counterparty = ParseUtils.name(sent.group(3)!);
      phone = sent.group(4)!;
      date = ParseUtils.frDateTime(sent.group(5)!, sent.group(6)!);
    } else if (received != null) {
      amount = ParseUtils.amount(received.group(1)!);
      type = TransactionType.receive;
      date = ParseUtils.frDateTime(received.group(2)!, received.group(3)!);
      counterparty = ParseUtils.name(received.group(4)!);
      phone = received.group(5)!;
    } else {
      return null;
    }

    int? group(RegExp r) {
      final g = r.firstMatch(body)?.group(1);
      return g == null ? null : ParseUtils.amount(g);
    }

    return Transaction(
      date: date,
      amount: amount,
      fee: group(_fee) ?? 0,
      type: type,
      operator: operator,
      counterparty: counterparty,
      counterpartyPhone: phone,
      balance: group(_balance),
      reference: _ref.firstMatch(body)?.group(1),
      rawSms: body,
      source: TransactionSource.sms,
    );
  }
}

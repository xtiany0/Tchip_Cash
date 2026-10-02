import '../../data/models/transaction.dart';
import 'sms_parser.dart';

/// MTN MoMo Bénin. Known formats (2026):
///   Transfert 12500F de NAME (229…) 2026-09-30 08:12:37 Ref:1 Solde:24998F ID:…
///   Transfert 1000F a NAME(229…) 2026-10-01 12:29:37 Frais: 0F Solde:5748F Ref: ... ID: …
///   Paiement 2125F a NAME P2M (229…) 2026-09-30 10:26:51 Frais:0F Solde:23373F ID:…
///   Paiement 1000F a BUY DATA 2026-07-23 17:21:02 Frais:0F Solde:14431F ID:… Ref:-
///   Retrait 2500F via AGENT(229… - CODE) 2026-09-29 20:50:46 Solde:12498F Frais:125F ID:…
class MtnParser extends SmsParser {
  const MtnParser();

  @override
  Operator get operator => Operator.mtn;

  static final _head = RegExp(
    r'^\s*(Transfert|Paiement|Retrait)\s+(\d[\d\s]*)\s*F(?:CFA)?\s+(de|a|à|via)\s+'
    r'(.+?)\s*(?:\((\d{8,13})(?:\s*-\s*[^)]*)?\))?\s+'
    r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})',
    caseSensitive: false,
  );
  static final _fee = RegExp(r'Frais\s*:\s*(\d[\d\s]*)\s*F', caseSensitive: false);
  static final _balance = RegExp(r'Solde\s*:\s*(\d[\d\s]*)\s*F', caseSensitive: false);
  static final _id = RegExp(r'\bID\s*:\s*(\d+)');

  /// Merchants that sell data or airtime bundles.
  static final _bundle = RegExp(r'\b(BUY DATA|FORFAIT|BUNDLE|CREDIT)\b', caseSensitive: false);

  @override
  Transaction? parse(String body) {
    final m = _head.firstMatch(body);
    if (m == null) return null;

    final verb = m.group(1)!.toLowerCase();
    final preposition = m.group(3)!.toLowerCase();
    final counterparty = ParseUtils.name(m.group(4)!);

    final type = switch (verb) {
      'retrait' => TransactionType.withdrawal,
      'paiement' when _bundle.hasMatch(counterparty) => TransactionType.bundle,
      'paiement' => TransactionType.payment,
      _ => preposition == 'de' ? TransactionType.receive : TransactionType.send,
    };

    int? group(RegExp r) {
      final g = r.firstMatch(body)?.group(1);
      return g == null ? null : ParseUtils.amount(g);
    }

    return Transaction(
      date: ParseUtils.isoDateTime(m.group(6)!),
      amount: ParseUtils.amount(m.group(2)!),
      fee: group(_fee) ?? 0,
      type: type,
      operator: operator,
      counterparty: counterparty,
      counterpartyPhone: m.group(5),
      balance: group(_balance),
      reference: _id.firstMatch(body)?.group(1),
      rawSms: body,
      source: TransactionSource.sms,
    );
  }
}

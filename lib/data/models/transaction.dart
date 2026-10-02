/// Mobile Money operator, or cash for manual entries.
enum Operator { mtn, moov, celtiis, cash }

/// Kind of operation, as in the `transactions.type` column.
enum TransactionType {
  /// Money sent to a person.
  send,

  /// Money received.
  receive,

  /// Cash withdrawal at an agent.
  withdrawal,

  /// Payment to a merchant.
  payment,

  /// Airtime or data bundle.
  bundle;

  bool get isIncome => this == receive;
}

enum TransactionSource { sms, manual }

/// One operation. Amounts are whole FCFA.
class Transaction {
  const Transaction({
    this.id,
    required this.date,
    required this.amount,
    this.fee = 0,
    required this.type,
    required this.operator,
    this.counterparty,
    this.counterpartyPhone,
    this.categoryId,
    this.balance,
    this.reference,
    this.note,
    this.rawSms,
    required this.source,
  });

  /// Database id, null before insertion.
  final int? id;
  final DateTime date;

  /// Amount of the operation, always positive. See [type] for its direction.
  final int amount;

  /// Fee charged by the operator on top of [amount].
  final int fee;
  final TransactionType type;
  final Operator operator;
  final String? counterparty;
  final String? counterpartyPhone;
  final int? categoryId;

  /// Balance after the operation, when the SMS gives it.
  final int? balance;

  /// Operator transaction id. Used to skip duplicates on import.
  final String? reference;
  final String? note;

  /// Full SMS text, kept to replay parsing when rules change.
  final String? rawSms;
  final TransactionSource source;

  /// Signed effect on the balance: negative for spending, fee included.
  int get signedTotal => type.isIncome ? amount - fee : -(amount + fee);

  Transaction copyWith({int? id, int? categoryId}) => Transaction(
    id: id ?? this.id,
    date: date,
    amount: amount,
    fee: fee,
    type: type,
    operator: operator,
    counterparty: counterparty,
    counterpartyPhone: counterpartyPhone,
    categoryId: categoryId ?? this.categoryId,
    balance: balance,
    reference: reference,
    note: note,
    rawSms: rawSms,
    source: source,
  );

  @override
  String toString() =>
      'Transaction(${operator.name} ${type.name} $amount F, fee $fee F, '
      '$counterparty, $date, ref $reference)';
}

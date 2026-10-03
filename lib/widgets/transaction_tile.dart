import 'package:flutter/material.dart';

import '../core/format/tchip_format.dart';
import '../data/models/transaction.dart';
import '../domain/categories.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/tchip_theme.dart';

/// One operation row: icon, title, "category · operator · time", amount and
/// operator fee under it.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.showIcon = true,
    this.verticalPadding = 6,
  });

  final Transaction transaction;
  final bool showIcon;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    final t = transaction;
    final category = DefaultCategory.byId(t.categoryId);
    final income = t.type.isIncome;

    final subtitle = [
      ?category?.label(l),
      if (category == null && t.type == TransactionType.receive)
        _typeLabel(l, t.type),
      _operatorLabel(l, t.operator),
      f.time(t.date),
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        children: [
          if (showIcon) ...[
            _Icon(transaction: t, category: category),
            const SizedBox(width: TchipSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(l, t),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TchipText.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TchipText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: TchipSpacing.md),
          // Amount keeps its size; it only shrinks when the row is too narrow.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    f.signed(income ? t.amount : -t.amount),
                    style: TchipText.amountLight(
                      15,
                      color: income ? TchipColors.okText : TchipColors.text,
                    ),
                  ),
                  if (_showFee(t)) ...[
                    const SizedBox(height: 2),
                    Text(l.opFee(f.amount(t.fee)), style: TchipText.caption),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Fee line under SMS sends, withdrawals and payments, even at 0 F, so the
  /// user sees the operator charged nothing. Never on cash or bundles.
  static bool _showFee(Transaction t) =>
      t.fee > 0 ||
      (t.source == TransactionSource.sms &&
          const {
            TransactionType.send,
            TransactionType.withdrawal,
            TransactionType.payment,
          }.contains(t.type));

  static String _title(AppLocalizations l, Transaction t) {
    if (t.note != null && t.note!.isNotEmpty) return t.note!;
    final who = t.counterparty;
    return switch (t.type) {
      TransactionType.receive when who != null => l.opReceivedFrom(who),
      TransactionType.send when who != null => l.opSentTo(who),
      TransactionType.payment || TransactionType.bundle when who != null => who,
      _ => _typeLabel(l, t.type),
    };
  }

  static String _typeLabel(AppLocalizations l, TransactionType type) =>
      switch (type) {
        TransactionType.send => l.typeSend,
        TransactionType.receive => l.typeReceive,
        TransactionType.withdrawal => l.typeWithdrawal,
        TransactionType.payment => l.typePayment,
        TransactionType.bundle => l.typeBundle,
      };

  static String _operatorLabel(AppLocalizations l, Operator o) => switch (o) {
    Operator.mtn => 'MTN',
    Operator.moov => 'Moov',
    Operator.celtiis => 'Celtiis',
    Operator.cash => l.opCash,
  };
}

class _Icon extends StatelessWidget {
  const _Icon({required this.transaction, required this.category});

  final Transaction transaction;
  final DefaultCategory? category;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (transaction.type) {
      TransactionType.receive => (Icons.south_west, TchipColors.okText),
      TransactionType.withdrawal => (
        Icons.payments_outlined,
        TchipColors.textMuted,
      ),
      _ when category != null => (category!.icon, category!.color),
      _ => (Icons.north_east, TchipColors.textMuted),
    };
    return ExcludeSemantics(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TchipColors.cardRaised,
          borderRadius: TchipRadii.all(TchipRadii.md),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

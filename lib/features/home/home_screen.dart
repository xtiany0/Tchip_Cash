import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/tchip_format.dart';
import '../../core/layout/breakpoints.dart';
import '../../domain/home_summary.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/home_provider.dart';
import '../../theme/tchip_theme.dart';
import '../../widgets/placeholder_screen.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/tchip_logo.dart';
import '../../widgets/transaction_tile.dart';

/// Home (maquette/Main.dc.html, and Tablette.dc.html in landscape tablets):
/// current plan, today by category, money received and fees this month,
/// latest operations.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeSummaryProvider);
    return Scaffold(
      body: SafeArea(
        child: context.isTablet
            ? _TabletHome(summary: summary)
            : _PhoneHome(summary: summary),
      ),
    );
  }
}

class _PhoneHome extends StatelessWidget {
  const _PhoneHome({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TchipSpacing.screen,
        28,
        TchipSpacing.screen,
        TchipSpacing.xxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TchipLogo(),
                  const SizedBox(height: 2),
                  Text(
                    f.dayLong(summary.today),
                    style: TchipText.caption.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            TchipIconButton(
              icon: Icons.settings_outlined,
              label: l.homeSettingsTooltip,
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        const SizedBox(height: TchipSpacing.section),
        _PlanCard(plan: summary.plan, today: summary.today),
        const SizedBox(height: TchipSpacing.section),
        _TodayCard(summary: summary),
        const SizedBox(height: TchipSpacing.section),
        _MonthTiles(summary: summary),
        const SizedBox(height: TchipSpacing.section),
        _LatestHeader(),
        const SizedBox(height: TchipSpacing.sm),
        for (final t in summary.latest.take(2)) TransactionTile(transaction: t),
      ],
    );
  }
}

class _TabletHome extends StatelessWidget {
  const _TabletHome({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l.homeGreeting,
                style: TchipText.title.copyWith(fontSize: 28),
              ),
            ),
            Text(
              f.dayLong(summary.today),
              style: TchipText.bodySmall.copyWith(
                color: TchipColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: TchipSpacing.xxl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _PlanCard(plan: summary.plan, today: summary.today),
                  const SizedBox(height: TchipSpacing.lg),
                  _MonthTiles(summary: summary),
                ],
              ),
            ),
            const SizedBox(width: TchipSpacing.xl),
            Expanded(child: _TodayCard(summary: summary, vertical: true)),
            const SizedBox(width: TchipSpacing.xl),
            Expanded(
              child: _Card(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    _LatestHeader(),
                    for (final (i, t) in summary.latest.take(4).indexed) ...[
                      if (i > 0)
                        const Divider(height: 1, color: TchipColors.border),
                      TransactionTile(
                        transaction: t,
                        showIcon: false,
                        verticalPadding: 12,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Plain card from the maquette: #1B1B1B, 1 px border.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(TchipSpacing.lg),
    this.radius = TchipRadii.card,
    this.color = TchipColors.card,
    this.borderColor = TchipColors.border,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: TchipRadii.all(radius),
      border: Border.all(color: borderColor),
    ),
    child: child,
  );
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan, required this.today});

  final PlanProgress? plan;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    final p = plan;

    if (p == null) {
      return _Card(
        radius: TchipRadii.hero,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.homeNoPlanTitle, style: TchipText.bodyStrong),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go('/plans'),
              child: Text(l.homeNoPlanAction),
            ),
          ],
        ),
      );
    }

    final state = p.state;
    final (badge, message) = switch (state) {
      BudgetState.ok => (
        l.homeBadgeOk,
        l.homeMsgOk(f.amount(p.left), p.daysLeftAfter(today)),
      ),
      BudgetState.warning => (
        l.homeBadgeWarning(p.percent),
        l.homeMsgWarning(f.amount(p.left), p.daysLeftAfter(today)),
      ),
      BudgetState.over => (l.homeBadgeOver, l.homeMsgOver(f.amount(-p.left))),
    };
    final (bg, border) = switch (state) {
      BudgetState.ok => (TchipColors.card, TchipColors.border),
      BudgetState.warning => (
        TchipColors.card,
        TchipColors.warning.withValues(alpha: 0.45),
      ),
      BudgetState.over => (
        TchipColors.over.withValues(alpha: 0.12),
        TchipColors.over.withValues(alpha: 0.6),
      ),
    };
    final (start, end) = f.dayRange(p.start, p.end);

    return GestureDetector(
      // Debug only: cycle the three maquette states on sample data.
      onLongPress: kDebugMode
          ? () => ref.read(sampleScenarioProvider.notifier).next()
          : null,
      child: _Card(
        radius: TchipRadii.hero,
        padding: const EdgeInsets.all(18),
        color: bg,
        borderColor: border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: TchipText.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.homePlanRange(start, end),
                        style: TchipText.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TchipSpacing.sm),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: state.bar.withValues(
                          alpha: state == BudgetState.over ? 0.2 : 0.16,
                        ),
                        borderRadius: TchipRadii.all(TchipRadii.pill),
                      ),
                      child: Text(
                        badge,
                        style: TchipText.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: state.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: TchipSpacing.sm,
              children: [
                Text(f.amount(p.spent), style: TchipText.amount(38)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l.homeCapOf(f.amount(p.cap)),
                    style: TchipText.body.copyWith(
                      color: TchipColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TchipProgressBar(fill: p.fill, color: state.bar, height: 10),
            const SizedBox(height: 12),
            Text(
              message,
              style: TchipText.bodySmall.copyWith(color: TchipColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.summary, this.vertical = false});

  final HomeSummary summary;

  /// Tablet: one category per row instead of a grid.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    final left = summary.leftToday;

    final header = Row(
      children: [
        Expanded(
          child: Text(
            l.screenDay,
            style: TchipText.body.copyWith(
              fontSize: vertical ? 16 : 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: TchipSpacing.sm),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              left >= 0
                  ? l.homeTodayLeft(f.amount(left))
                  : l.homeTodayOver(f.amount(-left)),
              style: TchipText.caption.copyWith(
                fontSize: 13,
                color: left >= 0 ? TchipColors.yellow : TchipColors.overText,
              ),
            ),
          ),
        ),
        if (!vertical)
          const Icon(Icons.chevron_right, size: 18, color: TchipColors.yellow),
      ],
    );

    final cats = summary.categoriesToday;
    final Widget body;
    if (vertical) {
      body = Column(
        children: [
          for (final (i, c) in cats.indexed) ...[
            if (i > 0) const SizedBox(height: TchipSpacing.lg),
            _CategoryRow(day: c),
          ],
        ],
      );
    } else {
      body = LayoutBuilder(
        builder: (context, constraints) {
          // Three columns as in the maquette, fewer when the screen is narrow
          // or the system font is large, so amounts never get cut.
          final minWidth = MediaQuery.textScalerOf(context).scale(90);
          final columns = (constraints.maxWidth / (minWidth + 12))
              .floor()
              .clamp(1, 3);
          final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in cats)
                SizedBox(
                  width: width,
                  child: _CategoryCell(day: c),
                ),
            ],
          );
        },
      );
    }

    return Semantics(
      button: true,
      hint: l.homeTodayHint,
      child: Material(
        color: TchipColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: TchipRadii.all(
            vertical ? TchipRadii.hero : TchipRadii.card,
          ),
          side: const BorderSide(color: TchipColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/home/day'),
          child: Padding(
            padding: EdgeInsets.all(vertical ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                SizedBox(height: vertical ? 16 : 12),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _capPair(TchipFormat f, CategoryDay c) =>
    '${f.number(c.spent)} / ${f.number(c.cap)}';

Color _capPairColor(CategoryDay c) =>
    c.state == BudgetState.ok ? TchipColors.textSoft : c.state.text;

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({required this.day});

  final CategoryDay day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.category.label(l),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TchipText.caption,
        ),
        const SizedBox(height: 6),
        TchipProgressBar(fill: day.fill, color: day.state.bar),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _capPair(f, day),
            style: TchipText.amountLight(12, color: _capPairColor(day)),
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.day});

  final CategoryDay day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(day.category.label(l), style: TchipText.bodySmall),
            ),
            const SizedBox(width: TchipSpacing.sm),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _capPair(f, day),
                  style: TchipText.amountLight(14, color: _capPairColor(day)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TchipSpacing.sm),
        TchipProgressBar(fill: day.fill, color: day.state.bar),
      ],
    );
  }
}

class _MonthTiles extends StatelessWidget {
  const _MonthTiles({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = TchipFormat.of(context);
    Widget tile(String label, String value, Color color) => Expanded(
      child: _Card(
        radius: TchipRadii.xl,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TchipText.caption),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TchipText.amount(17, color: color)),
            ),
          ],
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile(
            l.homeReceivedMonth,
            f.signed(summary.receivedThisMonth),
            TchipColors.okText,
          ),
          const SizedBox(width: 12),
          tile(
            l.homeFeesMonth,
            f.amount(summary.feesThisMonth),
            TchipColors.text,
          ),
        ],
      ),
    );
  }
}

class _LatestHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: Text(l.homeLatest, style: TchipText.section)),
        Flexible(
          child: TextButton(
            onPressed: () => context.go('/operations'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(l.homeSeeAll, maxLines: 1),
          ),
        ),
      ],
    );
  }
}

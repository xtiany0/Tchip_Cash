import '../data/models/transaction.dart';
import '../theme/tchip_colors.dart';
import 'categories.dart';

/// Spending of the current plan against its global cap.
class PlanProgress {
  const PlanProgress({
    required this.name,
    required this.start,
    required this.end,
    required this.cap,
    required this.spent,
  });

  final String name;
  final DateTime start;

  /// Last day of the plan, included.
  final DateTime end;
  final int cap;
  final int spent;

  BudgetState get state => BudgetState.of(spent, cap);

  /// Spent / cap in percent, rounded, not capped at 100.
  int get percent => cap <= 0 ? 0 : (spent * 100 / cap).round();

  /// Bar fill, 0 to 1.
  double get fill => cap <= 0 ? 1 : (spent / cap).clamp(0.0, 1.0);

  /// Negative when the cap is exceeded.
  int get left => cap - spent;

  /// Days of the plan still to come after [today].
  int daysLeftAfter(DateTime today) {
    final t = DateTime(today.year, today.month, today.day);
    final e = DateTime(end.year, end.month, end.day);
    final d = e.difference(t).inDays;
    return d < 0 ? 0 : d;
  }
}

/// Today's spending in one category against its daily cap.
class CategoryDay {
  const CategoryDay({
    required this.category,
    required this.spent,
    required this.cap,
  });

  final DefaultCategory category;
  final int spent;
  final int cap;

  BudgetState get state => BudgetState.of(spent, cap);
  double get fill => cap <= 0 ? 1 : (spent / cap).clamp(0.0, 1.0);
}

/// Everything the home screen shows.
class HomeSummary {
  const HomeSummary({
    required this.today,
    required this.plan,
    required this.categoriesToday,
    required this.receivedThisMonth,
    required this.feesThisMonth,
    required this.latest,
  });

  final DateTime today;

  /// Null when no plan covers today.
  final PlanProgress? plan;
  final List<CategoryDay> categoriesToday;
  final int receivedThisMonth;
  final int feesThisMonth;

  /// Most recent first.
  final List<Transaction> latest;

  /// Left for today across all categories with a cap. Negative when over.
  int get leftToday => categoriesToday.fold(0, (s, c) => s + c.cap - c.spent);
}

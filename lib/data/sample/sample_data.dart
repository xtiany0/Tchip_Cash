import '../../domain/categories.dart';
import '../../domain/home_summary.dart';
import '../models/transaction.dart';

/// Budget states of the maquette (Main.dc.html, prop "etat").
enum SampleScenario { ok, warning, over }

/// Example data shaped like the maquette, used until SQLite is wired.
/// Dates are relative to [now] so the screens always look current.
HomeSummary sampleHomeSummary(DateTime now, SampleScenario scenario) {
  final today = DateTime(now.year, now.month, now.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final spent = switch (scenario) {
    SampleScenario.ok => 6200,
    SampleScenario.warning => 16400,
    SampleScenario.over => 21300,
  };

  return HomeSummary(
    today: today,
    plan: PlanProgress(
      name: 'Semaine de cours',
      start: monday,
      end: monday.add(const Duration(days: 6)),
      cap: 20000,
      spent: spent,
    ),
    categoriesToday: const [
      CategoryDay(category: DefaultCategory.food, spent: 1200, cap: 2000),
      CategoryDay(category: DefaultCategory.transport, spent: 1000, cap: 1200),
      CategoryDay(category: DefaultCategory.leisure, spent: 500, cap: 800),
    ],
    receivedThisMonth: 85000,
    feesThisMonth: 1250,
    latest: [
      Transaction(
        date: today.add(const Duration(hours: 9, minutes: 40)),
        amount: 20000,
        fee: 300,
        type: TransactionType.withdrawal,
        operator: Operator.mtn,
        source: TransactionSource.sms,
      ),
      Transaction(
        date: today.add(const Duration(hours: 8, minutes: 14)),
        amount: 500,
        type: TransactionType.payment,
        operator: Operator.cash,
        categoryId: DefaultCategory.transport.id,
        note: 'Zém Akpakpa',
        source: TransactionSource.manual,
      ),
      Transaction(
        date: today.add(const Duration(hours: 7, minutes: 52)),
        amount: 1500,
        type: TransactionType.bundle,
        operator: Operator.mtn,
        categoryId: DefaultCategory.bundles.id,
        note: 'Forfait 3 Go',
        source: TransactionSource.sms,
      ),
      Transaction(
        date: today.subtract(const Duration(hours: 5)),
        amount: 20000,
        type: TransactionType.receive,
        operator: Operator.moov,
        counterparty: 'Maman',
        source: TransactionSource.sms,
      ),
    ],
  );
}

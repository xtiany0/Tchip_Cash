import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample/sample_data.dart';
import '../domain/home_summary.dart';

/// Which maquette state the sample data shows. Debug builds cycle it with a
/// long press on the plan card.
final sampleScenarioProvider =
    NotifierProvider<SampleScenarioNotifier, SampleScenario>(
      SampleScenarioNotifier.new,
    );

class SampleScenarioNotifier extends Notifier<SampleScenario> {
  @override
  SampleScenario build() => SampleScenario.ok;

  void next() => state =
      SampleScenario.values[(state.index + 1) % SampleScenario.values.length];
}

/// Clock, overridable in tests.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Home data. Sample data for now; reads SQLite from week 2.
final homeSummaryProvider = Provider<HomeSummary>((ref) {
  final now = ref.watch(nowProvider)();
  return sampleHomeSummary(now, ref.watch(sampleScenarioProvider));
});

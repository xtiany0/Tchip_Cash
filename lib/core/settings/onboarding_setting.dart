import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'language_setting.dart';

/// Whether the welcome screen was completed, and whether the user chose to
/// let Tchip read operator SMS.
class OnboardingState {
  const OnboardingState({required this.done, required this.smsEnabled});

  final bool done;
  final bool smsEnabled;
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  static const _doneKey = 'onboarding_done';
  static const _smsKey = 'sms_enabled';

  @override
  OnboardingState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return OnboardingState(
      done: prefs.getBool(_doneKey) ?? false,
      smsEnabled: prefs.getBool(_smsKey) ?? false,
    );
  }

  Future<void> complete({required bool smsEnabled}) async {
    state = OnboardingState(done: true, smsEnabled: smsEnabled);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_smsKey, smsEnabled);
    await prefs.setBool(_doneKey, true);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

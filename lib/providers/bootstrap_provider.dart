import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads everything the home screen needs before leaving the splash.
/// For now it only simulates the load; the SQLite opening and SMS import
/// replace this delay in week 2.
final bootstrapProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 2600));
});

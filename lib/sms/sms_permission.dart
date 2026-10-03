import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum SmsPermissionResult {
  granted,
  denied,

  /// Denied with "don't ask again", or blocked by policy: only the system
  /// settings can turn it back on.
  blocked,
}

/// Wraps permission_handler so widgets can be tested without a platform.
class SmsPermission {
  const SmsPermission();

  Future<SmsPermissionResult> request() async {
    final status = await Permission.sms.request();
    return _map(status);
  }

  Future<SmsPermissionResult> status() async =>
      _map(await Permission.sms.status);

  Future<bool> openSystemSettings() => openAppSettings();

  static SmsPermissionResult _map(PermissionStatus s) {
    if (s.isGranted || s.isLimited) return SmsPermissionResult.granted;
    if (s.isPermanentlyDenied || s.isRestricted) {
      return SmsPermissionResult.blocked;
    }
    return SmsPermissionResult.denied;
  }
}

final smsPermissionProvider = Provider<SmsPermission>(
  (ref) => const SmsPermission(),
);

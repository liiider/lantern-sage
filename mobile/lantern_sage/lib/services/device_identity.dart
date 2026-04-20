import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentityStore {
  static const _deviceIdKey = 'lantern_sage_device_id';

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = _newDeviceId();
    await prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  String _newDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return 'guest-$hex';
  }
}

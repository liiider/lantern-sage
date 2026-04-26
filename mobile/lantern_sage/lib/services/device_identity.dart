import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentityStore {
  static const _deviceIdKey = 'lantern_sage_device_id';
  static const _preferredCityKey = 'lantern_sage_preferred_city';
  static const _preferredTimezoneKey = 'lantern_sage_preferred_timezone';

  Future<bool> hasDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    return existing != null && existing.isNotEmpty;
  }

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

  Future<void> savePreferredLocation({
    required String city,
    required String timezone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferredCityKey, city);
    await prefs.setString(_preferredTimezoneKey, timezone);
  }

  Future<({String city, String timezone})> getPreferredLocation({
    required String defaultCity,
    required String defaultTimezone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString(_preferredCityKey);
    final timezone = prefs.getString(_preferredTimezoneKey);
    return (
      city: city != null && city.isNotEmpty ? city : defaultCity,
      timezone:
          timezone != null && timezone.isNotEmpty ? timezone : defaultTimezone,
    );
  }

  String _newDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final hex =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return 'guest-$hex';
  }
}

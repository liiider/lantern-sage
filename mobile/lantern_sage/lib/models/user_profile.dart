class UserProfile {
  const UserProfile({
    required this.id,
    required this.deviceId,
    required this.city,
    required this.timezone,
    required this.language,
    required this.tier,
    required this.reminderTime,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      city: json['city'] as String? ?? 'Shanghai',
      timezone: json['timezone'] as String? ?? 'Asia/Shanghai',
      language: json['language'] as String? ?? 'en',
      tier: json['tier'] as String? ?? 'free',
      reminderTime: json['reminder_time'] as String? ?? '20:00',
    );
  }

  final String id;
  final String deviceId;
  final String city;
  final String timezone;
  final String language;
  final String tier;
  final String reminderTime;

  UserProfile copyWith({
    String? city,
    String? timezone,
    String? reminderTime,
  }) {
    return UserProfile(
      id: id,
      deviceId: deviceId,
      city: city ?? this.city,
      timezone: timezone ?? this.timezone,
      language: language,
      tier: tier,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

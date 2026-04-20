class ImportantDateGuidance {
  const ImportantDateGuidance({
    required this.targetDate,
    required this.eventType,
    required this.city,
    required this.timezone,
    required this.lunarDate,
    required this.solarTerm,
    required this.dayGanzhi,
    required this.dayQuality,
    required this.summary,
    required this.bestWindow,
    required this.cautionWindow,
    required this.goodFor,
    required this.avoid,
    required this.practicalTip,
  });

  factory ImportantDateGuidance.fromJson(Map<String, dynamic> json) {
    return ImportantDateGuidance(
      targetDate: json['target_date'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'general',
      city: json['city'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
      lunarDate: json['lunar_date'] as String? ?? '',
      solarTerm: json['solar_term'] as String? ?? '',
      dayGanzhi: json['day_ganzhi'] as String? ?? '',
      dayQuality: json['day_quality'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      bestWindow: json['best_window'] as String? ?? '',
      cautionWindow: json['caution_window'] as String? ?? '',
      goodFor: _stringList(json['good_for']),
      avoid: _stringList(json['avoid']),
      practicalTip: json['practical_tip'] as String? ?? '',
    );
  }

  final String targetDate;
  final String eventType;
  final String city;
  final String timezone;
  final String lunarDate;
  final String solarTerm;
  final String dayGanzhi;
  final String dayQuality;
  final String summary;
  final String bestWindow;
  final String cautionWindow;
  final List<String> goodFor;
  final List<String> avoid;
  final String practicalTip;

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<String>().toList();
  }
}

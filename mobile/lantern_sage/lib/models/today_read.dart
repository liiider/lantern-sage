class TodayRead {
  const TodayRead({
    required this.dateLabel,
    required this.lunarLabel,
    required this.title,
    required this.practicalTip,
    required this.goodFor,
    required this.avoid,
    required this.bestTime,
    required this.avoidTime,
    required this.compass,
    this.feedbackSubmitted = false,
  });

  factory TodayRead.fromJson(Map<String, dynamic> json, String dateLabel) {
    final compassJson = json['compass_directions'];
    final compassItems = compassJson is List
        ? compassJson
            .whereType<Map<String, dynamic>>()
            .map(CompassItem.fromJson)
            .toList()
        : const <CompassItem>[];

    return TodayRead(
      dateLabel: dateLabel,
      lunarLabel: _joinLabelParts([
        json['lunar_date'] as String?,
        json['solar_term'] as String?,
      ]),
      title: json['today_message'] as String? ?? '',
      practicalTip: json['practical_tip'] as String? ?? '',
      goodFor: _stringList(json['good_for']),
      avoid: _stringList(json['avoid']),
      bestTime: json['best_outgoing_time'] as String? ?? '',
      avoidTime: json['avoid_time'] as String? ?? '',
      compass: compassItems,
      feedbackSubmitted: json['feedback_submitted'] as bool? ?? false,
    );
  }

  final String dateLabel;
  final String lunarLabel;
  final String title;
  final String practicalTip;
  final List<String> goodFor;
  final List<String> avoid;
  final String bestTime;
  final String avoidTime;
  final List<CompassItem> compass;
  final bool feedbackSubmitted;
}

class CompassItem {
  const CompassItem({
    required this.direction,
    required this.label,
    required this.quality,
  });

  factory CompassItem.fromJson(Map<String, dynamic> json) {
    return CompassItem(
      direction: json['direction'] as String? ?? '',
      label: json['label'] as String? ?? '',
      quality: json['quality'] as String? ?? '',
    );
  }

  final String direction;
  final String label;
  final String quality;
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<String>().toList();
}

String _joinLabelParts(List<String?> parts) {
  return parts.where((part) => part != null && part.trim().isNotEmpty).join('  ');
}

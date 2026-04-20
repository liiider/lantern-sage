class HistoryEntry {
  const HistoryEntry({
    required this.date,
    required this.dayOfWeek,
    required this.message,
    required this.goodForSummary,
    required this.avoidSummary,
    required this.askCount,
    this.bestWindow,
    this.avoidWindow,
    this.feedback,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      date: json['date'] as String? ?? '',
      dayOfWeek: json['day_of_week'] as String? ?? '',
      message: json['today_message'] as String? ?? '',
      goodForSummary: json['good_for_summary'] as String? ?? '',
      avoidSummary: json['avoid_summary'] as String? ?? '',
      bestWindow: json['best_window'] as String?,
      avoidWindow: json['avoid_window'] as String?,
      feedback: json['feedback'] as String?,
      askCount: json['ask_count'] as int? ?? 0,
    );
  }

  final String date;
  final String dayOfWeek;
  final String message;
  final String goodForSummary;
  final String avoidSummary;
  final String? bestWindow;
  final String? avoidWindow;
  final String? feedback;
  final int askCount;
}

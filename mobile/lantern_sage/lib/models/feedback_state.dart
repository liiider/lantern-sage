class FeedbackState {
  const FeedbackState({
    required this.date,
    required this.submitted,
    this.rating,
  });

  factory FeedbackState.fromJson(Map<String, dynamic> json) {
    return FeedbackState(
      date: json['date'] as String? ?? '',
      submitted: json['submitted'] as bool? ?? false,
      rating: json['rating'] as String?,
    );
  }

  final String date;
  final bool submitted;
  final String? rating;
}

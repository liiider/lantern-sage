class AskQuestion {
  const AskQuestion({
    required this.type,
    required this.text,
    this.hint = '',
    this.available = true,
  });

  factory AskQuestion.fromJson(Map<String, dynamic> json) {
    return AskQuestion(
      type: json['type'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      available: json['available'] as bool? ?? true,
    );
  }

  final int type;
  final String text;
  final String hint;
  final bool available;
}

class AskAnswer {
  const AskAnswer({
    required this.shortAnswer,
    required this.recommendedTime,
    required this.caution,
    required this.reason,
  });

  factory AskAnswer.fromJson(Map<String, dynamic> json) {
    return AskAnswer(
      shortAnswer: json['short_answer'] as String? ?? '',
      recommendedTime: json['recommended_time_window'] as String? ?? '',
      caution: json['caution'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }

  final String shortAnswer;
  final String recommendedTime;
  final String caution;
  final String reason;
}

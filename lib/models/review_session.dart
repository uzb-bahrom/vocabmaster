class ReviewSession {
  final int? id;
  final String date;
  final String mode;
  final int totalWords;
  final int correctCount;
  final int durationSeconds;

  ReviewSession({
    this.id,
    required this.date,
    required this.mode,
    required this.totalWords,
    required this.correctCount,
    required this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mode': mode,
      'total_words': totalWords,
      'correct_count': correctCount,
      'duration_seconds': durationSeconds,
    };
  }

  factory ReviewSession.fromMap(Map<String, dynamic> map) {
    return ReviewSession(
      id: map['id'],
      date: map['date'],
      mode: map['mode'],
      totalWords: map['total_words'],
      correctCount: map['correct_count'],
      durationSeconds: map['duration_seconds'],
    );
  }
}

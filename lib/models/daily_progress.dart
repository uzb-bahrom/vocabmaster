class DailyProgress {
  final int? id;
  final String date;
  final int wordsAdded;
  final int wordsReviewed;
  final int streakDay;

  DailyProgress({
    this.id,
    required this.date,
    this.wordsAdded = 0,
    this.wordsReviewed = 0,
    this.streakDay = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'words_added': wordsAdded,
      'words_reviewed': wordsReviewed,
      'streak_day': streakDay,
    };
  }

  factory DailyProgress.fromMap(Map<String, dynamic> map) {
    return DailyProgress(
      id: map['id'],
      date: map['date'],
      wordsAdded: map['words_added'] ?? 0,
      wordsReviewed: map['words_reviewed'] ?? 0,
      streakDay: map['streak_day'] ?? 0,
    );
  }
}

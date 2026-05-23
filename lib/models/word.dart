class Word {
  final int? id;
  final String english;
  final String uzbek;
  final String? pronunciation;
  final String? example;
  final String difficulty;
  final String? category;
  final int masteryLevel;
  final String addedDate;
  final String nextReviewDate;
  final int reviewCount;

  Word({
    this.id,
    required this.english,
    required this.uzbek,
    this.pronunciation,
    this.example,
    this.difficulty = 'medium',
    this.category,
    this.masteryLevel = 0,
    required this.addedDate,
    required this.nextReviewDate,
    this.reviewCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'uzbek': uzbek,
      'pronunciation': pronunciation,
      'example': example,
      'difficulty': difficulty,
      'category': category,
      'mastery_level': masteryLevel,
      'added_date': addedDate,
      'next_review_date': nextReviewDate,
      'review_count': reviewCount,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      english: map['english'],
      uzbek: map['uzbek'],
      pronunciation: map['pronunciation'],
      example: map['example'],
      difficulty: map['difficulty'] ?? 'medium',
      category: map['category'],
      masteryLevel: map['mastery_level'] ?? 0,
      addedDate: map['added_date'],
      nextReviewDate: map['next_review_date'],
      reviewCount: map['review_count'] ?? 0,
    );
  }

  Word copyWith({
    int? id,
    String? english,
    String? uzbek,
    String? pronunciation,
    String? example,
    String? difficulty,
    String? category,
    int? masteryLevel,
    String? addedDate,
    String? nextReviewDate,
    int? reviewCount,
  }) {
    return Word(
      id: id ?? this.id,
      english: english ?? this.english,
      uzbek: uzbek ?? this.uzbek,
      pronunciation: pronunciation ?? this.pronunciation,
      example: example ?? this.example,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      addedDate: addedDate ?? this.addedDate,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

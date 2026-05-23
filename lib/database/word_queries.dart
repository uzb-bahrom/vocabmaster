import 'package:sqflite/sqflite.dart';
import '../models/word.dart';
import 'database_helper.dart';

class WordQueries {
  final DatabaseHelper _db = DatabaseHelper();

  Future<int> insertWord(Word word) async {
    final db = await _db.database;
    return await db.insert('words', word.toMap());
  }

  Future<List<Word>> getAllWords({String? search}) async {
    final db = await _db.database;
    if (search != null && search.isNotEmpty) {
      final maps = await db.query(
        'words',
        where: 'english LIKE ? OR uzbek LIKE ?',
        whereArgs: ['%$search%', '%$search%'],
        orderBy: 'added_date DESC',
      );
      return maps.map((m) => Word.fromMap(m)).toList();
    }
    final maps = await db.query('words', orderBy: 'added_date DESC');
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  Future<List<Word>> getWordsForReview({int limit = 20, int offset = 0}) async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.query(
      'words',
      where: 'next_review_date <= ? AND mastery_level < 5',
      whereArgs: [today],
      orderBy: 'mastery_level ASC, next_review_date ASC',
      limit: limit,
      offset: offset,
    );
    if (maps.length < limit) {
      final extra = await db.query(
        'words',
        where: 'mastery_level < 5',
        orderBy: 'RANDOM()',
        limit: limit - maps.length,
      );
      return [...maps, ...extra].map((m) => Word.fromMap(m)).toList();
    }
    return maps.map((m) => Word.fromMap(m)).toList();
  }

  Future<void> updateWordMastery(int id, bool correct) async {
    final db = await _db.database;
    final maps = await db.query('words', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return;

    final word = Word.fromMap(maps.first);
    int newMastery = (word.masteryLevel + (correct ? 1 : -1)).clamp(0, 5);
    final nextReview = DateTime.now()
        .add(Duration(days: newMastery == 0 ? 1 : newMastery * 2))
        .toIso8601String()
        .substring(0, 10);

    await db.update(
      'words',
      {
        'mastery_level': newMastery,
        'next_review_date': nextReview,
        'review_count': word.reviewCount + 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWord(int id) async {
    final db = await _db.database;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getStats() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words')) ?? 0;
    final mastered = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words WHERE mastery_level = 5')) ?? 0;
    final addedToday = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM words WHERE added_date = '$today'")) ?? 0;
    final dueToday = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM words WHERE next_review_date <= '$today' AND mastery_level < 5")) ?? 0;
    return {'total': total, 'mastered': mastered, 'addedToday': addedToday, 'dueToday': dueToday};
  }

  Future<List<Word>> getRandomWords(int count, {int? excludeId}) async {
    final db = await _db.database;
    final maps = await db.query(
      'words',
      where: excludeId != null ? 'id != ?' : null,
      whereArgs: excludeId != null ? [excludeId] : null,
      orderBy: 'RANDOM()',
      limit: count,
    );
    return maps.map((m) => Word.fromMap(m)).toList();
  }
}

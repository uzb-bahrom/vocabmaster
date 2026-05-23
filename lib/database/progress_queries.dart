import '../models/daily_progress.dart';
import 'database_helper.dart';

class ProgressQueries {
  final DatabaseHelper _db = DatabaseHelper();

  Future<DailyProgress> getTodayProgress() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final maps = await db.query('daily_progress', where: 'date = ?', whereArgs: [today]);
    if (maps.isEmpty) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
      final yMaps = await db.query('daily_progress', where: 'date = ?', whereArgs: [yesterday]);
      int streak = yMaps.isNotEmpty ? DailyProgress.fromMap(yMaps.first).streakDay : 0;
      final progress = DailyProgress(date: today, streakDay: streak);
      await db.insert('daily_progress', progress.toMap());
      return progress;
    }
    return DailyProgress.fromMap(maps.first);
  }

  Future<void> incrementWordsAdded() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await db.rawUpdate("UPDATE daily_progress SET words_added = words_added + 1 WHERE date = ?", [today]);
  }

  Future<void> incrementWordsReviewed() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await db.rawUpdate("UPDATE daily_progress SET words_reviewed = words_reviewed + 1 WHERE date = ?", [today]);
  }

  Future<void> incrementStreak() async {
    final db = await _db.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await db.rawUpdate("UPDATE daily_progress SET streak_day = streak_day + 1 WHERE date = ?", [today]);
  }

  Future<List<DailyProgress>> getLastNDays(int n) async {
    final db = await _db.database;
    final maps = await db.query('daily_progress', orderBy: 'date DESC', limit: n);
    return maps.map((m) => DailyProgress.fromMap(m)).toList();
  }
}

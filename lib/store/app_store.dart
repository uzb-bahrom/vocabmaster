import 'package:flutter/material.dart';
import '../models/word.dart';
import '../models/daily_progress.dart';
import '../database/word_queries.dart';
import '../database/progress_queries.dart';

class AppStore extends ChangeNotifier {
  final _wordQ = WordQueries();
  final _progressQ = ProgressQueries();

  List<Word> _words = [];
  DailyProgress? _todayProgress;
  Map<String, int> _stats = {};
  bool _loading = false;

  List<Word> get words => _words;
  DailyProgress? get todayProgress => _todayProgress;
  Map<String, int> get stats => _stats;
  bool get loading => _loading;

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();
    _words = await _wordQ.getAllWords();
    _todayProgress = await _progressQ.getTodayProgress();
    _stats = await _wordQ.getStats();
    _loading = false;
    notifyListeners();
  }

  Future<void> addWord(Word word) async {
    await _wordQ.insertWord(word);
    await _progressQ.incrementWordsAdded();
    await loadAll();
  }

  Future<void> updateMastery(int id, bool correct) async {
    await _wordQ.updateWordMastery(id, correct);
    await _progressQ.incrementWordsReviewed();
    notifyListeners();
  }

  Future<void> deleteWord(int id) async {
    await _wordQ.deleteWord(id);
    await loadAll();
  }

  Future<List<Word>> getSessionWords() => _wordQ.getWordsForReview(limit: 20);

  Future<List<Word>> getRandomOptions(int count, {int? excludeId}) =>
      _wordQ.getRandomWords(count, excludeId: excludeId);

  Future<List<Word>> searchWords(String q) => _wordQ.getAllWords(search: q);
}

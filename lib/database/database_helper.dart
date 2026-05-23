import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vocabmaster.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        uzbek TEXT NOT NULL,
        pronunciation TEXT,
        example TEXT,
        difficulty TEXT DEFAULT 'medium',
        category TEXT,
        mastery_level INTEGER DEFAULT 0,
        added_date TEXT NOT NULL,
        next_review_date TEXT NOT NULL,
        review_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE review_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        mode TEXT NOT NULL,
        total_words INTEGER NOT NULL,
        correct_count INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        words_added INTEGER DEFAULT 0,
        words_reviewed INTEGER DEFAULT 0,
        streak_day INTEGER DEFAULT 0
      )
    ''');
  }
}

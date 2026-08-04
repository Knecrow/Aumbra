import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/quest_model.dart';
import '../models/history_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aumbra.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        name TEXT,
        career TEXT,
        interests TEXT,
        fitness_level INTEGER,
        daily_time TEXT,
        has_computer INTEGER,
        current_rank INTEGER DEFAULT 1,
        current_streak INTEGER DEFAULT 0,
        integrity_streak INTEGER DEFAULT 0,
        rank_completions INTEGER DEFAULT 0,
        shields_remaining INTEGER DEFAULT 3,
        shields_last_reset INTEGER,
        recent_quest_history TEXT,
        total_quests_completed INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        start_date INTEGER,
        total_xp INTEGER DEFAULT 0,
        unlocked_badges TEXT,
        unlocked_titles TEXT,
        aura_color TEXT DEFAULT '#FFD700',
        cloud_backup_enabled INTEGER DEFAULT 1,
        had_broken_streak INTEGER DEFAULT 0,
        phoenix_streak_before_break INTEGER DEFAULT 0
      )
    ''');

    // History table
    await db.execute('''
      CREATE TABLE history (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        quest_title TEXT,
        quest_category TEXT,
        completed_date INTEGER,
        rank_at_time TEXT
      )
    ''');

    // Quest cache table
    await db.execute('''
      CREATE TABLE quest_cache (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        category TEXT,
        is_completed INTEGER DEFAULT 0,
        date TEXT,
        is_boss_quest INTEGER DEFAULT 0
      )
    ''');

    // Streak history table (for chart)
    await db.execute('''
      CREATE TABLE streak_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        streak_value INTEGER,
        all_completed INTEGER DEFAULT 0
      )
    ''');
  }

  // ─── USER CRUD ──────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String uid) async {
    final db = await database;
    final maps = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getFirstUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  Future<void> deleteUser(String uid) async {
    final db = await database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
    await db.delete('history', where: 'user_id = ?', whereArgs: [uid]);
    await db.delete('quest_cache', where: '1=1');
    await db.delete('streak_history', where: '1=1');
  }

  // ─── QUEST CACHE CRUD ────────────────────────────────────────────────────

  Future<void> cacheQuests(List<QuestModel> quests) async {
    final db = await database;
    final batch = db.batch();
    for (final quest in quests) {
      batch.insert('quest_cache', quest.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<QuestModel>> getCachedQuests(String date) async {
    final db = await database;
    final maps = await db.query('quest_cache', where: 'date = ?', whereArgs: [date]);
    return maps.map((m) => QuestModel.fromMap(m)).toList();
  }

  Future<void> updateQuestCompletion(String questId, bool isCompleted) async {
    final db = await database;
    await db.update(
      'quest_cache',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [questId],
    );
  }

  Future<void> clearOldQuestCache(String keepDate) async {
    final db = await database;
    await db.delete('quest_cache', where: 'date != ?', whereArgs: [keepDate]);
  }

  // ─── HISTORY CRUD ────────────────────────────────────────────────────────

  Future<void> insertHistory(HistoryEntry entry) async {
    final db = await database;
    await db.insert('history', entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HistoryEntry>> getHistory(String userId) async {
    final db = await database;
    final maps = await db.query(
      'history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_date DESC',
    );
    return maps.map((m) => HistoryEntry.fromMap(m)).toList();
  }

  Future<HistoryEntry?> getFirstHistoryEntry(String userId) async {
    final db = await database;
    final maps = await db.query(
      'history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_date ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HistoryEntry.fromMap(maps.first);
  }

  Future<Map<String, int>> getCategoryBreakdown(String userId) async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT quest_category, COUNT(*) as count FROM history WHERE user_id = ? GROUP BY quest_category',
      [userId],
    );
    final result = <String, int>{};
    for (final m in maps) {
      result[m['quest_category'] as String] = m['count'] as int;
    }
    return result;
  }

  // ─── STREAK HISTORY ──────────────────────────────────────────────────────

  Future<void> recordDayCompletion(String date, int streakValue, bool allCompleted) async {
    final db = await database;
    await db.insert(
      'streak_history',
      {'date': date, 'streak_value': streakValue, 'all_completed': allCompleted ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getStreakHistory(int days) async {
    final db = await database;
    return await db.query(
      'streak_history',
      orderBy: 'date ASC',
      limit: days,
    );
  }

  Future<List<Map<String, dynamic>>> getCompletionHeatmap() async {
    final db = await database;
    return await db.query(
      'streak_history',
      orderBy: 'date ASC',
    );
  }

  // ─── FULL DATA EXPORT ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> exportAllData(String userId) async {
    final user = await getUser(userId);
    final history = await getHistory(userId);
    return {
      'user': user?.toMap(),
      'history': history.map((h) => h.toMap()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}

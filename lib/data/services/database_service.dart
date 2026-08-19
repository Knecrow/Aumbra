import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/quest_model.dart';
import '../models/history_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  sql.Database? _database;

  // ─── SQLITE (NATIVE) ──────────────────────────────────────────────────────
  Future<sql.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final path = join(dbPath, 'aumbra.db');

    return await sql.openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async {
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

  // ─── WEB STORAGE FALLBACK (SharedPreferences) ────────────────────────────
  static const String _webUsersKey = 'web_users_store';
  static const String _webHistoryKey = 'web_history_store';
  static const String _webQuestCacheKey = 'web_quest_cache_store';
  static const String _webStreakKey = 'web_streak_store';

  Future<SharedPreferences> get _webPrefs => SharedPreferences.getInstance();

  Future<Map<String, dynamic>> _getWebMap(String key) async {
    final prefs = await _webPrefs;
    final jsonStr = prefs.getString(key);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveWebMap(String key, Map<String, dynamic> data) async {
    final prefs = await _webPrefs;
    await prefs.setString(key, jsonEncode(data));
  }

  // ─── USER CRUD ──────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webUsersKey);
      map[user.uid] = user.toMap();
      await _saveWebMap(_webUsersKey, map);
      return;
    }
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(String uid) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webUsersKey);
      final raw = map[uid];
      if (raw == null) return null;
      return UserModel.fromMap(Map<String, dynamic>.from(raw as Map));
    }
    final db = await database;
    final maps = await db.query('users', where: 'uid = ?', whereArgs: [uid]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getFirstUser() async {
    if (kIsWeb) {
      final map = await _getWebMap(_webUsersKey);
      if (map.isEmpty) return null;
      final raw = map.values.first;
      return UserModel.fromMap(Map<String, dynamic>.from(raw as Map));
    }
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<void> updateUser(UserModel user) async {
    if (kIsWeb) {
      await saveUser(user);
      return;
    }
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'uid = ?',
      whereArgs: [user.uid],
    );
  }

  Future<void> deleteUser(String uid) async {
    if (kIsWeb) {
      final prefs = await _webPrefs;
      await prefs.remove(_webUsersKey);
      await prefs.remove(_webHistoryKey);
      await prefs.remove(_webQuestCacheKey);
      await prefs.remove(_webStreakKey);
      return;
    }
    final db = await database;
    await db.delete('users', where: 'uid = ?', whereArgs: [uid]);
    await db.delete('history', where: 'user_id = ?', whereArgs: [uid]);
    await db.delete('quest_cache', where: '1=1');
    await db.delete('streak_history', where: '1=1');
  }

  // ─── QUEST CACHE CRUD ────────────────────────────────────────────────────

  Future<void> cacheQuests(List<QuestModel> quests) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webQuestCacheKey);
      for (final quest in quests) {
        map[quest.id] = quest.toMap();
      }
      await _saveWebMap(_webQuestCacheKey, map);
      return;
    }
    final db = await database;
    final batch = db.batch();
    for (final quest in quests) {
      batch.insert('quest_cache', quest.toMap(),
          conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<QuestModel>> getCachedQuests(String date) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webQuestCacheKey);
      return map.values
          .map((m) => QuestModel.fromMap(Map<String, dynamic>.from(m as Map)))
          .where((q) => q.date == date)
          .toList();
    }
    final db = await database;
    final maps = await db.query('quest_cache', where: 'date = ?', whereArgs: [date]);
    return maps.map((m) => QuestModel.fromMap(m)).toList();
  }

  Future<void> updateQuestCompletion(String questId, bool isCompleted) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webQuestCacheKey);
      if (map.containsKey(questId)) {
        final qMap = Map<String, dynamic>.from(map[questId] as Map);
        qMap['is_completed'] = isCompleted ? 1 : 0;
        map[questId] = qMap;
        await _saveWebMap(_webQuestCacheKey, map);
      }
      return;
    }
    final db = await database;
    await db.update(
      'quest_cache',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [questId],
    );
  }

  Future<void> clearOldQuestCache(String keepDate) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webQuestCacheKey);
      map.removeWhere((key, value) => (value as Map)['date'] != keepDate);
      await _saveWebMap(_webQuestCacheKey, map);
      return;
    }
    final db = await database;
    await db.delete('quest_cache', where: 'date != ?', whereArgs: [keepDate]);
  }

  // ─── HISTORY CRUD ────────────────────────────────────────────────────────

  Future<void> insertHistory(HistoryEntry entry) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webHistoryKey);
      map[entry.id] = entry.toMap();
      await _saveWebMap(_webHistoryKey, map);
      return;
    }
    final db = await database;
    await db.insert('history', entry.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  Future<List<HistoryEntry>> getHistory(String userId) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webHistoryKey);
      final list = map.values
          .map((m) => HistoryEntry.fromMap(Map<String, dynamic>.from(m as Map)))
          .where((h) => h.userId == userId)
          .toList();
      list.sort((a, b) => b.completedDate.compareTo(a.completedDate));
      return list;
    }
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
    if (kIsWeb) {
      final list = await getHistory(userId);
      if (list.isEmpty) return null;
      list.sort((a, b) => a.completedDate.compareTo(b.completedDate));
      return list.first;
    }
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
    if (kIsWeb) {
      final list = await getHistory(userId);
      final result = <String, int>{};
      for (final h in list) {
        result[h.questCategory] = (result[h.questCategory] ?? 0) + 1;
      }
      return result;
    }
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
    if (kIsWeb) {
      final map = await _getWebMap(_webStreakKey);
      map[date] = {
        'date': date,
        'streak_value': streakValue,
        'all_completed': allCompleted ? 1 : 0,
      };
      await _saveWebMap(_webStreakKey, map);
      return;
    }
    final db = await database;
    await db.insert(
      'streak_history',
      {'date': date, 'streak_value': streakValue, 'all_completed': allCompleted ? 1 : 0},
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getStreakHistory(int days) async {
    if (kIsWeb) {
      final map = await _getWebMap(_webStreakKey);
      final list = map.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();
      list.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
      return list.length > days ? list.sublist(list.length - days) : list;
    }
    final db = await database;
    return await db.query(
      'streak_history',
      orderBy: 'date ASC',
      limit: days,
    );
  }

  Future<List<Map<String, dynamic>>> getCompletionHeatmap() async {
    if (kIsWeb) {
      final map = await _getWebMap(_webStreakKey);
      final list = map.values.map((v) => Map<String, dynamic>.from(v as Map)).toList();
      list.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
      return list;
    }
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

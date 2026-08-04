import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/models/history_entry.dart';
import '../../data/services/database_service.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/constants/ranks.dart';
import '../../core/constants/badges.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;
  final FirebaseService _firebase;
  final LocalStorageService _localStorage;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  RankInfo get currentRankInfo => getRankInfo(_user?.currentRank ?? 1);
  RankInfo? get nextRankInfo => getNextRank(_user?.currentRank ?? 1);

  UserProvider({
    required DatabaseService db,
    required FirebaseService firebase,
    required LocalStorageService localStorage,
  })  : _db = db,
        _firebase = firebase,
        _localStorage = localStorage;

  // ─── LOAD USER ───────────────────────────────────────────────────────────

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _db.getFirstUser();

      if (_user != null) {
        // Reset shields if new month
        _user = _checkShieldReset(_user!);
        await _db.updateUser(_user!);

        // Try to pull from cloud if signed in
        if (_firebase.isSignedIn && _user!.cloudBackupEnabled) {
          final cloudUser = await _firebase.pullFromCloud(_user!.uid);
          if (cloudUser != null) {
            // Merge: take higher progression values
            _user = _mergeWithCloud(_user!, cloudUser);
            await _db.updateUser(_user!);
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── SAVE / CREATE USER ──────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    _user = user;
    await _db.saveUser(user);
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _user = user;
    await _db.updateUser(user);
    await _syncToCloud();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? career,
    String? interests,
    int? fitnessLevel,
    String? dailyTime,
    bool? hasComputer,
  }) async {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      career: career,
      interests: interests,
      fitnessLevel: fitnessLevel,
      dailyTime: dailyTime,
      hasComputer: hasComputer,
    );
    await _db.updateUser(_user!);
    await _syncToCloud();
    notifyListeners();
  }

  // ─── QUEST COMPLETION ────────────────────────────────────────────────────

  /// Called when user completes all quests + oath in a day
  Future<bool> recordDayComplete({
    required bool oathAnswer,
    required List<String> completedQuestTitles,
  }) async {
    if (_user == null) return false;

    var user = _user!;
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Update streaks
    int newStreak = user.currentStreak + 1;
    int newIntegrityStreak = oathAnswer ? user.integrityStreak + 1 : 0;
    int newCompletions = user.rankCompletions + 1;
    int newTotalQuests = user.totalQuestsCompleted + completedQuestTitles.length;
    int newLongestStreak = newStreak > user.longestStreak ? newStreak : user.longestStreak;
    int newXp = user.totalXp + (completedQuestTitles.length * 100);

    // Update quest history (last 7)
    final newHistory = [...user.recentQuestHistory, ...completedQuestTitles];
    final trimmedHistory =
        newHistory.length > 7 ? newHistory.sublist(newHistory.length - 7) : newHistory;

    user = user.copyWith(
      currentStreak: newStreak,
      integrityStreak: newIntegrityStreak,
      rankCompletions: newCompletions,
      totalQuestsCompleted: newTotalQuests,
      longestStreak: newLongestStreak,
      totalXp: newXp,
      recentQuestHistory: trimmedHistory,
    );

    // Check and unlock badges/titles
    user = _checkBadgesAndTitles(user);

    // Record streak history
    await _db.recordDayCompletion(dateStr, newStreak, true);

    _user = user;
    await _db.updateUser(user);
    await _syncToCloud();
    notifyListeners();

    // Check if rank-up conditions are met
    return _checkRankUpReady(user);
  }

  bool _checkRankUpReady(UserModel user) {
    if (user.currentRank >= 15) return false;
    final rank = getRankInfo(user.currentRank);
    return user.rankCompletions >= rank.completionsRequired &&
        user.currentStreak >= rank.streakRequired;
  }

  bool get isRankUpReady {
    if (_user == null || _user!.currentRank >= 15) return false;
    return _checkRankUpReady(_user!);
  }

  // ─── RANK UP ─────────────────────────────────────────────────────────────

  Future<void> performRankUp() async {
    if (_user == null || _user!.currentRank >= 15) return;

    final newRank = _user!.currentRank + 1;
    _user = _user!.copyWith(
      currentRank: newRank,
      currentStreak: 0,
      rankCompletions: 0,
    );

    // Check rank-based badges
    _user = _checkBadgesAndTitles(_user!);

    await _db.updateUser(_user!);
    await _syncToCloud();
    notifyListeners();
  }

  // ─── SHIELD USAGE ────────────────────────────────────────────────────────

  Future<bool> useShield() async {
    if (_user == null || _user!.shieldsRemaining <= 0) return false;

    _user = _user!.copyWith(
      shieldsRemaining: _user!.shieldsRemaining - 1,
      currentStreak: _user!.currentStreak, // preserve streak
    );

    await _db.updateUser(_user!);
    await _syncToCloud();
    notifyListeners();
    return true;
  }

  /// Called when user misses a day (no shield used)
  Future<void> breakStreak() async {
    if (_user == null) return;

    final hadLongStreak = _user!.currentStreak >= 30;
    _user = _user!.copyWith(
      currentStreak: 0,
      rankCompletions: 0,
      hadBrokenStreak: hadLongStreak ? true : _user!.hadBrokenStreak,
      phoenixStreakBeforeBreak: hadLongStreak ? _user!.currentStreak : _user!.phoenixStreakBeforeBreak,
    );

    await _db.updateUser(_user!);
    await _syncToCloud();
    notifyListeners();
  }

  // ─── AURA COLOR ──────────────────────────────────────────────────────────

  Future<void> setAuraColor(Color color) async {
    if (_user == null || _user!.currentRank < 15) return;
    final r = (color.r * 255.0).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().toRadixString(16).padLeft(2, '0');
    final hex = '#$r$g$b';
    _user = _user!.copyWith(auraColor: hex);
    await _db.updateUser(_user!);
    await _syncToCloud();
    notifyListeners();
  }

  Color get currentRankColor {
    if (_user == null) return const Color(0xFF9E9E9E);
    if (_user!.currentRank == 15 && _user!.auraColor.isNotEmpty) {
      try {
        final hex = _user!.auraColor.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return currentRankInfo.color;
  }

  // ─── HISTORY ─────────────────────────────────────────────────────────────

  Future<void> addHistoryEntry(HistoryEntry entry) async {
    await _db.insertHistory(entry);
    if (_firebase.isSignedIn && (_user?.cloudBackupEnabled ?? false)) {
      await _firebase.saveHistoryEntry(entry);
    }
    notifyListeners();
  }

  Future<List<HistoryEntry>> getHistory() async {
    if (_user == null) return [];
    return await _db.getHistory(_user!.uid);
  }

  Future<Map<String, int>> getCategoryBreakdown() async {
    if (_user == null) return {};
    return await _db.getCategoryBreakdown(_user!.uid);
  }

  Future<List<Map<String, dynamic>>> getStreakHistory() async {
    return await _db.getStreakHistory(180); // last 6 months
  }

  Future<List<Map<String, dynamic>>> getHeatmapData() async {
    return await _db.getCompletionHeatmap();
  }

  // ─── SIGN OUT / DELETE ────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _firebase.signOut();
    await _localStorage.clearCurrentUserId();
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    if (_user == null) return;
    final uid = _user!.uid;
    await _db.deleteUser(uid);
    await _firebase.deleteUserFromFirestore(uid);
    await _localStorage.clearAll();
    _user = null;
    notifyListeners();
  }

  Future<void> toggleCloudBackup(bool enabled) async {
    if (_user == null) return;
    _user = _user!.copyWith(cloudBackupEnabled: enabled);
    await _db.updateUser(_user!);
    notifyListeners();
  }

  // ─── BADGE / TITLE LOGIC ─────────────────────────────────────────────────

  UserModel _checkBadgesAndTitles(UserModel user) {
    final badges = List<String>.from(user.unlockedBadges);
    final titles = List<String>.from(user.unlockedTitles);

    void addBadge(String id) {
      if (!badges.contains(id)) badges.add(id);
    }

    void addTitle(String id) {
      if (!titles.contains(id)) titles.add(id);
    }

    // Streak badges
    if (user.currentStreak >= 7) addBadge('first_flame');
    if (user.currentStreak >= 30) addBadge('iron_will');
    if (user.currentStreak >= 100) addBadge('unbreakable');

    // Volume badges
    if (user.totalQuestsCompleted >= 10) addBadge('initiate');
    if (user.totalQuestsCompleted >= 100) addBadge('grinder');
    if (user.totalQuestsCompleted >= 500) addBadge('ascetic');

    // Rank badges
    if (user.currentRank >= 2) addBadge('awakened_one');
    if (user.currentRank >= 8) addBadge('sages_wisdom');
    if (user.currentRank >= 15) addBadge('absolute_god');

    // Integrity badges
    if (user.integrityStreak >= 7) addBadge('the_honest');
    if (user.integrityStreak >= 30) addBadge('true_to_self');

    // Titles
    if (user.totalQuestsCompleted >= 1) addTitle('the_rookie');
    if (user.currentStreak >= 14 || user.longestStreak >= 14) addTitle('the_consistent');
    if (user.currentRank >= 8) addTitle('the_sage');
    if (user.currentRank >= 10) addTitle('the_limitless');
    if (user.currentRank >= 15) addTitle('the_absolute');

    // Phoenix title: had a 30+ day streak, broke it, then rebuilt to 30
    if (user.hadBrokenStreak && user.currentStreak >= 30) {
      addTitle('the_phoenix');
      addTitle('the_unshaken');
    }

    return user.copyWith(
      unlockedBadges: badges,
      unlockedTitles: titles,
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  UserModel _checkShieldReset(UserModel user) {
    final now = DateTime.now();
    final lastReset = user.shieldsLastReset;

    if (lastReset == null ||
        lastReset.month != now.month ||
        lastReset.year != now.year) {
      return user.copyWith(
        shieldsRemaining: 3,
        shieldsLastReset: now,
      );
    }
    return user;
  }

  UserModel _mergeWithCloud(UserModel local, UserModel cloud) {
    // Take the more progressed values
    return local.copyWith(
      currentRank: cloud.currentRank > local.currentRank ? cloud.currentRank : local.currentRank,
      totalQuestsCompleted: cloud.totalQuestsCompleted > local.totalQuestsCompleted
          ? cloud.totalQuestsCompleted
          : local.totalQuestsCompleted,
      longestStreak: cloud.longestStreak > local.longestStreak
          ? cloud.longestStreak
          : local.longestStreak,
      unlockedBadges: {...local.unlockedBadges, ...cloud.unlockedBadges}.toList(),
      unlockedTitles: {...local.unlockedTitles, ...cloud.unlockedTitles}.toList(),
    );
  }

  Future<void> _syncToCloud() async {
    if (_user == null || !_user!.cloudBackupEnabled || !_firebase.isSignedIn) {
      return;
    }
    await _firebase.syncUserToCloud(_user!);
  }

  // ─── EXPORT ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> exportData() async {
    if (_user == null) return {};
    return await _db.exportAllData(_user!.uid);
  }

  String? get currentTitle {
    if (_user == null || _user!.unlockedTitles.isEmpty) return null;
    // Return the most prestigious title
    const titlePriority = [
      'the_absolute',
      'the_phoenix',
      'the_limitless',
      'the_sage',
      'the_unshaken',
      'the_consistent',
      'the_rookie',
    ];
    for (final t in titlePriority) {
      if (_user!.unlockedTitles.contains(t)) {
        final titleInfo = kTitles.firstWhere((ti) => ti.id == t, orElse: () => kTitles.first);
        return titleInfo.name;
      }
    }
    return null;
  }

  int get daysSinceStart {
    if (_user?.startDate == null) return 0;
    return DateTime.now().difference(_user!.startDate!).inDays + 1;
  }

  int get estimatedDaysToAbsolute {
    if (_user == null) return 365;
    if (_user!.currentRank >= 15) return 0;
    // Sum remaining C values
    int remaining = 0;
    for (int i = _user!.currentRank; i < 15; i++) {
      remaining += kRanks[i].completionsRequired;
    }
    // Subtract current completions
    remaining -= _user!.rankCompletions;
    return remaining < 0 ? 0 : remaining;
  }
}

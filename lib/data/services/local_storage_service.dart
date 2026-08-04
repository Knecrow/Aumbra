import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _reduceEffectsKey = 'reduce_effects';
  static const String _currentUserIdKey = 'current_user_id';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _lastQuestDateKey = 'last_quest_date';
  static const String _oathAnsweredTodayKey = 'oath_answered_today';
  static const String _oathAnswerKey = 'oath_answer';
  static const String _bossQuestUnlockedKey = 'boss_quest_unlocked';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── API KEY ──────────────────────────────────────────────────────────────
  Future<void> setGeminiApiKey(String key) async {
    final p = await prefs;
    await p.setString(_apiKeyKey, key);
  }

  Future<String?> getGeminiApiKey() async {
    final p = await prefs;
    return p.getString(_apiKeyKey);
  }

  Future<void> clearGeminiApiKey() async {
    final p = await prefs;
    await p.remove(_apiKeyKey);
  }

  // ─── THEME ────────────────────────────────────────────────────────────────
  Future<void> setDarkMode(bool isDark) async {
    final p = await prefs;
    await p.setBool(_isDarkModeKey, isDark);
  }

  Future<bool> isDarkMode() async {
    final p = await prefs;
    return p.getBool(_isDarkModeKey) ?? true; // default dark
  }

  Future<void> setReduceEffects(bool reduce) async {
    final p = await prefs;
    await p.setBool(_reduceEffectsKey, reduce);
  }

  Future<bool> getReduceEffects() async {
    final p = await prefs;
    return p.getBool(_reduceEffectsKey) ?? false;
  }

  // ─── USER SESSION ─────────────────────────────────────────────────────────
  Future<void> setCurrentUserId(String uid) async {
    final p = await prefs;
    await p.setString(_currentUserIdKey, uid);
  }

  Future<String?> getCurrentUserId() async {
    final p = await prefs;
    return p.getString(_currentUserIdKey);
  }

  Future<void> clearCurrentUserId() async {
    final p = await prefs;
    await p.remove(_currentUserIdKey);
  }

  // ─── ONBOARDING ──────────────────────────────────────────────────────────
  Future<void> setOnboardingComplete(bool complete) async {
    final p = await prefs;
    await p.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final p = await prefs;
    return p.getBool(_onboardingCompleteKey) ?? false;
  }

  // ─── QUEST DATE TRACKING ─────────────────────────────────────────────────
  Future<void> setLastQuestDate(String date) async {
    final p = await prefs;
    await p.setString(_lastQuestDateKey, date);
  }

  Future<String?> getLastQuestDate() async {
    final p = await prefs;
    return p.getString(_lastQuestDateKey);
  }

  // ─── OATH TRACKING ───────────────────────────────────────────────────────
  Future<void> setOathAnsweredToday(bool answered, {bool? answer}) async {
    final p = await prefs;
    await p.setBool(_oathAnsweredTodayKey, answered);
    if (answer != null) {
      await p.setBool(_oathAnswerKey, answer);
    }
  }

  Future<bool> oathAnsweredToday() async {
    final p = await prefs;
    return p.getBool(_oathAnsweredTodayKey) ?? false;
  }

  Future<bool?> getOathAnswer() async {
    final p = await prefs;
    if (!(p.getBool(_oathAnsweredTodayKey) ?? false)) return null;
    return p.getBool(_oathAnswerKey);
  }

  // ─── BOSS QUEST ──────────────────────────────────────────────────────────
  Future<void> setBossQuestUnlocked(bool unlocked) async {
    final p = await prefs;
    await p.setBool(_bossQuestUnlockedKey, unlocked);
  }

  Future<bool> isBossQuestUnlocked() async {
    final p = await prefs;
    return p.getBool(_bossQuestUnlockedKey) ?? false;
  }

  // ─── DAILY RESET ──────────────────────────────────────────────────────────
  Future<void> resetDailyFlags() async {
    final p = await prefs;
    await p.setBool(_oathAnsweredTodayKey, false);
    await p.remove(_oathAnswerKey);
  }

  // ─── CLEAR ALL ───────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    final p = await prefs;
    await p.clear();
  }
}

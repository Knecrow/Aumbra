import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/models/quest_model.dart';
import '../../data/models/history_entry.dart';
import '../../data/services/database_service.dart';
import '../../data/services/gemini_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/constants/ranks.dart';
import './user_provider.dart';

enum QuestLoadingState { idle, loading, loaded, error }

class QuestProvider extends ChangeNotifier {
  final DatabaseService _db;
  final GeminiService _gemini;
  final LocalStorageService _localStorage;
  final UserProvider _userProvider;

  List<QuestModel> _todayQuests = [];
  QuestModel? _bossQuest;
  QuestLoadingState _state = QuestLoadingState.idle;
  bool _oathAnswered = false;
  bool? _oathAnswer;
  bool _bossQuestUnlocked = false;
  bool _bossQuestCompleted = false;
  String? _error;

  List<QuestModel> get todayQuests => _todayQuests;
  QuestModel? get bossQuest => _bossQuest;
  QuestLoadingState get state => _state;
  bool get oathAnswered => _oathAnswered;
  bool? get oathAnswer => _oathAnswer;
  bool get bossQuestUnlocked => _bossQuestUnlocked;
  bool get bossQuestCompleted => _bossQuestCompleted;
  String? get error => _error;

  bool get allQuestsCompleted =>
      _todayQuests.isNotEmpty &&
      _todayQuests.every((q) => q.isCompleted) &&
      _oathAnswered;

  bool get allMainQuestsCompleted =>
      _todayQuests.isNotEmpty && _todayQuests.every((q) => q.isCompleted);

  int get completedCount => _todayQuests.where((q) => q.isCompleted).length;
  int get totalCount => _todayQuests.length;

  QuestProvider({
    required DatabaseService db,
    required GeminiService gemini,
    required LocalStorageService localStorage,
    required UserProvider userProvider,
  })  : _db = db,
        _gemini = gemini,
        _localStorage = localStorage,
        _userProvider = userProvider;

  // ─── LOAD TODAY'S QUESTS ─────────────────────────────────────────────────

  Future<void> loadTodayQuests() async {
    final user = _userProvider.user;
    if (user == null) return;

    _state = QuestLoadingState.loading;
    notifyListeners();

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Check if we already have quests for today in cache
    final cached = await _db.getCachedQuests(today);
    if (cached.isNotEmpty) {
      _todayQuests = cached;
      await _restoreOathState();
      _bossQuestUnlocked = await _localStorage.isBossQuestUnlocked();
      _state = QuestLoadingState.loaded;
      notifyListeners();
      return;
    }

    // Generate new quests
    try {
      final apiKey = await _localStorage.getGeminiApiKey();
      final rankInfo = getRankInfo(user.currentRank);
      final categories = rankInfo.categories;

      final quests = await _gemini.generateQuests(
        apiKey: apiKey,
        taskCount: rankInfo.taskCount,
        career: user.career,
        interests: user.interests,
        fitnessLevel: user.fitnessLevel,
        hasComputer: user.hasComputer,
        rankNumber: user.currentRank,
        recentQuestHistory: user.recentQuestHistory,
        categories: categories,
        date: today,
      );

      // Cache them
      await _db.clearOldQuestCache(today);
      await _db.cacheQuests(quests);

      _todayQuests = quests;
      _state = QuestLoadingState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = QuestLoadingState.error;
    }

    await _restoreOathState();
    notifyListeners();
  }

  // ─── QUEST COMPLETION ────────────────────────────────────────────────────

  Future<void> completeQuest(String questId) async {
    final index = _todayQuests.indexWhere((q) => q.id == questId);
    if (index == -1) return;

    _todayQuests[index] = _todayQuests[index].copyWith(isCompleted: true);
    await _db.updateQuestCompletion(questId, true);

    // Save to history
    final user = _userProvider.user;
    if (user != null) {
      final entry = HistoryEntry(
        id: '${questId}_history',
        userId: user.uid,
        questTitle: _todayQuests[index].title,
        questCategory: _todayQuests[index].category,
        completedDate: DateTime.now(),
        rankAtTime: getRankInfo(user.currentRank).name,
      );
      await _userProvider.addHistoryEntry(entry);
    }

    // Check if all quests done + oath to see if day is complete
    if (allQuestsCompleted) {
      await _handleDayComplete();
    }

    notifyListeners();
  }

  Future<void> uncompleteQuest(String questId) async {
    final index = _todayQuests.indexWhere((q) => q.id == questId);
    if (index == -1) return;
    _todayQuests[index] = _todayQuests[index].copyWith(isCompleted: false);
    await _db.updateQuestCompletion(questId, false);
    notifyListeners();
  }

  // ─── OATH ────────────────────────────────────────────────────────────────

  Future<void> answerOath(bool honest) async {
    _oathAnswered = true;
    _oathAnswer = honest;
    await _localStorage.setOathAnsweredToday(true, answer: honest);

    if (allQuestsCompleted) {
      await _handleDayComplete();
    }

    notifyListeners();
  }

  // ─── DAY COMPLETE LOGIC ──────────────────────────────────────────────────

  Future<bool> _handleDayComplete() async {
    final user = _userProvider.user;
    if (user == null || _oathAnswer == null) return false;

    final completedTitles = _todayQuests
        .where((q) => q.isCompleted)
        .map((q) => q.title)
        .toList();

    final rankUpReady = await _userProvider.recordDayComplete(
      oathAnswer: _oathAnswer!,
      completedQuestTitles: completedTitles,
    );

    if (rankUpReady && user.currentRank < 15) {
      _bossQuestUnlocked = true;
      await _localStorage.setBossQuestUnlocked(true);
      await _generateBossQuest();
    }

    return rankUpReady;
  }

  // ─── BOSS QUEST ──────────────────────────────────────────────────────────

  Future<void> _generateBossQuest() async {
    final user = _userProvider.user;
    if (user == null) return;

    final apiKey = await _localStorage.getGeminiApiKey();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final nextRank = getNextRank(user.currentRank);

    _bossQuest = await _gemini.generateBossQuest(
      apiKey: apiKey,
      career: user.career,
      interests: user.interests,
      rankNumber: user.currentRank,
      currentRankName: getRankInfo(user.currentRank).name,
      nextRankName: nextRank?.name ?? 'Absolute',
      date: today,
    );

    notifyListeners();
  }

  Future<void> completeBossQuest() async {
    _bossQuestCompleted = true;
    _bossQuestUnlocked = false;
    await _localStorage.setBossQuestUnlocked(false);
    await _userProvider.performRankUp();
    notifyListeners();
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Future<void> _restoreOathState() async {
    _oathAnswered = await _localStorage.oathAnsweredToday();
    _oathAnswer = await _localStorage.getOathAnswer();
  }

  Future<void> resetForNewDay() async {
    _oathAnswered = false;
    _oathAnswer = null;
    _bossQuestCompleted = false;
    _todayQuests = [];
    await _localStorage.resetDailyFlags();
    await loadTodayQuests();
  }
}

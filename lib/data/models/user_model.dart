// User model for local SQLite and Firestore (minus API key)
class UserModel {
  final String uid;
  final String name;
  final String career;
  final String interests;
  final int fitnessLevel;
  final String dailyTime;
  final bool hasComputer;
  final int currentRank;
  final int currentStreak;
  final int integrityStreak;
  final int rankCompletions;
  final int shieldsRemaining;
  final DateTime? shieldsLastReset;
  final List<String> recentQuestHistory;
  final int totalQuestsCompleted;
  final int longestStreak;
  final DateTime? startDate;
  final int totalXp;
  final List<String> unlockedBadges;
  final List<String> unlockedTitles;
  final String auraColor; // only for Absolute rank
  final bool cloudBackupEnabled;
  // hadBrokenStreak: for Phoenix title logic
  final bool hadBrokenStreak;
  final int phoenixStreakBeforeBreak;

  const UserModel({
    required this.uid,
    required this.name,
    required this.career,
    required this.interests,
    required this.fitnessLevel,
    required this.dailyTime,
    required this.hasComputer,
    this.currentRank = 1,
    this.currentStreak = 0,
    this.integrityStreak = 0,
    this.rankCompletions = 0,
    this.shieldsRemaining = 3,
    this.shieldsLastReset,
    this.recentQuestHistory = const [],
    this.totalQuestsCompleted = 0,
    this.longestStreak = 0,
    this.startDate,
    this.totalXp = 0,
    this.unlockedBadges = const [],
    this.unlockedTitles = const [],
    this.auraColor = '#FFD700',
    this.cloudBackupEnabled = true,
    this.hadBrokenStreak = false,
    this.phoenixStreakBeforeBreak = 0,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? career,
    String? interests,
    int? fitnessLevel,
    String? dailyTime,
    bool? hasComputer,
    int? currentRank,
    int? currentStreak,
    int? integrityStreak,
    int? rankCompletions,
    int? shieldsRemaining,
    DateTime? shieldsLastReset,
    List<String>? recentQuestHistory,
    int? totalQuestsCompleted,
    int? longestStreak,
    DateTime? startDate,
    int? totalXp,
    List<String>? unlockedBadges,
    List<String>? unlockedTitles,
    String? auraColor,
    bool? cloudBackupEnabled,
    bool? hadBrokenStreak,
    int? phoenixStreakBeforeBreak,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      career: career ?? this.career,
      interests: interests ?? this.interests,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      dailyTime: dailyTime ?? this.dailyTime,
      hasComputer: hasComputer ?? this.hasComputer,
      currentRank: currentRank ?? this.currentRank,
      currentStreak: currentStreak ?? this.currentStreak,
      integrityStreak: integrityStreak ?? this.integrityStreak,
      rankCompletions: rankCompletions ?? this.rankCompletions,
      shieldsRemaining: shieldsRemaining ?? this.shieldsRemaining,
      shieldsLastReset: shieldsLastReset ?? this.shieldsLastReset,
      recentQuestHistory: recentQuestHistory ?? this.recentQuestHistory,
      totalQuestsCompleted: totalQuestsCompleted ?? this.totalQuestsCompleted,
      longestStreak: longestStreak ?? this.longestStreak,
      startDate: startDate ?? this.startDate,
      totalXp: totalXp ?? this.totalXp,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      unlockedTitles: unlockedTitles ?? this.unlockedTitles,
      auraColor: auraColor ?? this.auraColor,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
      hadBrokenStreak: hadBrokenStreak ?? this.hadBrokenStreak,
      phoenixStreakBeforeBreak: phoenixStreakBeforeBreak ?? this.phoenixStreakBeforeBreak,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'career': career,
      'interests': interests,
      'fitness_level': fitnessLevel,
      'daily_time': dailyTime,
      'has_computer': hasComputer ? 1 : 0,
      'current_rank': currentRank,
      'current_streak': currentStreak,
      'integrity_streak': integrityStreak,
      'rank_completions': rankCompletions,
      'shields_remaining': shieldsRemaining,
      'shields_last_reset': shieldsLastReset?.millisecondsSinceEpoch,
      'recent_quest_history': recentQuestHistory.join('|||'),
      'total_quests_completed': totalQuestsCompleted,
      'longest_streak': longestStreak,
      'start_date': startDate?.millisecondsSinceEpoch,
      'total_xp': totalXp,
      'unlocked_badges': unlockedBadges.join(','),
      'unlocked_titles': unlockedTitles.join(','),
      'aura_color': auraColor,
      'cloud_backup_enabled': cloudBackupEnabled ? 1 : 0,
      'had_broken_streak': hadBrokenStreak ? 1 : 0,
      'phoenix_streak_before_break': phoenixStreakBeforeBreak,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'career': career,
      'interests': interests,
      'fitness_level': fitnessLevel,
      'daily_time': dailyTime,
      'has_computer': hasComputer,
      'current_rank': currentRank,
      'current_streak': currentStreak,
      'integrity_streak': integrityStreak,
      'rank_completions': rankCompletions,
      'shields_remaining': shieldsRemaining,
      'shields_last_reset': shieldsLastReset?.millisecondsSinceEpoch,
      'recent_quest_history': recentQuestHistory,
      'total_quests_completed': totalQuestsCompleted,
      'longest_streak': longestStreak,
      'start_date': startDate?.millisecondsSinceEpoch,
      'total_xp': totalXp,
      'unlocked_badges': unlockedBadges,
      'unlocked_titles': unlockedTitles,
      'aura_color': auraColor,
      'had_broken_streak': hadBrokenStreak,
      'phoenix_streak_before_break': phoenixStreakBeforeBreak,
      // NOTE: gemini_api_key is NOT included here intentionally
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      career: map['career'] as String? ?? '',
      interests: map['interests'] as String? ?? '',
      fitnessLevel: map['fitness_level'] as int? ?? 5,
      dailyTime: map['daily_time'] as String? ?? '30',
      hasComputer: (map['has_computer'] == 1 || map['has_computer'] == true),
      currentRank: map['current_rank'] as int? ?? 1,
      currentStreak: map['current_streak'] as int? ?? 0,
      integrityStreak: map['integrity_streak'] as int? ?? 0,
      rankCompletions: map['rank_completions'] as int? ?? 0,
      shieldsRemaining: map['shields_remaining'] as int? ?? 3,
      shieldsLastReset: map['shields_last_reset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['shields_last_reset'] as int)
          : null,
      recentQuestHistory: map['recent_quest_history'] is String
          ? (map['recent_quest_history'] as String).isEmpty
              ? []
              : (map['recent_quest_history'] as String).split('|||')
          : (map['recent_quest_history'] as List?)?.cast<String>() ?? [],
      totalQuestsCompleted: map['total_quests_completed'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      startDate: map['start_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int)
          : null,
      totalXp: map['total_xp'] as int? ?? 0,
      unlockedBadges: map['unlocked_badges'] is String
          ? (map['unlocked_badges'] as String).isEmpty
              ? []
              : (map['unlocked_badges'] as String).split(',')
          : (map['unlocked_badges'] as List?)?.cast<String>() ?? [],
      unlockedTitles: map['unlocked_titles'] is String
          ? (map['unlocked_titles'] as String).isEmpty
              ? []
              : (map['unlocked_titles'] as String).split(',')
          : (map['unlocked_titles'] as List?)?.cast<String>() ?? [],
      auraColor: map['aura_color'] as String? ?? '#FFD700',
      cloudBackupEnabled: (map['cloud_backup_enabled'] == 1 || map['cloud_backup_enabled'] == true),
      hadBrokenStreak: (map['had_broken_streak'] == 1 || map['had_broken_streak'] == true),
      phoenixStreakBeforeBreak: map['phoenix_streak_before_break'] as int? ?? 0,
    );
  }
}

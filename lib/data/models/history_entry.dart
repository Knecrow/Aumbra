class HistoryEntry {
  final String id;
  final String userId;
  final String questTitle;
  final String questCategory;
  final DateTime completedDate;
  final String rankAtTime;

  const HistoryEntry({
    required this.id,
    required this.userId,
    required this.questTitle,
    required this.questCategory,
    required this.completedDate,
    required this.rankAtTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'quest_title': questTitle,
      'quest_category': questCategory,
      'completed_date': completedDate.millisecondsSinceEpoch,
      'rank_at_time': rankAtTime,
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      questTitle: map['quest_title'] as String? ?? '',
      questCategory: map['quest_category'] as String? ?? '',
      completedDate: DateTime.fromMillisecondsSinceEpoch(
        map['completed_date'] as int? ?? 0,
      ),
      rankAtTime: map['rank_at_time'] as String? ?? 'Awakened',
    );
  }
}

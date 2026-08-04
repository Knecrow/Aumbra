class QuestModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isCompleted;
  final String date; // yyyy-MM-dd
  final bool isBossQuest;

  const QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
    required this.date,
    this.isBossQuest = false,
  });

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    String? date,
    bool? isBossQuest,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      isBossQuest: isBossQuest ?? this.isBossQuest,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
      'date': date,
      'is_boss_quest': isBossQuest ? 1 : 0,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map) {
    return QuestModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      isCompleted: (map['is_completed'] == 1 || map['is_completed'] == true),
      date: map['date'] as String? ?? '',
      isBossQuest: (map['is_boss_quest'] == 1 || map['is_boss_quest'] == true),
    );
  }

  factory QuestModel.fromGeminiJson(Map<String, dynamic> json, String date) {
    return QuestModel(
      id: '${date}_${json['category']}_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Daily Quest',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Mind',
      date: date,
    );
  }
}

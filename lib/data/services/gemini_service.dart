import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quest_model.dart';
import '../../core/constants/fallback_quests.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Generates daily quests using Gemini API.
  /// Falls back to pre-written quests if API fails or key is missing.
  Future<List<QuestModel>> generateQuests({
    required String? apiKey,
    required int taskCount,
    required String career,
    required String interests,
    required int fitnessLevel,
    required bool hasComputer,
    required int rankNumber,
    required List<String> recentQuestHistory,
    required List<String> categories,
    required String date,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      return _generateFallbackQuests(categories, date);
    }

    try {
      final prompt = _buildPrompt(
        taskCount: taskCount,
        career: career,
        interests: interests,
        fitnessLevel: fitnessLevel,
        hasComputer: hasComputer,
        rankNumber: rankNumber,
        recentQuestHistory: recentQuestHistory,
        categories: categories,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'maxOutputTokens': 2048,
            'responseMimeType': 'application/json',
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (text != null) {
          return _parseQuestsFromJson(text, date, categories);
        }
      }
    } catch (e) {
      // Fall through to fallback
    }

    return _generateFallbackQuests(categories, date);
  }

  String _buildPrompt({
    required int taskCount,
    required String career,
    required String interests,
    required int fitnessLevel,
    required bool hasComputer,
    required int rankNumber,
    required List<String> recentQuestHistory,
    required List<String> categories,
  }) {
    final historyStr = recentQuestHistory.isEmpty
        ? 'none'
        : recentQuestHistory.join(', ');

    final categoriesForQuests = categories.where((c) => c != 'Oath').toList();

    return '''Generate ${categoriesForQuests.length} daily quests for a self-improvement app user.

Profile:
- Career/Study: $career
- Interests: $interests
- Fitness Level: $fitnessLevel/10
- Has Computer: $hasComputer
- Rank Number: $rankNumber (out of 15)

Categories needed (one quest per category): ${categoriesForQuests.join(', ')}

DO NOT repeat these recent quests: $historyStr

Depth scaling by rank:
- Ranks 1-3 (Absorb): watch, read, listen, stretch - zero output tasks
- Ranks 4-7 (Apply): do, write 1-3 sentences, practice
- Ranks 8-11 (Analyze): refactor, review, 200+ word analysis
- Ranks 12-15 (Create): build, design, teach, 500+ word guide

${!hasComputer ? 'IMPORTANT: Has Computer is FALSE. NEVER give laptop or computer-dependent quests.' : ''}

Return ONLY a JSON array, no other text:
[{"title":"...","description":"...","category":"..."}]

Each quest must:
- Have a title (short, action-oriented)
- Have a description (clear, specific, achievable in one day)
- Match the category exactly (${categoriesForQuests.join('/')})
- Be appropriate for rank $rankNumber depth level''';
  }

  List<QuestModel> _parseQuestsFromJson(
      String text, String date, List<String> categories) {
    try {
      // Extract JSON array from response
      final jsonStr = text.trim();
      final start = jsonStr.indexOf('[');
      final end = jsonStr.lastIndexOf(']');
      if (start == -1 || end == -1) throw Exception('No JSON array found');

      final jsonList = jsonDecode(jsonStr.substring(start, end + 1)) as List;
      final quests = <QuestModel>[];

      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          quests.add(QuestModel.fromGeminiJson(item, date));
        }
      }

      if (quests.isEmpty) throw Exception('No quests parsed');
      return quests;
    } catch (e) {
      return _generateFallbackQuests(categories, date);
    }
  }

  List<QuestModel> _generateFallbackQuests(List<String> categories, String date) {
    final fallbacks = getFallbackQuestsForCategories(categories);
    return fallbacks.map((f) {
      return QuestModel(
        id: '${date}_${f.category}_${f.title.hashCode}',
        title: f.title,
        description: f.description,
        category: f.category,
        date: date,
      );
    }).toList();
  }

  /// Generate a special Boss Quest for rank-up
  Future<QuestModel> generateBossQuest({
    required String? apiKey,
    required String career,
    required String interests,
    required int rankNumber,
    required String currentRankName,
    required String nextRankName,
    required String date,
  }) async {
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        final prompt = '''Generate ONE special "Boss Quest" for a user who is about to rank up from $currentRankName to $nextRankName.

Profile:
- Career/Study: $career
- Interests: $interests
- Rank: $rankNumber

This boss quest should be:
- Significantly more challenging than a regular daily task
- Something that proves they're ready for the next rank
- A meaningful achievement or output they can be proud of
- Completable in one sitting (2-4 hours)

Return ONLY a JSON object:
{"title":"...","description":"...","category":"Mind"}''';

        final response = await http.post(
          Uri.parse('$_baseUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.9,
              'maxOutputTokens': 512,
              'responseMimeType': 'application/json',
            },
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final text =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
          if (text != null) {
            final jsonStr = text.trim();
            final start = jsonStr.indexOf('{');
            final end = jsonStr.lastIndexOf('}');
            if (start != -1 && end != -1) {
              final json = jsonDecode(jsonStr.substring(start, end + 1));
              return QuestModel.fromGeminiJson(json, date).copyWith(isBossQuest: true);
            }
          }
        }
      } catch (e) {
        // Fall through to default
      }
    }

    // Fallback boss quest
    return QuestModel(
      id: '${date}_boss_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Prove Your Worth: The $nextRankName Trial',
      description:
          'You stand at the threshold of $nextRankName. Complete a meaningful project or task in your field of $career that demonstrates mastery. Document your process and what you learned. This is your rite of passage.',
      category: 'Mind',
      date: date,
      isBossQuest: true,
    );
  }
}

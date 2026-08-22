import 'package:flutter/material.dart';

// ─── RANK DEFINITIONS ──────────────────────────────────────────────────────
class RankInfo {
  final int rankNumber;
  final String name;
  final Color color;
  final Color? trimColor;
  final bool isGradient;
  final List<Color>? gradientColors;
  final bool isShimmer;
  final bool isCustomColor;

  // Progression requirements
  final int completionsRequired; // C
  final int streakRequired;      // S

  // Task configuration
  final int taskCount;
  final String depthLevel; // Absorb / Apply / Analyze / Create

  const RankInfo({
    required this.rankNumber,
    required this.name,
    required this.color,
    this.trimColor,
    this.isGradient = false,
    this.gradientColors,
    this.isShimmer = false,
    this.isCustomColor = false,
    required this.completionsRequired,
    required this.streakRequired,
    required this.taskCount,
    required this.depthLevel,
  });

  int get bufferDays => completionsRequired - streakRequired;

  List<String> get categories {
    switch (rankNumber) {
      case 1:
      case 2:
      case 3:
        return ['Mind', 'Body', 'Soul', 'Environment', 'Oath'];
      case 4:
      case 5:
      case 6:
      case 7:
        return ['Mind', 'Body', 'Soul', 'Environment', 'Social', 'Oath'];
      case 8:
      case 9:
      case 10:
      case 11:
        return ['Mind', 'Body', 'Soul', 'Environment', 'Social', 'Plan', 'Oath'];
      case 12:
      case 13:
      case 14:
        return ['Mind', 'Body', 'Soul', 'Environment', 'Social', 'Plan', 'Reflect', 'Oath'];
      case 15:
        return ['Mind', 'Body', 'Soul', 'Environment', 'Social', 'Plan', 'Reflect', 'Custom', 'Oath'];
      default:
        return ['Mind', 'Body', 'Soul', 'Environment', 'Oath'];
    }
  }
}

const List<RankInfo> kRanks = [
  RankInfo(
    rankNumber: 1,
    name: 'Awakened',
    color: Color(0xFF78909C), // Gunmetal Slate Steel
    completionsRequired: 13,
    streakRequired: 11,
    taskCount: 5,
    depthLevel: 'Absorb',
  ),
  RankInfo(
    rankNumber: 2,
    name: 'Seeker',
    color: Color(0xFFD48443), // Antique Bronze Copper
    completionsRequired: 15,
    streakRequired: 13,
    taskCount: 5,
    depthLevel: 'Absorb',
  ),
  RankInfo(
    rankNumber: 3,
    name: 'Strider',
    color: Color(0xFFE0E6ED), // Polished Silver Chrome
    completionsRequired: 17,
    streakRequired: 14,
    taskCount: 5,
    depthLevel: 'Absorb',
  ),
  RankInfo(
    rankNumber: 4,
    name: 'Forged',
    color: Color(0xFFFFD700), // Pure Solar Gold
    completionsRequired: 19,
    streakRequired: 16,
    taskCount: 6,
    depthLevel: 'Apply',
  ),
  RankInfo(
    rankNumber: 5,
    name: 'Ascendant',
    color: Color(0xFF00F5D4), // Radianite Mint Cyan
    completionsRequired: 21,
    streakRequired: 17,
    taskCount: 6,
    depthLevel: 'Apply',
  ),
  RankInfo(
    rankNumber: 6,
    name: 'Exalted',
    color: Color(0xFF00E676), // Vibrant Emerald Green
    completionsRequired: 23,
    streakRequired: 19,
    taskCount: 6,
    depthLevel: 'Apply',
  ),
  RankInfo(
    rankNumber: 7,
    name: 'Paragon',
    color: Color(0xFFC6FF00), // Acid Volt Lime
    completionsRequired: 25,
    streakRequired: 20,
    taskCount: 6,
    depthLevel: 'Apply',
  ),
  RankInfo(
    rankNumber: 8,
    name: 'Sage',
    color: Color(0xFFFF6D00), // Blaze Fire Orange
    completionsRequired: 27,
    streakRequired: 22,
    taskCount: 7,
    depthLevel: 'Analyze',
  ),
  RankInfo(
    rankNumber: 9,
    name: 'Saint',
    color: Color(0xFFFF1744), // Vivid Crimson Red
    completionsRequired: 29,
    streakRequired: 23,
    taskCount: 7,
    depthLevel: 'Analyze',
  ),
  RankInfo(
    rankNumber: 10,
    name: 'Limitless',
    color: Color(0xFFFF007F), // Deep Hot Neon Pink
    completionsRequired: 31,
    streakRequired: 25,
    taskCount: 7,
    depthLevel: 'Analyze',
  ),
  RankInfo(
    rankNumber: 11,
    name: 'Eternal',
    color: Color(0xFF9C27B0), // Imperial Amethyst Violet
    completionsRequired: 33,
    streakRequired: 26,
    taskCount: 7,
    depthLevel: 'Analyze',
  ),
  RankInfo(
    rankNumber: 12,
    name: 'Transcendent',
    color: Color(0xFF2979FF), // Arcana Cobalt Blue
    trimColor: Color(0xFF00F5D4),
    completionsRequired: 35,
    streakRequired: 28,
    taskCount: 8,
    depthLevel: 'Create',
  ),
  RankInfo(
    rankNumber: 13,
    name: 'Celestial',
    color: Color(0xFF004D40), // Dark Obsidian Pine
    isShimmer: true,
    completionsRequired: 37,
    streakRequired: 29,
    taskCount: 8,
    depthLevel: 'Create',
  ),
  RankInfo(
    rankNumber: 14,
    name: 'Divine',
    color: Color(0xFFEA80FC), // Luminous Aurora Orchid
    isGradient: true,
    gradientColors: [Color(0xFF80D8FF), Color(0xFFEA80FC), Color(0xFFFF6D00)],
    completionsRequired: 40,
    streakRequired: 32,
    taskCount: 8,
    depthLevel: 'Create',
  ),
  RankInfo(
    rankNumber: 15,
    name: 'Absolute',
    color: Color(0xFFFFF59D), // Luminous Sovereign Starlight
    isCustomColor: true,
    completionsRequired: 0,
    streakRequired: 0,
    taskCount: 9,
    depthLevel: 'Create',
  ),
];

RankInfo getRankInfo(int rankNumber) {
  if (rankNumber < 1) return kRanks[0];
  if (rankNumber > 15) return kRanks[14];
  return kRanks[rankNumber - 1];
}

RankInfo? getNextRank(int currentRank) {
  if (currentRank >= 15) return null;
  return kRanks[currentRank]; // index = currentRank (0-based = next rank)
}

String getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'mind': return '🧠';
    case 'body': return '💪';
    case 'soul': return '🎨';
    case 'environment': return '🏠';
    case 'social': return '💬';
    case 'plan': return '📅';
    case 'reflect': return '🪞';
    case 'custom': return '✨';
    case 'oath': return '🤝';
    default: return '⚡';
  }
}

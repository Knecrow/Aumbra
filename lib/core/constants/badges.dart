// Badge definitions
class BadgeInfo {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;

  const BadgeInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
  });
}

const List<BadgeInfo> kBadges = [
  // Streak
  BadgeInfo(
    id: 'first_flame',
    name: 'First Flame',
    description: 'Maintain a 7-day streak',
    icon: '🔥',
    category: 'Streak',
  ),
  BadgeInfo(
    id: 'iron_will',
    name: 'Iron Will',
    description: 'Maintain a 30-day streak',
    icon: '⚔️',
    category: 'Streak',
  ),
  BadgeInfo(
    id: 'unbreakable',
    name: 'Unbreakable',
    description: 'Maintain a 100-day streak',
    icon: '💎',
    category: 'Streak',
  ),

  // Volume
  BadgeInfo(
    id: 'initiate',
    name: 'Initiate',
    description: 'Complete 10 quests',
    icon: '⚡',
    category: 'Volume',
  ),
  BadgeInfo(
    id: 'grinder',
    name: 'Grinder',
    description: 'Complete 100 quests',
    icon: '🏋️',
    category: 'Volume',
  ),
  BadgeInfo(
    id: 'ascetic',
    name: 'Ascetic',
    description: 'Complete 500 quests',
    icon: '🌟',
    category: 'Volume',
  ),

  // Rank
  BadgeInfo(
    id: 'awakened_one',
    name: 'Awakened One',
    description: 'Reach the Seeker rank',
    icon: '👁️',
    category: 'Rank',
  ),
  BadgeInfo(
    id: 'sages_wisdom',
    name: "Sage's Wisdom",
    description: 'Reach the Sage rank',
    icon: '🔮',
    category: 'Rank',
  ),
  BadgeInfo(
    id: 'absolute_god',
    name: 'Absolute God',
    description: 'Reach the Absolute rank',
    icon: '👑',
    category: 'Rank',
  ),

  // Integrity
  BadgeInfo(
    id: 'the_honest',
    name: 'The Honest',
    description: 'Maintain a 7-day Oath streak',
    icon: '🤝',
    category: 'Integrity',
  ),
  BadgeInfo(
    id: 'true_to_self',
    name: 'True to Self',
    description: 'Maintain a 30-day Oath streak',
    icon: '🪞',
    category: 'Integrity',
  ),

  // Shield
  BadgeInfo(
    id: 'the_resilient',
    name: 'The Resilient',
    description: 'Use all 3 shields in a month and still rank up',
    icon: '🛡️',
    category: 'Shield',
  ),
];

// ─── TITLE DEFINITIONS ──────────────────────────────────────────────────────
class TitleInfo {
  final String id;
  final String name;
  final String description;

  const TitleInfo({
    required this.id,
    required this.name,
    required this.description,
  });
}

const List<TitleInfo> kTitles = [
  TitleInfo(
    id: 'the_rookie',
    name: 'The Rookie',
    description: 'Complete your first quest',
  ),
  TitleInfo(
    id: 'the_consistent',
    name: 'The Consistent',
    description: 'Achieve a 14-day streak',
  ),
  TitleInfo(
    id: 'the_unshaken',
    name: 'The Unshaken',
    description: 'Recover from a broken streak',
  ),
  TitleInfo(
    id: 'the_sage',
    name: 'The Sage',
    description: 'Reach the Sage rank',
  ),
  TitleInfo(
    id: 'the_limitless',
    name: 'The Limitless',
    description: 'Reach the Limitless rank',
  ),
  TitleInfo(
    id: 'the_absolute',
    name: 'The Absolute',
    description: 'Reach the Absolute rank',
  ),
  TitleInfo(
    id: 'the_phoenix',
    name: 'The Phoenix',
    description: 'Break a 30-day streak and rebuild to 30',
  ),
];

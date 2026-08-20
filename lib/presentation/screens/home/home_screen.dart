import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/rank_widgets.dart';
import '../../widgets/hex_quest_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestProvider>().loadTodayQuests();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final questProvider = context.watch<QuestProvider>();
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
      );
    }

    final rankInfo = userProvider.currentRankInfo;
    final rankColor = userProvider.currentRankColor;
    final lightRankColor = AppColors.getLightVariant(rankColor);

    final answered = questProvider.oathAnswered;
    final answerTrue = questProvider.oathAnswer == true;
    final completionsReq = rankInfo.completionsRequired;
    final userCompletions = user.rankCompletions;
    final ascProgress = completionsReq > 0 ? (userCompletions / completionsReq).clamp(0.0, 1.0) : 1.0;
    final daysAwakened = user.startDate != null
        ? DateTime.now().difference(user.startDate!).inDays + 1
        : 1;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.buildRankAmbientGradient(rankColor),
        ),
        child: SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _headerAnim,
            child: Column(
              children: [
                // ── 1. DEDICATED TOP PROFILE & TELEMETRY CARD ─────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: AppColors.glassCard(
                      rankColor: rankColor,
                      borderRadius: 22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Top Row: Profile & Stats ───────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left: Avatar with Progress Ring + Codename + Rank Name Highlight
                            GestureDetector(
                              onTap: () => _showEditProfileModal(context, userProvider),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Circular Avatar with Ascension Progress Ring in Rank Color
                                  SizedBox(
                                    width: 46,
                                    height: 46,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Progress Ring in Rank Color
                                        CircularProgressIndicator(
                                          value: ascProgress,
                                          strokeWidth: 2.5,
                                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                                          valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                                        ),
                                        // Inner Avatar Circle with Unique Rank Insignia Icon
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF000000),
                                            border: Border.all(
                                              color: rankColor.withValues(alpha: 0.40),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              _getRankAvatarIcon(rankInfo.rankNumber),
                                              color: lightRankColor,
                                              size: 19,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Name & Highlighted Rank Name Pill
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user.name.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      // 🌟 RANK NAME HIGHLIGHT PILL
                                      GestureDetector(
                                        onTap: () => _showRankLoreModal(context, userProvider),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: rankColor.withValues(alpha: 0.16),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: rankColor.withValues(alpha: 0.45),
                                              width: 0.9,
                                            ),
                                          ),
                                          child: Text(
                                            rankInfo.name.toUpperCase(),
                                            style: TextStyle(
                                              color: lightRankColor,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Right: 3 Shields & Streak Pill
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 1. Streak Protection Shields (3 Shields)
                                GestureDetector(
                                  onTap: () => _showShieldInfoDialog(context, user.shieldsRemaining, rankColor),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF000000),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: rankColor.withValues(alpha: 0.35),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(3, (idx) {
                                        final isActive = idx < user.shieldsRemaining;
                                        return Padding(
                                          padding: EdgeInsets.only(right: idx < 2 ? 3 : 0),
                                          child: Icon(
                                            isActive ? Icons.shield_rounded : Icons.shield_outlined,
                                            color: isActive
                                                ? rankColor
                                                : Colors.white.withValues(alpha: 0.18),
                                            size: 13.5,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),

                                // 2. Streak Pill (Flame + Days)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF000000),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFF9100).withValues(alpha: 0.30),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.local_fire_department_rounded,
                                          color: Color(0xFFFF9100), size: 13),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${user.currentStreak}d',
                                        style: const TextStyle(
                                          color: Color(0xFFFFB74D),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Bottom Progress Bar for Completed Days / Ascension ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.done_all_rounded,
                                    color: AppColors.emeraldPrimary, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'COMPLETED: $userCompletions / $completionsReq PROTOCOLS',
                                  style: const TextStyle(
                                    color: Color(0xFF8E9BA6),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${(ascProgress * 100).toInt()}%',
                              style: TextStyle(
                                color: lightRankColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Sleek Glowing Linear Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              Container(
                                height: 5.5,
                                width: double.infinity,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              FractionallySizedBox(
                                widthFactor: ascProgress.clamp(0.02, 1.0),
                                child: Container(
                                  height: 5.5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        rankColor,
                                        lightRankColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: rankColor.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 2. HERO CENTERPIECE: HEXAGONAL HONEYCOMB QUEST GRID ────
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: HexQuestHoneycombGrid(
                        quests: questProvider.todayQuests,
                        bossQuest: questProvider.bossQuest,
                        bossQuestUnlocked: questProvider.bossQuestUnlocked,
                        oathAnswered: answered,
                        oathHonored: answerTrue,
                        onOathTap: () => _showHonestyOathModal(context, questProvider, rankColor),
                        rankColor: rankColor,
                        rankInfo: rankInfo,
                        onComplete: (id) => questProvider.completeQuest(id),
                        onUncomplete: (id) => questProvider.uncompleteQuest(id),
                        onBossChallenge: () => _showBossQuestDialog(questProvider, rankColor),
                      ),
                    ),
                  ),
                ),

                // Floating Nav Dock spacing
                const SizedBox(height: 86),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns time-of-day greeting
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  /// Unique avatar insignia icon for each hunter rank
  IconData _getRankAvatarIcon(int rank) {
    switch (rank) {
      case 1: return Icons.auto_awesome_rounded;      // Awakened Spark
      case 2: return Icons.explore_rounded;            // Seeker Compass
      case 3: return Icons.bolt_rounded;               // Strider Lightning
      case 4: return Icons.local_fire_department_rounded; // Forged Flame
      case 5: return Icons.north_east_rounded;         // Vector Ascendant
      case 6: return Icons.shield_rounded;             // Warden Shield
      case 7: return Icons.diamond_rounded;            // Sovereign Diamond
      case 8: return Icons.menu_book_rounded;          // Master Grimoire
      case 9: return Icons.wb_sunny_rounded;           // Solar Zenith
      case 10: return Icons.all_inclusive_rounded;     // Eternal Infinity
      case 11: return Icons.hourglass_empty_rounded;   // Time Weaver
      case 12: return Icons.flare_rounded;             // Solar Flare
      case 13: return Icons.stars_rounded;             // Celestial Monarch
      case 14: return Icons.military_tech_rounded;     // Grand Marshal
      case 15: return Icons.workspace_premium_rounded; // Absolute Crown
      default: return Icons.auto_awesome_rounded;
    }
  }

  void _showShieldInfoDialog(BuildContext context, int shieldsRemaining, Color rankColor) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF080808),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: rankColor.withValues(alpha: 0.4), width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.shield_rounded, color: rankColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              'STREAK SHIELDS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(3, (idx) {
                final active = idx < shieldsRemaining;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    active ? Icons.shield_rounded : Icons.shield_outlined,
                    color: active ? const Color(0xFF29B6F6) : Colors.white.withValues(alpha: 0.20),
                    size: 26,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              '$shieldsRemaining of 3 Shields Available',
              style: const TextStyle(
                color: Color(0xFF81D4FA),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Streak shields automatically preserve your active streak if you miss a protocol day. Shields refresh each month.',
              style: TextStyle(
                color: Color(0xFF8E9BA6),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('DISMISS', style: TextStyle(color: Color(0xFF29B6F6), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showHonestyOathModal(BuildContext context, QuestProvider questProvider, Color rankColor) {
    HapticFeedback.mediumImpact();
    final answered = questProvider.oathAnswered;
    final answerTrue = questProvider.oathAnswer == true;
    final lightRank = AppColors.getLightVariant(rankColor);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF080808),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E0E0E), Color(0xFF040404)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: answered
                  ? (answerTrue ? AppColors.emeraldPrimary : const Color(0xFFFF9100)).withValues(alpha: 0.45)
                  : rankColor.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: rankColor.withValues(alpha: 0.4), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, size: 14, color: rankColor),
                        const SizedBox(width: 6),
                        Text(
                          'HONESTY OATH',
                          style: TextStyle(
                            color: lightRank,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.darkSubText, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'DAILY INTEGRITY CHECK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Did you complete today\'s protocols with genuine, honest effort?',
                style: TextStyle(
                  color: Color(0xFF8E9BA6),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        questProvider.answerOath(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [rankColor, AppColors.getDeepVariant(rankColor)],
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            'YES, HONORED ✓',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showOathReflectionDialog(context, rankColor);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.darkCardElevated,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.0),
                        ),
                        child: const Center(
                          child: Text(
                            'REFLECT',
                            style: TextStyle(
                              color: AppColors.darkSubText,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOathReflectionDialog(BuildContext context, Color rankColor) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: rankColor.withValues(alpha: 0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: rankColor, size: 20),
            const SizedBox(width: 8),
            const Text('Daily Reflection',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Honesty is the foundation of discipline. What will you conquer differently tomorrow?',
              style: TextStyle(color: AppColors.darkSubText, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Your reflection...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<QuestProvider>().answerOath(false);
            },
            child: Text('SUBMIT', style: TextStyle(color: rankColor, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) return;
    final rankColor = userProvider.currentRankColor;
    final lightRankColor = AppColors.getLightVariant(rankColor);
    final controller = TextEditingController(text: user.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: rankColor.withValues(alpha: 0.15),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkSubText.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'EDIT CODENAME',
                style: TextStyle(
                  color: lightRankColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Enter new codename...',
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: rankColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      await userProvider.updateProfile(name: newName);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: rankColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('SAVE IDENTITY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showRankLoreModal(BuildContext context, UserProvider userProvider) {
    final rankInfo = userProvider.currentRankInfo;
    final rankColor = userProvider.currentRankColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: 0.2),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkSubText.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            RankGlowBadge(rankInfo: rankInfo, size: 68),
            const SizedBox(height: 14),
            Text(
              'RANK ${rankInfo.rankNumber}: ${rankInfo.name.toUpperCase()}',
              style: TextStyle(
                color: AppColors.getLightVariant(rankColor),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'DEPTH LEVEL: ${rankInfo.depthLevel.toUpperCase()}',
              style: const TextStyle(
                color: AppColors.darkSubText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Requires ${rankInfo.taskCount} daily discipline objectives across Mind, Body, Soul, and Ascendance.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.darkText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rankColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showBossQuestDialog(QuestProvider questProvider, Color rankColor) {
    final boss = questProvider.bossQuest;
    if (boss == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: rankColor, width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.bolt_rounded, color: rankColor, size: 24),
            const SizedBox(width: 8),
            const Text('BOSS ENCOUNTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              boss.title,
              style: TextStyle(color: rankColor, fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              boss.description,
              style: const TextStyle(color: AppColors.darkSubText, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.darkSubText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              questProvider.completeBossQuest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: rankColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('CONQUER', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

// ── COMPACT OATH ACTION BUTTON ───────────────────────────────────────────────
class _CompactOathButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactOathButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

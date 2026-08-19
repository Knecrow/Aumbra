import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/rank_widgets.dart';
import '../../widgets/radial_quest_dial.dart';

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
                // ── 1. LARGE & PROMINENT TOP PODS (IDENTITY LEFT + TELEMETRY RIGHT) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── LEFT TOP: STRUCTURED IDENTITY POD ──
                      GestureDetector(
                        onTap: () => _showEditProfileModal(context, userProvider),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.40),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RankGlowBadge(
                                rankInfo: rankInfo,
                                size: 44,
                                progress: ascProgress,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        user.name.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit_outlined, color: rankColor.withValues(alpha: 0.7), size: 13),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: rankColor.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: rankColor.withValues(alpha: 0.35),
                                        width: 0.8,
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── RIGHT TOP: STRUCTURED TELEMETRY POD ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Streak & Days Row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Days Awakened
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCardElevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '⚡ ${daysAwakened}d',
                                    style: const TextStyle(
                                      color: AppColors.darkSubText,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),

                                // Streak Flame Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCardElevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: rankColor.withValues(alpha: 0.35),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_fire_department_rounded, color: rankColor, size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${user.currentStreak}d',
                                        style: TextStyle(
                                          color: lightRankColor,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            // Shields & Info Row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkCardElevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    children: List.generate(3, (i) {
                                      final available = i < user.shieldsRemaining;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 1),
                                        child: Icon(
                                          available ? Icons.shield_rounded : Icons.shield_outlined,
                                          color: available ? rankColor : AppColors.darkDimText.withValues(alpha: 0.35),
                                          size: 13,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () => _showRankLoreModal(context, userProvider),
                                  child: Container(
                                    padding: const EdgeInsets.all(3.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkCardElevated,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Icon(Icons.info_outline_rounded, color: rankColor, size: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. HERO CENTERPIECE: RADIAL ENERGY WHEEL (70% ATTENTION) ──
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: RadialQuestDial(
                          quests: questProvider.todayQuests,
                          bossQuest: questProvider.bossQuest,
                          bossQuestUnlocked: questProvider.bossQuestUnlocked,
                          rankColor: rankColor,
                          rankInfo: rankInfo,
                          ascProgress: ascProgress,
                          onComplete: (id) => questProvider.completeQuest(id),
                          onUncomplete: (id) => questProvider.uncompleteQuest(id),
                          onBossChallenge: () => _showBossQuestDialog(questProvider, rankColor),
                          onCenterTap: () => _showRankLoreModal(context, userProvider),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── 3. MINIMAL 1-LINE DAILY INTEGRITY OATH TRIGGER ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: answered
                              ? (answerTrue ? AppColors.emeraldPrimary : AppColors.darkSubText)
                              : rankColor,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            answered
                                ? (answerTrue ? 'INTEGRITY: HONOR KEPT' : 'INTEGRITY: REFLECTION LOGGED')
                                : 'INTEGRITY: HONEST WORK TODAY?',
                            style: TextStyle(
                              color: answered
                                  ? (answerTrue ? AppColors.emeraldPrimary : AppColors.darkSubText)
                                  : Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        if (!answered) ...[
                          _CompactOathButton(
                            label: 'YES',
                            color: rankColor,
                            onTap: () => questProvider.answerOath(true),
                          ),
                          const SizedBox(width: 6),
                          _CompactOathButton(
                            label: 'NO',
                            color: AppColors.darkSubText,
                            onTap: () => _showOathReflectionDialog(context, rankColor),
                          ),
                        ] else
                          Icon(
                            answerTrue ? Icons.shield_rounded : Icons.info_outline_rounded,
                            color: answerTrue ? AppColors.emeraldPrimary : AppColors.darkSubText,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),

                // Floating Nav Dock spacing
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
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
                  fillColor: const Color(0xFF0D0E16),
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

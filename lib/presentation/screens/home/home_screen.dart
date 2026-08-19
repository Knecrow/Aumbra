import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../../core/constants/ranks.dart';
import '../../../core/constants/quotes.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/quest_card.dart';
import '../../widgets/rank_widgets.dart';

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = userProvider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final rankInfo = userProvider.currentRankInfo;
    final nextRank = userProvider.nextRankInfo;
    final rankColor = userProvider.currentRankColor;
    final quote = getDailyQuote();
    final dayNumber = userProvider.daysSinceStart;

    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? const Color(0xFF64748B) : AppColors.lightSubText;
    final dimColor = isDark ? const Color(0xFF334155) : AppColors.lightDimText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Container(
        decoration: isDark
            ? BoxDecoration(gradient: AppColors.buildRankAmbientGradient(rankColor))
            : null,
        child: FadeTransition(
          opacity: _headerAnim,
          child: CustomScrollView(
            slivers: [
              // ── SECTION 1: PROFILE HEADER ──
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left: Avatar + identity
                            RankGlowBadge(rankInfo: rankInfo, size: 54),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showEditProfileModal(context, userProvider),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            user.name.toUpperCase(),
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(Icons.edit_note_rounded, color: rankColor, size: 16),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rankInfo.name.toUpperCase(),
                                    style: TextStyle(
                                      color: rankColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Right: Sleek horizontal stats capsule
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0x880C1020),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _MiniStat(value: '${user.currentStreak}', icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF6D00)),
                                  const SizedBox(width: 8),
                                  Container(width: 1, height: 12, color: isDark ? const Color(0x22FFFFFF) : const Color(0x22000000)),
                                  const SizedBox(width: 8),
                                  _MiniStat(value: '${user.shieldsRemaining}/3', icon: Icons.shield_rounded, color: const Color(0xFF38BDF8)),
                                  const SizedBox(width: 8),
                                  Container(width: 1, height: 12, color: isDark ? const Color(0x22FFFFFF) : const Color(0x22000000)),
                                  const SizedBox(width: 8),
                                  _MiniStat(value: 'D$dayNumber', icon: Icons.bolt_rounded, color: const Color(0xFF10B981)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── RANK PROGRESS (inline, no card) ──
              if (nextRank != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: _buildRankProgress(
                      rankInfo, nextRank, rankColor, user, subColor, textColor, dimColor),
                  ),
                ),

              // ── MANTRA (borderless) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: _buildMantra(quote, dayNumber, rankColor, subColor),
                ),
              ),

              // ── QUEST HEADER ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        "Today's Quests",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      if (questProvider.state == QuestLoadingState.loaded)
                        Text(
                          '${questProvider.completedCount} / ${questProvider.totalCount}',
                          style: TextStyle(
                            color: subColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── QUEST LIST ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildQuestList(questProvider, rankColor),
                ),
              ),

              // ── SECTION 5: OATH ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _buildOathSection(questProvider),
                ),
              ),

              // ── SECTION 6: BOSS QUEST ──
              if (questProvider.bossQuest != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildBossQuestButton(questProvider, rankColor),
                  ),
                ),

              // ── BOTTOM PADDING ──
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }

  // ── RANK PROGRESS (borderless inline) ─────────────────────────────────────
  Widget _buildRankProgress(RankInfo rankInfo, RankInfo nextRank, Color rankColor,
      dynamic user, Color subColor, Color textColor, Color dimColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RankProgressBar(
                progress: rankInfo.completionsRequired > 0
                    ? user.rankCompletions / rankInfo.completionsRequired
                    : 1.0,
                color: rankColor,
                label: 'Completions',
                value: '${user.rankCompletions}/${rankInfo.completionsRequired}',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: RankProgressBar(
                progress: rankInfo.streakRequired > 0
                    ? user.currentStreak / rankInfo.streakRequired
                    : 1.0,
                color: rankColor.withValues(alpha: 0.75),
                label: 'Streak',
                value: '${user.currentStreak}/${rankInfo.streakRequired}',
              ),
            ),
          ],
        ),
        if (context.read<QuestProvider>().bossQuestUnlocked) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                'Boss encounter unlocked — scroll down',
                style: TextStyle(
                  color: rankColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMantra(dynamic quote, int dayNumber, Color rankColor, Color subColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 2,
          height: 36,
          decoration: BoxDecoration(
            color: rankColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '"${quote.text}"',
            style: TextStyle(
              color: subColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── QUEST LIST ──────────────────────────────────────────────────────────
  Widget _buildQuestList(QuestProvider questProvider, Color rankColor) {
    if (questProvider.state == QuestLoadingState.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            CircularProgressIndicator(color: rankColor, strokeWidth: 2),
            const SizedBox(height: 16),
            const Text(
              'System is loading your quests...',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (questProvider.todayQuests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(questProvider.todayQuests.length, (index) {
        final quest = questProvider.todayQuests[index];
        return QuestCard(
          quest: quest,
          index: index,
          onComplete: () => context.read<QuestProvider>().completeQuest(quest.id),
          onUncomplete: () => context.read<QuestProvider>().uncompleteQuest(quest.id),
        );
      }),
    );
  }

  // ── OATH SECTION (borderless) ─────────────────────────────────────────────
  Widget _buildOathSection(QuestProvider questProvider) {
    final answered = questProvider.oathAnswered;
    final answerTrue = questProvider.oathAnswer == true;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? const Color(0xFF64748B) : AppColors.lightSubText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Were you honest today?',
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (!answered)
          Row(
            children: [
              Expanded(
                child: _OathButton(
                  label: 'Yes',
                  icon: Icons.check_rounded,
                  color: const Color(0xFF00E5FF),
                  onTap: () => context.read<QuestProvider>().answerOath(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OathButton(
                  label: 'No',
                  icon: Icons.close_rounded,
                  color: subColor,
                  onTap: () => _showOathReflectionDialog(context),
                ),
              ),
            ],
          )
        else
          Text(
            answerTrue
                ? '✓ Integrity logged — your word stands.'
                : '— Noted. Reflection is growth.',
            style: TextStyle(
              color: answerTrue ? const Color(0xFF00E5FF) : subColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  // ── BOSS QUEST BUTTON ──────────────────────────────────────────────────────
  Widget _buildBossQuestButton(QuestProvider questProvider, Color rankColor) {
    final unlocked = questProvider.bossQuestUnlocked;
    if (!unlocked) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showBossQuestDialog(questProvider, rankColor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: rankColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: rankColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚔️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              'Boss Quest — Challenge Now',
              style: TextStyle(
                color: rankColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOathReflectionDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x22FFFFFF), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: Color(0xFF00E5FF), size: 18),
            SizedBox(width: 8),
            Text('Reflection',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'The system respects your honesty. What will you do differently tomorrow?',
              style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Your reflection...',
                hintStyle: const TextStyle(color: Color(0xFF555555)),
                filled: true,
                fillColor: const Color(0x0DFFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0x14FFFFFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Color(0x14FFFFFF)),
                ),
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
            child: const Text('Submit', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.name);
    final careerCtrl = TextEditingController(text: user.career);
    final interestsCtrl = TextEditingController(text: user.interests);
    double fitness = user.fitnessLevel.toDouble();
    bool hasComp = user.hasComputer;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rankColor = userProvider.currentRankColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0F1123) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PLAYER DOSSIER',
                          style: TextStyle(
                            color: rankColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Codename / Name',
                        labelStyle: TextStyle(color: rankColor),
                        filled: true,
                        fillColor: isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: careerCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Career / Field of Study',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        filled: true,
                        fillColor: isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: interestsCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Interests & Focus Areas',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                        filled: true,
                        fillColor: isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Fitness Level: ${fitness.round()}/10',
                        style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                    Slider(
                      value: fitness,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: rankColor,
                      onChanged: (val) => setModalState(() => fitness = val),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Computer Access',
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                        Switch(
                          value: hasComp,
                          activeThumbColor: rankColor,
                          onChanged: (val) => setModalState(() => hasComp = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rankColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () async {
                          await userProvider.updateProfile(
                            name: nameCtrl.text.trim(),
                            career: careerCtrl.text.trim(),
                            interests: interestsCtrl.text.trim(),
                            fitnessLevel: fitness.round(),
                            hasComputer: hasComp,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text('UPDATE DOSSIER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBossQuestDialog(QuestProvider questProvider, Color rankColor) {
    final quest = questProvider.bossQuest;
    if (quest == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: rankColor.withValues(alpha: 0.4), width: 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⚔️ BOSS QUEST',
                style: TextStyle(color: rankColor, fontSize: 11, letterSpacing: 2)),
            const SizedBox(height: 6),
            Text(quest.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          quest.description,
          style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Later', style: TextStyle(color: rankColor.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRankUpCelebration(questProvider, rankColor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: rankColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('COMPLETE ⚡', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  void _showRankUpCelebration(QuestProvider questProvider, Color rankColor) {
    final nextRank = context.read<UserProvider>().nextRankInfo;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: nextRank?.color ?? rankColor, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (ctx, v, child) => Transform.scale(scale: v, child: child),
              child: Icon(Icons.workspace_premium_rounded, size: 64, color: nextRank?.color ?? rankColor),
            ),
            const SizedBox(height: 20),
            Text(
              'RANK UP!',
              style: TextStyle(
                color: nextRank?.color ?? rankColor,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are now ${nextRank?.name ?? "ABSOLUTE"}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<QuestProvider>().completeBossQuest();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: nextRank?.color ?? rankColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('ACCEPT ASCENSION',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── HELPER WIDGETS ──────────────────────────────────────────────────────────


class _MiniStat extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStat({required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _OathButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OathButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<_OathButton> createState() => _OathButtonState();
}

class _OathButtonState extends State<_OathButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 90), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.color, size: 16),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

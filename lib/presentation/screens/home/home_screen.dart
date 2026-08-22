import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/quest_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/tactical_panel.dart';
import '../../widgets/tactical_hud_widgets.dart';
import '../../widgets/valorant_ability_card.dart';
import '../../widgets/valorant_inspect_modal.dart';
import '../../widgets/tactical_oath_modal.dart';
import '../../widgets/tactical_dialogs.dart';
import '../../widgets/tactical_particle_canvas.dart';
import '../../widgets/hex_quest_card.dart'; // for HexagonClipper

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerAnim;
  final List<Widget> _popups = [];

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestProvider>().loadTodayQuests();
    });
  }

  void _triggerXpPopup(BuildContext context, String text, Color color) {
    final size = MediaQuery.of(context).size;
    final pos = Offset(size.width / 2 - 40, size.height * 0.42);
    final key = UniqueKey();
    setState(() {
      _popups.add(
        FloatingRadianitePopup(
          key: key,
          origin: pos,
          text: text,
          color: color,
          onDismiss: () {
            if (mounted) {
              setState(() {
                _popups.removeWhere((p) => p.key == key);
              });
            }
          },
        ),
      );
    });
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'DAWN FOCUS · ACT 01';
    if (hour >= 12 && hour < 17) return 'MIDDAY MOMENTUM · ACT 01';
    if (hour >= 17 && hour < 22) return 'EVENING ASCENSION · ACT 01';
    return 'NIGHT REVIEW · ACT 01';
  }

  IconData _getRankAvatarIcon(int rank) {
    switch (rank) {
      case 1: return Icons.auto_awesome_rounded;
      case 2: return Icons.explore_rounded;
      case 3: return Icons.bolt_rounded;
      case 4: return Icons.local_fire_department_rounded;
      case 5: return Icons.north_east_rounded;
      case 6: return Icons.shield_rounded;
      case 7: return Icons.diamond_rounded;
      case 8: return Icons.menu_book_rounded;
      case 9: return Icons.wb_sunny_rounded;
      case 10: return Icons.all_inclusive_rounded;
      case 11: return Icons.hourglass_empty_rounded;
      case 12: return Icons.flare_rounded;
      case 13: return Icons.stars_rounded;
      case 14: return Icons.military_tech_rounded;
      case 15: return Icons.workspace_premium_rounded;
      default: return Icons.auto_awesome_rounded;
    }
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

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: TacticalParticleCanvas(
        rankColor: rankColor,
        particleCount: 24,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.buildRankAmbientGradient(rankColor),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                FadeTransition(
                  opacity: _headerAnim,
                  child: Column(
                    children: [
                      // ── 1. RIOT VALORANT TACTICAL TOP HUD DECK ───────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                        child: TacticalPanel(
                          rankColor: rankColor,
                          showHeader: true,
                          tacticalTag: _getTimeGreeting(),
                          chamferSize: 14.0,
                          chamferCorner: ChamferCorner.all,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Top Row: Avatar, Name, Shields, Streak ───
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left: Faceted Avatar with Progress Ring + Name + Rank Badge
                                  GestureDetector(
                                    onTap: () => showTacticalEditProfileDialog(context, userProvider, rankColor),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Faceted Avatar with Ascension Progress Ring in Rank Color
                                        SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Circular Progress Ring
                                              CircularProgressIndicator(
                                                value: ascProgress,
                                                strokeWidth: 2.5,
                                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                                valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                                              ),
                                              // Tactical Inner Hex / Diamond Disc
                                                  Container(
                                                    width: 38,
                                                    height: 38,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF07090E),
                                                      border: Border.all(
                                                        color: rankColor.withValues(alpha: 0.50),
                                                        width: 1.2,
                                                      ),
                                                    ),
                                                    child: ClipPath(
                                                      clipper: const HexagonClipper(cornerRadius: 8),
                                                      child: Container(
                                                        color: const Color(0xFF07090E),
                                                        child: Center(
                                                          child: Icon(
                                                            _getRankAvatarIcon(rankInfo.rankNumber),
                                                            color: lightRankColor,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Name & Highlighted Tactical Rank Badge
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              user.name.toUpperCase(),
                                              style: GoogleFonts.rajdhani(
                                                color: AppColors.darkText,
                                                fontSize: 19,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.0,
                                                height: 1.0,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () => showTacticalRankLoreDialog(context, userProvider),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: rankColor.withValues(alpha: 0.15),
                                                  border: Border.all(
                                                    color: rankColor.withValues(alpha: 0.50),
                                                    width: 0.9,
                                                  ),
                                                ),
                                                child: Text(
                                                  rankInfo.name.toUpperCase(),
                                                  style: GoogleFonts.spaceMono(
                                                    color: lightRankColor,
                                                    fontSize: 9.0,
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

                                  // Right: Armor Shields & Streak Pods
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TacticalShieldsPod(
                                        shieldsRemaining: user.shieldsRemaining,
                                        rankColor: rankColor,
                                        onTap: () => showTacticalShieldDialog(context, user.shieldsRemaining, rankColor),
                                      ),
                                      const SizedBox(width: 6),
                                      TacticalStreakPod(
                                        streakDays: user.currentStreak,
                                        rankColor: rankColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // ── Bottom Segmented Energy Meter ──
                              TacticalSegmentedBar(
                                progress: ascProgress,
                                rankColor: rankColor,
                                label: '',
                                readoutText: '$userCompletions / $completionsReq DAYS',
                                totalSegments: 14,
                                height: 7.0,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── 2. VALORANT TACTICAL ABILITY & PROTOCOL LOADOUT ─────────
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            // Section Header Tag
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'DAILY PILLARS',
                                  style: GoogleFonts.spaceMono(
                                    color: AppColors.darkSubText,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // ── Empty state ──
                            if (questProvider.todayQuests.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    Icon(Icons.radar_rounded,
                                        color: rankColor.withValues(alpha: 0.4), size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      'NO ACTIVE PROTOCOLS',
                                      style: GoogleFonts.spaceMono(
                                        color: AppColors.darkSubText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Quests load at the start of each day',
                                      style: GoogleFonts.spaceMono(
                                        color: AppColors.darkDimText,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Main Left Power Circuit Backbone Layout ──
                            ...questProvider.todayQuests.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final quest = entry.value;

                              // Check if all quests in the chain above this one are completed
                              final isPoweredFromAbove = idx == 0
                                  ? true
                                  : questProvider.todayQuests.take(idx).every((q) => q.isCompleted);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: TacticalLeftBackboneSegment(
                                  isTop: idx == 0,
                                  isQuestCompleted: quest.isCompleted,
                                  isPoweredFromAbove: isPoweredFromAbove,
                                  rankColor: rankColor,
                                  child: ValorantAbilityCard(
                                    quest: quest,
                                    index: idx,
                                    rankColor: rankColor,
                                    onTap: () {
                                      showValorantInspectModal(
                                        context: context,
                                        quest: quest,
                                        index: idx,
                                        rankColor: rankColor,
                                        onComplete: () {
                                          if (quest.isCompleted) {
                                            questProvider.uncompleteQuest(quest.id);
                                          } else {
                                            questProvider.completeQuest(quest.id);
                                            _triggerXpPopup(context, '+25 RAD', rankColor);
                                          }
                                        },
                                        onSwapQuest: () {},
                                      );
                                    },
                                     onLongPress: () {
                                       if (quest.isCompleted) {
                                         questProvider.uncompleteQuest(quest.id);
                                       } else {
                                         questProvider.completeQuest(quest.id);
                                         _triggerXpPopup(context, '+25 RAD', rankColor);
                                       }
                                     },
                                  ),
                                ),
                              );
                            }),

                            // ── The Apex 5th Card: The Final Key / Honesty Oath Reactor (Left Backbone Input) ──
                            TacticalLeftBackboneOathWrapper(
                              isFullCharge: questProvider.todayQuests.where((q) => q.isCompleted).length >=
                                  questProvider.todayQuests.length.clamp(1, 4),
                              rankColor: rankColor,
                              child: ValorantUltimateCard(
                                isAnswered: answered,
                                isHonored: answerTrue,
                                rankColor: rankColor,
                                completedCount: questProvider.todayQuests.where((q) => q.isCompleted).length,
                                totalQuests: questProvider.todayQuests.length.clamp(1, 4),
                                onTap: () => showTacticalHonestyOathModal(
                                  context: context,
                                  questProvider: questProvider,
                                  rankColor: rankColor,
                                ),
                              ),
                            ),

                            // Boss Quest Card if unlocked
                            if (questProvider.bossQuestUnlocked && questProvider.bossQuest != null) ...[
                              const SizedBox(height: 12),
                              TacticalPanel(
                                rankColor: const Color(0xFFFF4655), // Valorant Red
                                showHeader: true,
                                tacticalTag: 'WEEKLY ASCENSION CHALLENGE',
                                statusBadge: 'CRITICAL',
                                chamferSize: 12.0,
                                onTap: () => showTacticalBossDialog(context, questProvider, rankColor),
                                child: Row(
                                  children: [
                                    const Icon(Icons.military_tech_rounded, color: Color(0xFFFF4655), size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            questProvider.bossQuest!.title.toUpperCase(),
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            'TAP TO CONQUER BOSS CHALLENGE',
                                            style: GoogleFonts.spaceMono(
                                              color: const Color(0xFFFF8A94),
                                              fontSize: 9.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ..._popups,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

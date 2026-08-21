import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/quest_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ranks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. MATHEMATICALLY PERFECT ROUNDED POINT-TOPPED HEXAGON PATH BUILDER
// ─────────────────────────────────────────────────────────────────────────────

Path buildRoundedPointyHexPath(Rect rect, {double cornerRadius = 14.0}) {
  final path = Path();
  final w = rect.width;
  final h = rect.height;
  final cx = rect.left + w / 2;
  final cy = rect.top + h / 2;

  // 6 vertices of a point-topped hexagon inscribed in rect
  // V0: Top center
  // V1: Top right
  // V2: Bottom right
  // V3: Bottom center
  // V4: Bottom left
  // V5: Top left
  final points = <Offset>[
    Offset(cx, rect.top),                          // V0 (top point)
    Offset(rect.right, rect.top + h * 0.25),       // V1 (top right)
    Offset(rect.right, rect.bottom - h * 0.25),    // V2 (bottom right)
    Offset(cx, rect.bottom),                       // V3 (bottom point)
    Offset(rect.left, rect.bottom - h * 0.25),     // V4 (bottom left)
    Offset(rect.left, rect.top + h * 0.25),        // V5 (top left)
  ];

  final cr = cornerRadius.clamp(2.0, 20.0);

  for (int i = 0; i < 6; i++) {
    final prev = points[(i + 5) % 6];
    final curr = points[i];
    final next = points[(i + 1) % 6];

    // Inward and outward unit vectors
    final dIn = (curr - prev);
    final lenIn = dIn.distance;
    final uIn = dIn / (lenIn > 0 ? lenIn : 1);

    final dOut = (next - curr);
    final lenOut = dOut.distance;
    final uOut = dOut / (lenOut > 0 ? lenOut : 1);

    final pStart = curr - uIn * math.min(cr, lenIn * 0.45);
    final pEnd = curr + uOut * math.min(cr, lenOut * 0.45);

    if (i == 0) {
      path.moveTo(pStart.dx, pStart.dy);
    } else {
      path.lineTo(pStart.dx, pStart.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, pEnd.dx, pEnd.dy);
  }

  path.close();
  return path;
}

class HexagonClipper extends CustomClipper<Path> {
  final double cornerRadius;
  const HexagonClipper({this.cornerRadius = 14.0});

  @override
  Path getClip(Size size) {
    return buildRoundedPointyHexPath(Offset.zero & size, cornerRadius: cornerRadius);
  }

  @override
  bool shouldReclip(covariant HexagonClipper oldClipper) =>
      oldClipper.cornerRadius != cornerRadius;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. HEXAGON PAINTER (Background Gradient + Glowing Neon Border)
// ─────────────────────────────────────────────────────────────────────────────

class HexagonPainter extends CustomPainter {
  final Color borderColor;
  final Color baseColor;
  final Color glowColor;
  final double borderWidth;
  final double cornerRadius;
  final bool isCompleted;
  final bool isSelected;
  final bool isBoss;

  HexagonPainter({
    required this.borderColor,
    required this.baseColor,
    required this.glowColor,
    this.borderWidth = 1.6,
    this.cornerRadius = 14.0,
    this.isCompleted = false,
    this.isSelected = false,
    this.isBoss = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = buildRoundedPointyHexPath(rect, cornerRadius: cornerRadius);

    // 1. Ambient Drop Shadow / Glow
    if (isSelected || isBoss || isCompleted) {
      final shadowPaint = Paint()
        ..color = glowColor.withValues(alpha: isSelected ? 0.35 : (isBoss ? 0.28 : 0.18))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, isSelected ? 16 : 10);
      canvas.drawPath(path, shadowPaint);
    } else {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path, shadowPaint);
    }

    // 2. Fill Gradient
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isCompleted
          ? [
              const Color(0xFF08140E),
              const Color(0xFF030805),
            ]
          : isBoss
              ? [
                  baseColor.withValues(alpha: 0.26),
                  const Color(0xFF101010),
                  const Color(0xFF040404),
                ]
              : isSelected
                  ? [
                      baseColor.withValues(alpha: 0.22),
                      const Color(0xFF141414),
                      const Color(0xFF060606),
                    ]
                  : [
                      const Color(0xFF121212),
                      const Color(0xFF0A0A0A),
                      const Color(0xFF020202),
                    ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3. Subtle Top-Edge Specular Glass Arc
    final highlightGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: isSelected ? 0.20 : 0.10),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45],
    );
    final highlightPaint = Paint()
      ..shader = highlightGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, highlightPaint);

    // 4. Glowing Stroke Border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant HexagonPainter old) {
    return old.borderColor != borderColor ||
        old.baseColor != baseColor ||
        old.glowColor != glowColor ||
        old.isSelected != isSelected ||
        old.isCompleted != isCompleted ||
        old.isBoss != isBoss;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. INDIVIDUAL HEXAGONAL QUEST TILE
// ─────────────────────────────────────────────────────────────────────────────

class HexQuestTile extends StatefulWidget {
  final QuestModel quest;
  final int index;
  final bool isSelected;
  final Color rankColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const HexQuestTile({
    super.key,
    required this.quest,
    required this.index,
    this.isSelected = false,
    required this.rankColor,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<HexQuestTile> createState() => _HexQuestTileState();
}

class _HexQuestTileState extends State<HexQuestTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _touchCtrl;
  late Animation<double> _touchScale;

  @override
  void initState() {
    super.initState();
    _touchCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _touchScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _touchCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _touchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.quest.isCompleted;
    final isBoss = widget.quest.isBossQuest;
    final categoryColor = AppColors.getCategoryColor(widget.quest.category);
    final accentColor = isBoss ? widget.rankColor : categoryColor;
    final lightRankColor = widget.isSelected ? Colors.white : const Color(0xFF90D9E6);

    // Glowing cyan/teal theme by default, rankColor on selected/boss
    final borderColor = isCompleted
        ? AppColors.emeraldPrimary.withValues(alpha: 0.8)
        : widget.isSelected
            ? const Color(0xFF4EEBFB)
            : isBoss
                ? widget.rankColor.withValues(alpha: 0.9)
                : const Color(0xFF285465);

    final glowColor = isCompleted
        ? AppColors.emeraldPrimary
        : widget.isSelected
            ? const Color(0xFF00E5FF)
            : isBoss
                ? widget.rankColor
                : const Color(0xFF00E5FF);

    const hexW = 104.0;
    const hexH = 118.0;

    return GestureDetector(
      onTapDown: (_) => _touchCtrl.forward(),
      onTapUp: (_) {
        _touchCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _touchCtrl.reverse(),
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _touchScale,
        child: SizedBox(
          width: hexW,
          height: hexH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hexagon Canvas
              Positioned.fill(
                child: CustomPaint(
                  painter: HexagonPainter(
                    borderColor: borderColor,
                    baseColor: accentColor,
                    glowColor: glowColor,
                    borderWidth: widget.isSelected ? 2.2 : (isCompleted ? 1.8 : 1.4),
                    cornerRadius: 14.0,
                    isCompleted: isCompleted,
                    isSelected: widget.isSelected,
                    isBoss: isBoss,
                  ),
                ),
              ),

              // Center 2D Sci-Fi Icon
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tactical Protocol Index (Valorant Micro-code)
                    Text(
                      '// 0${widget.index + 1} ${widget.quest.category.toUpperCase()}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: isCompleted
                            ? AppColors.emeraldPrimary.withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: isCompleted
                          ? Icon(
                              Icons.check_circle_rounded,
                              key: const ValueKey('done'),
                              size: 34,
                              color: AppColors.emeraldPrimary,
                            )
                          : Icon(
                              isBoss
                                  ? Icons.military_tech_rounded
                                  : AppColors.getCategoryIconData(widget.quest.category),
                              key: ValueKey(widget.quest.category),
                              size: 32,
                              color: lightRankColor,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3.5. HONESTY QUEST HEXAGONAL TILE
// ─────────────────────────────────────────────────────────────────────────────

class HexHonestyTile extends StatefulWidget {
  final bool isAnswered;
  final bool isHonored;
  final Color rankColor;
  final VoidCallback onTap;

  const HexHonestyTile({
    super.key,
    required this.isAnswered,
    required this.isHonored,
    required this.rankColor,
    required this.onTap,
  });

  @override
  State<HexHonestyTile> createState() => _HexHonestyTileState();
}

class _HexHonestyTileState extends State<HexHonestyTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _touchCtrl;
  late Animation<double> _touchScale;

  @override
  void initState() {
    super.initState();
    _touchCtrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _touchScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _touchCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _touchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const hexW = 104.0;
    const hexH = 118.0;

    final borderColor = widget.isAnswered
        ? (widget.isHonored
            ? AppColors.emeraldPrimary.withValues(alpha: 0.85)
            : const Color(0xFFFF9100).withValues(alpha: 0.85))
        : widget.rankColor.withValues(alpha: 0.90);

    final glowColor = widget.isAnswered
        ? (widget.isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF9100))
        : widget.rankColor;

    return GestureDetector(
      onTapDown: (_) => _touchCtrl.forward(),
      onTapUp: (_) {
        _touchCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _touchCtrl.reverse(),
      child: ScaleTransition(
        scale: _touchScale,
        child: SizedBox(
          width: hexW,
          height: hexH,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Hexagon Canvas
              Positioned.fill(
                child: CustomPaint(
                  painter: HexagonPainter(
                    borderColor: borderColor,
                    baseColor: widget.rankColor,
                    glowColor: glowColor,
                    borderWidth: 2.2,
                    cornerRadius: 14.0,
                    isCompleted: widget.isAnswered,
                    isSelected: false,
                    isBoss: true,
                  ),
                ),
              ),

              // Icon & Tactical Label
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '// OATH',
                      style: GoogleFonts.spaceMono(
                        fontSize: 7.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: widget.isAnswered
                            ? (widget.isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      widget.isAnswered
                          ? (widget.isHonored ? Icons.shield_rounded : Icons.shield_outlined)
                          : Icons.shield_rounded,
                      size: 32,
                      color: widget.isAnswered
                          ? (widget.isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
                          : widget.rankColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. HONEYCOMB STAGGERED MESH GRID (Matches Reference Screenshot Layout)
// ─────────────────────────────────────────────────────────────────────────────

class HexQuestHoneycombGrid extends StatefulWidget {
  final List<QuestModel> quests;
  final QuestModel? bossQuest;
  final bool bossQuestUnlocked;
  final bool oathAnswered;
  final bool oathHonored;
  final VoidCallback? onOathTap;
  final Color rankColor;
  final RankInfo rankInfo;
  final Function(String questId) onComplete;
  final Function(String questId) onUncomplete;
  final VoidCallback? onBossChallenge;

  const HexQuestHoneycombGrid({
    super.key,
    required this.quests,
    this.bossQuest,
    this.bossQuestUnlocked = false,
    this.oathAnswered = false,
    this.oathHonored = false,
    this.onOathTap,
    required this.rankColor,
    required this.rankInfo,
    required this.onComplete,
    required this.onUncomplete,
    this.onBossChallenge,
  });

  @override
  State<HexQuestHoneycombGrid> createState() => _HexQuestHoneycombGridState();
}

class _HexQuestHoneycombGridState extends State<HexQuestHoneycombGrid> {
  int? _selectedQuestIndex;

  void _showQuestDetailSheet(BuildContext context, QuestModel quest, int index) {
    HapticFeedback.mediumImpact();
    setState(() => _selectedQuestIndex = index);

    final isCompleted = quest.isCompleted;
    final isBoss = quest.isBossQuest;
    final categoryColor = AppColors.getCategoryColor(quest.category);
    final accentColor = isBoss ? widget.rankColor : categoryColor;

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
              color: accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row with Category & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBoss
                              ? Icons.military_tech_rounded
                              : AppColors.getCategoryIconData(quest.category),
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBoss ? 'BOSS' : 'OBJECTIVE',
                          style: GoogleFonts.inter(
                            color: accentColor,
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

              // Title
              Text(
                quest.title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                  height: 1.25,
                ),
              ),

              if (quest.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quest.description,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF8E9BA6),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // CTA Action Button (Sporty Pill)
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  if (isCompleted) {
                    widget.onUncomplete(quest.id);
                  } else {
                    HapticFeedback.heavyImpact();
                    widget.onComplete(quest.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? null
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              accentColor,
                              AppColors.getDeepVariant(accentColor),
                            ],
                          ),
                    color: isCompleted ? const Color(0xFF16232B) : null,
                    borderRadius: BorderRadius.circular(50),
                    border: isCompleted
                        ? Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.4), width: 1.0)
                        : null,
                    boxShadow: isCompleted
                        ? null
                        : [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isCompleted ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                          color: isCompleted ? Colors.white : Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCompleted ? 'MARK INCOMPLETE' : 'COMPLETE PROTOCOL',
                          style: GoogleFonts.inter(
                            color: isCompleted ? Colors.white : Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allQuests = <QuestModel>[...widget.quests];
    if (widget.bossQuest != null && widget.bossQuestUnlocked) {
      allQuests.insert(0, widget.bossQuest!);
    }

    if (allQuests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Text(
            'All protocols completed for today.',
            style: GoogleFonts.inter(color: AppColors.darkSubText, fontSize: 13),
          ),
        ),
      );
    }

    // ── 2 – 1 – 2 INVERTED HOURGLASS LAYOUT ─────────────────────────────
    // Row 0: Quest 0 & Quest 1
    // Row 1: Quest 2
    // Row 2: Quest 3 & Honesty Oath
    // (If Boss Quest is unlocked, it sits as Crown Node on top)
    final hasBoss = widget.bossQuest != null && widget.bossQuestUnlocked;
    final boss = widget.bossQuest;

    final q0 = allQuests.isNotEmpty ? allQuests[0] : null;
    final q1 = allQuests.length > 1 ? allQuests[1] : null;
    final q2 = allQuests.length > 2 ? allQuests[2] : null;
    final q3 = allQuests.length > 3 ? allQuests[3] : null;

    Widget buildTile(QuestModel quest, int index) {
      return HexQuestTile(
        quest: quest,
        index: index,
        isSelected: _selectedQuestIndex == index,
        rankColor: widget.rankColor,
        onTap: () => _showQuestDetailSheet(context, quest, index),
        onLongPress: () {
          HapticFeedback.heavyImpact();
          if (quest.isCompleted) {
            widget.onUncomplete(quest.id);
          } else {
            widget.onComplete(quest.id);
          }
        },
      );
    }

    const double wingGap = 64.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional Boss Crown Node if unlocked
        if (hasBoss && boss != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTile(boss, 99),
              ],
            ),
          ),

        // ── TOP FLANK ROW: 2 WIDE NODES (Quest 0 & Quest 1) ─────────────────
        if (q0 != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTile(q0, 0),
                if (q1 != null) ...[
                  const SizedBox(width: wingGap),
                  buildTile(q1, 1),
                ],
              ],
            ),
          ),

        // ── MID CENTER PINCH NODE: (Honesty Oath Quest) ─────────────────────
        Transform.translate(
          offset: const Offset(0, -6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HexHonestyTile(
                isAnswered: widget.oathAnswered,
                isHonored: widget.oathHonored,
                rankColor: widget.rankColor,
                onTap: () => widget.onOathTap?.call(),
              ),
            ],
          ),
        ),

        // ── BOTTOM FLANK ROW: 2 WIDE NODES (Quest 2 & Quest 3) ──────────────
        if (q2 != null)
          Transform.translate(
            offset: const Offset(0, -12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTile(q2, 2),
                if (q3 != null) ...[
                  const SizedBox(width: wingGap),
                  buildTile(q3, 3),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

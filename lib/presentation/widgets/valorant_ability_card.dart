import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/quest_model.dart';
import '../../core/constants/app_colors.dart';
import 'tactical_icons.dart';

/// Keybind letters mapped to the 4 protocol abilities
const List<String> kAbilityKeybinds = ['Q', 'E', 'C', 'F'];

/// A Riot Valorant inspired full-width horizontal Tactical Ability Card
class ValorantAbilityCard extends StatefulWidget {
  final QuestModel quest;
  final int index;
  final bool isSelected;
  final Color rankColor;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ValorantAbilityCard({
    super.key,
    required this.quest,
    required this.index,
    this.isSelected = false,
    required this.rankColor,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<ValorantAbilityCard> createState() => _ValorantAbilityCardState();
}

class _ValorantAbilityCardState extends State<ValorantAbilityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _touchCtrl;
  late Animation<double> _touchScale;

  @override
  void initState() {
    super.initState();
    _touchCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _touchScale = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final accentColor = isCompleted
        ? widget.rankColor
        : (isBoss ? widget.rankColor : categoryColor);

    return GestureDetector(
      onTapDown: (_) => _touchCtrl.forward(),
      onTapUp: (_) {
        _touchCtrl.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _touchCtrl.reverse(),
      onLongPress: () {
        HapticFeedback.heavyImpact();
        widget.onLongPress();
      },
      child: ScaleTransition(
        scale: _touchScale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isCompleted
                ? widget.rankColor.withValues(alpha: 0.08)
                : (widget.isSelected ? const Color(0xFF141924) : const Color(0xFF0C0E15)),
            border: Border.all(
              color: isCompleted
                  ? widget.rankColor.withValues(alpha: 0.85)
                  : (widget.isSelected ? accentColor : accentColor.withValues(alpha: 0.35)),
              width: isCompleted || widget.isSelected ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? widget.rankColor : accentColor)
                    .withValues(alpha: isCompleted ? 0.22 : 0.08),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Left: Sliced Icon Plate ──
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? widget.rankColor.withValues(alpha: 0.15)
                      : const Color(0xFF07090F),
                  border: Border.all(
                    color: isCompleted
                        ? widget.rankColor.withValues(alpha: 0.80)
                        : accentColor.withValues(alpha: 0.50),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: TacticalGlyph.fromCategory(
                    widget.quest.category,
                    color: isCompleted ? widget.rankColor : accentColor,
                    size: 20,
                    isCompleted: isCompleted,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Center: Title & Category Metadata ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? widget.rankColor.withValues(alpha: 0.20)
                                : accentColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: isCompleted
                                  ? widget.rankColor.withValues(alpha: 0.60)
                                  : accentColor.withValues(alpha: 0.40),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            widget.quest.category.toUpperCase(),
                            style: GoogleFonts.spaceMono(
                              color: isCompleted ? widget.rankColor : accentColor,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCompleted ? 'PILLAR COMPLETED' : 'DAILY PILLAR',
                          style: GoogleFonts.spaceMono(
                            color: isCompleted ? widget.rankColor : AppColors.darkSubText,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.quest.title.toUpperCase(),
                      style: GoogleFonts.rajdhani(
                        color: AppColors.darkText,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── Right: Status Tag ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? widget.rankColor.withValues(alpha: 0.15)
                      : accentColor.withValues(alpha: 0.10),
                  border: Border.all(
                    color: isCompleted
                        ? widget.rankColor.withValues(alpha: 0.70)
                        : accentColor.withValues(alpha: 0.40),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCompleted ? 'COMPLETED' : '+25 RAD',
                      style: GoogleFonts.spaceMono(
                        color: isCompleted ? widget.rankColor : accentColor,
                        fontSize: 9.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_rounded, color: widget.rankColor, size: 11),
                    ],
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

/// Tactical Left Power Circuit Backbone Segment (Static clean illumination in rankColor)
class TacticalLeftBackboneSegment extends StatelessWidget {
  final bool isTop;
  final bool isQuestCompleted;
  final bool isPoweredFromAbove;
  final Color rankColor;
  final Widget child;

  const TacticalLeftBackboneSegment({
    super.key,
    required this.isTop,
    required this.isQuestCompleted,
    required this.isPoweredFromAbove,
    this.rankColor = AppColors.goldPrimary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeftBackboneRowPainter(
        isTop: isTop,
        isQuestCompleted: isQuestCompleted,
        isPoweredFromAbove: isPoweredFromAbove,
        rankColor: rankColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0), // 24dp gutter for the main left backbone
        child: child,
      ),
    );
  }
}

class _LeftBackboneRowPainter extends CustomPainter {
  final bool isTop;
  final bool isQuestCompleted;
  final bool isPoweredFromAbove;
  final Color rankColor;

  _LeftBackboneRowPainter({
    required this.isTop,
    required this.isQuestCompleted,
    required this.isPoweredFromAbove,
    required this.rankColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const backboneX = 9.0;
    final branchY = size.height * 0.5;
    final cardLeftX = 24.0;

    const inactiveColor = Color(0xFF1E2430);
    final activeColor = rankColor;

    // 1. Top backbone vertical line (active only if power reached this node from above)
    if (!isTop) {
      if (isPoweredFromAbove) {
        final glowPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.40)
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
        canvas.drawLine(const Offset(backboneX, 0), Offset(backboneX, branchY), glowPaint);
      }
      final topPaint = Paint()
        ..color = isPoweredFromAbove ? activeColor : inactiveColor
        ..strokeWidth = isPoweredFromAbove ? 2.0 : 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(backboneX, 0), Offset(backboneX, branchY), topPaint);
    }

    // 2. Horizontal Feeder Branch (from Card left edge to Backbone junction)
    if (isQuestCompleted) {
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.40)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawLine(Offset(backboneX, branchY), Offset(cardLeftX, branchY), glowPaint);
    }
    final branchPaint = Paint()
      ..color = isQuestCompleted ? activeColor : inactiveColor
      ..strokeWidth = isQuestCompleted ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(backboneX, branchY), Offset(cardLeftX, branchY), branchPaint);

    // 3. Bottom backbone vertical line (ONLY transmits downwards if power arrived from above AND THIS quest is completed)
    final isTransmittingDown = isPoweredFromAbove && isQuestCompleted;
    if (isTransmittingDown) {
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.40)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawLine(Offset(backboneX, branchY), Offset(backboneX, size.height + 10.0), glowPaint);
    }
    final bottomPaint = Paint()
      ..color = isTransmittingDown ? activeColor : inactiveColor
      ..strokeWidth = isTransmittingDown ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(backboneX, branchY), Offset(backboneX, size.height + 10.0), bottomPaint);

    // 4. Diamond Junction Pip at (backboneX, branchY)
    final isNodeActive = isQuestCompleted;
    final nodeFill = Paint()
      ..color = isNodeActive ? activeColor : const Color(0xFF0C0E14)
      ..style = PaintingStyle.fill;
    final nodeStroke = Paint()
      ..color = isNodeActive ? activeColor : const Color(0xFF2B3342)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(backboneX, branchY - 3.5)
      ..lineTo(backboneX + 3.5, branchY)
      ..lineTo(backboneX, branchY + 3.5)
      ..lineTo(backboneX - 3.5, branchY)
      ..close();

    canvas.drawPath(path, nodeFill);
    canvas.drawPath(path, nodeStroke);
  }

  @override
  bool shouldRepaint(covariant _LeftBackboneRowPainter old) {
    return old.isTop != isTop ||
        old.isQuestCompleted != isQuestCompleted ||
        old.isPoweredFromAbove != isPoweredFromAbove ||
        old.rankColor != rankColor;
  }
}

/// Tactical Left Power Circuit Backbone Wrapper for Honesty Oath
class TacticalLeftBackboneOathWrapper extends StatelessWidget {
  final bool isFullCharge;
  final Color rankColor;
  final Widget child;

  const TacticalLeftBackboneOathWrapper({
    super.key,
    required this.isFullCharge,
    this.rankColor = AppColors.goldPrimary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeftBackboneOathPainter(
        isFullCharge: isFullCharge,
        rankColor: rankColor,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: child,
      ),
    );
  }
}

class _LeftBackboneOathPainter extends CustomPainter {
  final bool isFullCharge;
  final Color rankColor;

  _LeftBackboneOathPainter({
    required this.isFullCharge,
    required this.rankColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const backboneX = 9.0;
    const cardLeftX = 24.0;
    const branchY = 32.0;

    const inactiveColor = Color(0xFF1E2430);
    final activeColor = rankColor;

    final isPowered = isFullCharge; // ONLY power the Oath line when 100% of quests are completed

    // 1. Vertical line descending from top of gutter to the input port
    if (isPowered) {
      final glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.40)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
      canvas.drawLine(const Offset(backboneX, -10.0), const Offset(backboneX, branchY), glowPaint);
      canvas.drawLine(const Offset(backboneX, branchY), const Offset(cardLeftX, branchY), glowPaint);
    }

    final linePaint = Paint()
      ..color = isPowered ? activeColor : inactiveColor
      ..strokeWidth = isPowered ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(backboneX, -10.0), const Offset(backboneX, branchY), linePaint);
    canvas.drawLine(const Offset(backboneX, branchY), const Offset(cardLeftX, branchY), linePaint);

    // 2. Diamond Node at the input junction
    final nodeFill = Paint()
      ..color = isPowered ? activeColor : const Color(0xFF0C0E14)
      ..style = PaintingStyle.fill;
    final nodeStroke = Paint()
      ..color = isPowered ? activeColor : const Color(0xFF2B3342)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(backboneX, branchY - 3.5)
      ..lineTo(backboneX + 3.5, branchY)
      ..lineTo(backboneX, branchY + 3.5)
      ..lineTo(backboneX - 3.5, branchY)
      ..close();

    canvas.drawPath(path, nodeFill);
    canvas.drawPath(path, nodeStroke);
  }

  @override
  bool shouldRepaint(covariant _LeftBackboneOathPainter old) {
    return old.isFullCharge != isFullCharge || old.rankColor != rankColor;
  }
}

/// Riot Valorant Ultimate Ability Card (The Final Key // Honesty Oath Reactor)
class ValorantUltimateCard extends StatefulWidget {
  final bool isAnswered;
  final bool isHonored;
  final Color rankColor;
  final VoidCallback onTap;
  final int completedCount;
  final int totalQuests;

  const ValorantUltimateCard({
    super.key,
    required this.isAnswered,
    required this.isHonored,
    required this.rankColor,
    required this.onTap,
    this.completedCount = 0,
    this.totalQuests = 4,
  });

  @override
  State<ValorantUltimateCard> createState() => _ValorantUltimateCardState();
}

class _ValorantUltimateCardState extends State<ValorantUltimateCard>
    with TickerProviderStateMixin {
  late AnimationController _touchCtrl;
  late Animation<double> _touchScale;
  late AnimationController _breatheCtrl;

  @override
  void initState() {
    super.initState();
    _touchCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _touchScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _touchCtrl, curve: Curves.easeOutCubic),
    );

    _breatheCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _touchCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCharged = widget.completedCount >= widget.totalQuests && widget.totalQuests > 0;
    
    // Priority order: 1. Answered Oath (Sealed/Compromised), 2. Charged (Ready to vouch), 3. Dormant
    final Color activeColor = widget.isAnswered
        ? (widget.isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
        : (isCharged ? widget.rankColor : const Color(0xFF191D26));

    final bool hasActiveGlow = widget.isAnswered || isCharged;

    return AnimatedBuilder(
      animation: _breatheCtrl,
      builder: (context, child) {
        final breathe = _breatheCtrl.value;

        return GestureDetector(
          onTapDown: (_) => _touchCtrl.forward(),
          onTapUp: (_) {
            _touchCtrl.reverse();
            HapticFeedback.heavyImpact();
            widget.onTap();
          },
          onTapCancel: () => _touchCtrl.reverse(),
          child: ScaleTransition(
            scale: _touchScale,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isAnswered
                    ? (widget.isHonored
                        ? AppColors.emeraldPrimary.withValues(alpha: 0.08)
                        : const Color(0xFFFF4655).withValues(alpha: 0.08))
                    : const Color(0xFF0B0D13), // Pure deep stealth carbon
                border: Border.all(
                  color: widget.isAnswered
                      ? activeColor
                      : (isCharged
                          ? activeColor.withValues(alpha: 0.70 + 0.30 * breathe)
                          : const Color(0xFF191D26)),
                  width: hasActiveGlow ? (1.4 + (isCharged && !widget.isAnswered ? 0.6 * breathe : 0.0)) : 0.9,
                ),
                boxShadow: hasActiveGlow
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(
                              alpha: isCharged && !widget.isAnswered ? (0.20 + 0.25 * breathe) : 0.22),
                          blurRadius: isCharged && !widget.isAnswered ? (20 + 16 * breathe) : 20,
                          spreadRadius: isCharged && !widget.isAnswered ? (0.5 + 1.5 * breathe) : -2.0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null, // Zero glow when dormant
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Header Bar: Final Key / Daily Oath + Multiplier ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.isAnswered
                                  ? activeColor.withValues(alpha: 0.20)
                                  : (isCharged
                                      ? activeColor.withValues(alpha: 0.20 + 0.15 * breathe)
                                      : const Color(0xFF12151E)),
                              border: Border.all(
                                color: widget.isAnswered
                                    ? activeColor
                                    : (isCharged
                                        ? activeColor.withValues(alpha: 0.70 + 0.30 * breathe)
                                        : const Color(0xFF1F2533)),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              widget.isAnswered
                                  ? (widget.isHonored ? 'SEALED & HONORED' : 'DEFENSE CONSUMED')
                                  : (isCharged ? 'FINAL KEY' : 'DAILY OATH'),
                              style: GoogleFonts.spaceMono(
                                color: widget.isAnswered ? activeColor : (isCharged ? activeColor : const Color(0xFF5A6372)),
                                fontSize: 9.0,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.isAnswered ? 'PROTOCOL SEALED' : 'INTEGRITY OATH',
                            style: GoogleFonts.spaceMono(
                              color: hasActiveGlow ? const Color(0xFFECE8E1) : const Color(0xFF5A6372),
                              fontSize: 9.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.isAnswered
                            ? (widget.isHonored ? '+50 RAD EARNED' : '0 RAD')
                            : '+50 RAD BONUS',
                        style: GoogleFonts.spaceMono(
                          color: hasActiveGlow ? activeColor : const Color(0xFF5A6372),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── 2. 4 Energy Diamond Cells (Mind, Body, Soul, Env) ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07090E),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PILLAR ENERGY',
                          style: GoogleFonts.spaceMono(
                            color: hasActiveGlow ? activeColor : const Color(0xFF5A6372),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: List.generate(widget.totalQuests.clamp(1, 4), (i) {
                            final isFilled = i < widget.completedCount;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isFilled
                                      ? activeColor.withValues(alpha: 0.25)
                                      : const Color(0xFF12151E),
                                  border: Border.all(
                                    color: isFilled
                                        ? activeColor
                                        : const Color(0xFF1E2430),
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isFilled ? '◆' : '◇',
                                    style: TextStyle(
                                      color: isFilled ? activeColor : const Color(0xFF3E4654),
                                      fontSize: 8,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 3. Center Core ──
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF07090F),
                          border: Border.all(
                            color: widget.isAnswered
                                ? activeColor
                                : (isCharged
                                    ? activeColor.withValues(alpha: 0.70 + 0.30 * breathe)
                                    : const Color(0xFF191D26)),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            widget.isAnswered
                                ? (widget.isHonored ? Icons.verified_rounded : Icons.shield_outlined)
                                : Icons.security_rounded,
                            color: hasActiveGlow ? activeColor : const Color(0xFF4A5260),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isAnswered
                                  ? (widget.isHonored ? 'OATH COMPLETED' : 'DEFENSE SHIELD USED')
                                  : 'THE INTEGRITY OATH',
                              style: GoogleFonts.rajdhani(
                                color: hasActiveGlow ? Colors.white : const Color(0xFF9EAAB8),
                                fontSize: 17.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isAnswered
                                  ? (widget.isHonored
                                      ? 'DAY 100% SEALED · PROTOCOL HONORED'
                                      : 'FELL SHORT · SHIELD PRESERVED STREAK')
                                  : (isCharged
                                      ? 'ALL 4 PILLARS COMPLETE · READY TO SEAL'
                                      : 'COMPLETE ${widget.completedCount}/${widget.totalQuests} PILLARS TO UNLOCK'),
                              style: GoogleFonts.spaceMono(
                                color: hasActiveGlow ? activeColor : const Color(0xFF5A6372),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── 4. Action Button Bar ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: widget.isAnswered
                          ? activeColor.withValues(alpha: 0.15)
                          : (isCharged
                              ? activeColor.withValues(alpha: 0.15 + 0.15 * breathe)
                              : const Color(0xFF0E1118)),
                      border: Border.all(
                        color: widget.isAnswered
                            ? activeColor
                            : (isCharged
                                ? activeColor.withValues(alpha: 0.70 + 0.30 * breathe)
                                : const Color(0xFF191D26)),
                        width: hasActiveGlow ? 1.4 : 0.9,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.isAnswered
                            ? (widget.isHonored ? '✓ OATH HONORED · DAY LOGGED IN CHRONICLE' : '✕ SHIELD DEFENSE CONSUMED')
                            : (isCharged
                                ? '⚡ SEAL TODAY\'S HABITS · VOUCH INTEGRITY ⚡'
                                : '🔒 COMPLETE ALL 4 PILLARS TO SEAL'),
                        style: GoogleFonts.spaceMono(
                          color: hasActiveGlow ? activeColor : const Color(0xFF5A6372),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


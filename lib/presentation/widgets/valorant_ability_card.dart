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
        ? AppColors.emeraldPrimary
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
                ? const Color(0xFF09120E)
                : (widget.isSelected ? const Color(0xFF141924) : const Color(0xFF0C0E15)),
            border: Border.all(
              color: isCompleted
                  ? AppColors.emeraldPrimary.withValues(alpha: 0.85)
                  : (widget.isSelected ? accentColor : accentColor.withValues(alpha: 0.35)),
              width: isCompleted || widget.isSelected ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? AppColors.emeraldPrimary : accentColor)
                    .withValues(alpha: isCompleted ? 0.18 : 0.08),
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
                      ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                      : const Color(0xFF07090F),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.emeraldPrimary.withValues(alpha: 0.80)
                        : accentColor.withValues(alpha: 0.50),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: TacticalGlyph.fromCategory(
                    widget.quest.category,
                    color: isCompleted ? AppColors.emeraldPrimary : accentColor,
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
                                ? AppColors.emeraldPrimary.withValues(alpha: 0.20)
                                : accentColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.emeraldPrimary.withValues(alpha: 0.60)
                                  : accentColor.withValues(alpha: 0.40),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            widget.quest.category.toUpperCase(),
                            style: GoogleFonts.spaceMono(
                              color: isCompleted ? AppColors.emeraldPrimary : accentColor,
                              fontSize: 9.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCompleted ? 'PROTOCOL SECURED' : 'ACTIVE DIRECTIVE',
                          style: GoogleFonts.spaceMono(
                            color: isCompleted ? AppColors.emeraldPrimary : AppColors.darkSubText,
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

              // ── Right: Radianite Status Tag ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                      : const Color(0xFF00F5D4).withValues(alpha: 0.10),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.emeraldPrimary.withValues(alpha: 0.70)
                        : const Color(0xFF00F5D4).withValues(alpha: 0.40),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isCompleted ? 'SECURED' : '+25 RAD',
                      style: GoogleFonts.spaceMono(
                        color: isCompleted ? AppColors.emeraldPrimary : const Color(0xFF00F5D4),
                        fontSize: 9.0,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_rounded, color: AppColors.emeraldPrimary, size: 11),
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

/// Tactical Left Power Circuit Backbone Segment wrapping each ability card
class TacticalLeftBackboneSegment extends StatelessWidget {
  final bool isTop;
  final bool isQuestCompleted;
  final bool isPoweredFromAbove;
  final Widget child;

  const TacticalLeftBackboneSegment({
    super.key,
    required this.isTop,
    required this.isQuestCompleted,
    required this.isPoweredFromAbove,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeftBackboneRowPainter(
        isTop: isTop,
        isQuestCompleted: isQuestCompleted,
        isPoweredFromAbove: isPoweredFromAbove,
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

  _LeftBackboneRowPainter({
    required this.isTop,
    required this.isQuestCompleted,
    required this.isPoweredFromAbove,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const backboneX = 9.0;
    final branchY = size.height * 0.5;
    final cardLeftX = 24.0;

    const inactiveColor = Color(0xFF1E2430);
    const activeColor = Color(0xFF00F5D4);

    final isTransmitting = isQuestCompleted || isPoweredFromAbove;

    // 1. Top backbone vertical line
    if (!isTop) {
      final topPaint = Paint()
        ..color = isPoweredFromAbove ? activeColor : inactiveColor
        ..strokeWidth = isPoweredFromAbove ? 2.0 : 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(backboneX, 0), Offset(backboneX, branchY), topPaint);
    }

    // 2. Bottom backbone vertical line (transmits downwards)
    final bottomPaint = Paint()
      ..color = isTransmitting ? activeColor : inactiveColor
      ..strokeWidth = isTransmitting ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(backboneX, branchY), Offset(backboneX, size.height + 10.0), bottomPaint);

    // 3. Horizontal Feeder Branch (from Card left edge to Backbone)
    final branchPaint = Paint()
      ..color = isQuestCompleted ? activeColor : inactiveColor
      ..strokeWidth = isQuestCompleted ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(backboneX, branchY), Offset(cardLeftX, branchY), branchPaint);

    // 4. Diamond Junction Pip at (backboneX, branchY)
    final nodeFill = Paint()
      ..color = isTransmitting ? activeColor : const Color(0xFF0C0E14)
      ..style = PaintingStyle.fill;
    final nodeStroke = Paint()
      ..color = isTransmitting ? activeColor : const Color(0xFF2B3342)
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
        old.isPoweredFromAbove != isPoweredFromAbove;
  }
}

/// Tactical Left Power Circuit Backbone Wrapper for the Oath Reactor at the base
class TacticalLeftBackboneOathWrapper extends StatelessWidget {
  final bool isFullCharge;
  final bool hasAnyCompleted;
  final Widget child;

  const TacticalLeftBackboneOathWrapper({
    super.key,
    required this.isFullCharge,
    required this.hasAnyCompleted,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeftBackboneOathPainter(
        isFullCharge: isFullCharge,
        hasAnyCompleted: hasAnyCompleted,
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
  final bool hasAnyCompleted;

  _LeftBackboneOathPainter({
    required this.isFullCharge,
    required this.hasAnyCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const backboneX = 9.0;
    const cardLeftX = 24.0;
    const branchY = 32.0; // Plugs right into the left of the Oath Header

    const inactiveColor = Color(0xFF1E2430);
    const activeColor = Color(0xFF00F5D4);

    final isPowered = hasAnyCompleted;

    // 1. Vertical line descending from top of gutter to the input port
    final linePaint = Paint()
      ..color = isPowered ? activeColor : inactiveColor
      ..strokeWidth = isPowered ? 2.0 : 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(backboneX, -10.0), const Offset(backboneX, branchY), linePaint);

    // 2. Horizontal branch into the Oath card
    canvas.drawLine(const Offset(backboneX, branchY), const Offset(cardLeftX, branchY), linePaint);

    // 3. Diamond Node at the input junction
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
    return old.isFullCharge != isFullCharge || old.hasAnyCompleted != hasAnyCompleted;
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
    final isCharged = widget.completedCount >= widget.totalQuests && widget.totalQuests > 0;
    final statusColor = widget.isAnswered
        ? (widget.isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
        : (isCharged ? const Color(0xFF00F5D4) : const Color(0xFF191D26));

    final hasActiveGlow = isCharged || widget.isAnswered;

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
            color: const Color(0xFF0B0D13), // Pure deep stealth carbon
            border: Border.all(
              color: isCharged
                  ? const Color(0xFF00F5D4)
                  : (widget.isAnswered ? statusColor : const Color(0xFF191D26)),
              width: hasActiveGlow ? 1.6 : 0.9,
            ),
            boxShadow: hasActiveGlow
                ? [
                    BoxShadow(
                      color: (isCharged ? const Color(0xFF00F5D4) : statusColor)
                          .withValues(alpha: isCharged ? 0.35 : 0.20),
                      blurRadius: isCharged ? 28 : 20,
                      spreadRadius: isCharged ? 1.0 : -2.0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null, // Zero glow when dormant!
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Conduit Header Bar: Final Key Reactor + 4 Energy Diamond Cells ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCharged
                              ? const Color(0xFF00F5D4).withValues(alpha: 0.25)
                              : const Color(0xFF12151E),
                          border: Border.all(
                            color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF1F2533),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          isCharged ? '⚡ FINAL KEY' : '[ 🔒 DORMANT ]',
                          style: GoogleFonts.spaceMono(
                            color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF5A6372),
                            fontSize: 9.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HONESTY REACTOR',
                        style: GoogleFonts.spaceMono(
                          color: isCharged ? const Color(0xFFECE8E1) : const Color(0xFF5A6372),
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+50 RAD MULTIPLIER',
                    style: GoogleFonts.spaceMono(
                      color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF5A6372),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── 2. 4 Energy Conduit Cells (Mind, Body, Soul, Env) ──
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
                      'CONDUIT CHARGE',
                      style: GoogleFonts.spaceMono(
                        color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF5A6372),
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
                                  ? const Color(0xFF00F5D4).withValues(alpha: 0.25)
                                  : const Color(0xFF12151E),
                              border: Border.all(
                                color: isFilled
                                    ? const Color(0xFF00F5D4)
                                    : const Color(0xFF1E2430),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isFilled ? '◆' : '◇',
                                style: TextStyle(
                                  color: isFilled ? const Color(0xFF00F5D4) : const Color(0xFF3E4654),
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

              // ── 3. Center Reactor Core ──
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07090F),
                      border: Border.all(
                        color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF191D26),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: TacticalGlyph(
                        type: TacticalGlyphType.oath,
                        color: isCharged
                            ? const Color(0xFF00F5D4)
                            : (widget.isAnswered ? statusColor : const Color(0xFF4A5260)),
                        size: 24,
                        glow: hasActiveGlow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'THE INTEGRITY OATH',
                          style: GoogleFonts.rajdhani(
                            color: isCharged ? Colors.white : const Color(0xFF9EAAB8),
                            fontSize: 17.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCharged
                              ? '⚡ ALL 4 PROTOCOLS LINKED // APEX READY'
                              : 'LINK ${widget.completedCount}/${widget.totalQuests} ENERGY CELLS TO SEAL',
                          style: GoogleFonts.spaceMono(
                            color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF5A6372),
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

              // ── 4. Tactical Status / Ignition Button Bar ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: widget.isAnswered
                      ? (widget.isHonored
                          ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                          : const Color(0xFFFF4655).withValues(alpha: 0.15))
                      : (isCharged
                          ? const Color(0xFF00F5D4).withValues(alpha: 0.20)
                          : const Color(0xFF0E1118)),
                  border: Border.all(
                    color: isCharged
                        ? const Color(0xFF00F5D4)
                        : (widget.isAnswered ? statusColor : const Color(0xFF191D26)),
                    width: isCharged ? 1.4 : 0.9,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.isAnswered
                        ? (widget.isHonored ? 'FINAL KEY SEALED // +50 RAD' : 'COMPROMISED // SHIELD CONSUMED')
                        : (isCharged
                            ? '⚡ TURN FINAL KEY // SEAL DAILY PROTOCOLS ⚡'
                            : '🔒 REQUIRES 4/4 PROTOCOLS TO IGNITE'),
                    style: GoogleFonts.spaceMono(
                      color: isCharged
                          ? const Color(0xFF00F5D4)
                          : (widget.isAnswered ? statusColor : const Color(0xFF5A6372)),
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
  }
}


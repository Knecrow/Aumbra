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
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
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
                              fontSize: 8.0,
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
                            fontSize: 8.0,
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

/// Tactical vertical spine conduit connector linking one ability card to the next
class TacticalSpineConnector extends StatelessWidget {
  final bool isCompleted;
  final Color rankColor;
  final double height;

  const TacticalSpineConnector({
    super.key,
    required this.isCompleted,
    required this.rankColor,
    this.height = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isCompleted ? const Color(0xFF00F5D4) : const Color(0xFF232A38);

    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          width: 2.0,
          height: height,
          decoration: BoxDecoration(
            color: activeColor,
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.60),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// Custom painter for 45° chamfered Valorant ability card
class _ValorantCardPainter extends CustomPainter {
  final Color accentColor;
  final bool isCompleted;
  final bool isSelected;

  _ValorantCardPainter({
    required this.accentColor,
    required this.isCompleted,
    required this.isSelected,
  });

  Path _buildChamferPath(Rect rect) {
    const c = 12.0;
    final path = Path();
    path.moveTo(rect.left + c, rect.top);
    path.lineTo(rect.right - c, rect.top);
    path.lineTo(rect.right, rect.top + c);
    path.lineTo(rect.right, rect.bottom - c);
    path.lineTo(rect.right - c, rect.bottom);
    path.lineTo(rect.left + c, rect.bottom);
    path.lineTo(rect.left, rect.bottom - c);
    path.lineTo(rect.left, rect.top + c);
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = _buildChamferPath(rect);

    // 1. Fill Gradient
    final fillGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isCompleted
          ? [const Color(0xFF0B1410), const Color(0xFF050B08)]
          : (isSelected
              ? [accentColor.withValues(alpha: 0.16), const Color(0xFF0A0D14)]
              : [const Color(0xFF0D1018), const Color(0xFF06080C)]),
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. Glowing Perimeter Stroke
    final borderPaint = Paint()
      ..color = isCompleted
          ? AppColors.emeraldPrimary.withValues(alpha: 0.70)
          : (isSelected ? accentColor : accentColor.withValues(alpha: 0.32))
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.6 : 1.0;
    canvas.drawPath(path, borderPaint);

    // 3. Tactical Top Accent Line
    final topAccent = Paint()
      ..color = isCompleted ? AppColors.emeraldPrimary : accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(rect.left + 16, rect.top),
      Offset(rect.left + 36, rect.top),
      topAccent,
    );
  }

  @override
  bool shouldRepaint(covariant _ValorantCardPainter old) {
    return old.accentColor != accentColor ||
        old.isCompleted != isCompleted ||
        old.isSelected != isSelected;
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
        : (isCharged ? const Color(0xFF00F5D4) : widget.rankColor);

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
            color: const Color(0xFF0E111A),
            border: Border.all(
              color: isCharged
                  ? const Color(0xFF00F5D4).withValues(alpha: 0.85)
                  : statusColor.withValues(alpha: widget.isAnswered ? 0.90 : 0.45),
              width: isCharged ? 1.6 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCharged ? const Color(0xFF00F5D4) : statusColor).withValues(alpha: isCharged ? 0.25 : 0.15),
                blurRadius: isCharged ? 28 : 20,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
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
                          color: statusColor.withValues(alpha: 0.20),
                          border: Border.all(color: statusColor, width: 1.0),
                        ),
                        child: Text(
                          isCharged ? '⚡ FINAL KEY' : '[ ULTIMATE ]',
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HONESTY REACTOR',
                        style: GoogleFonts.spaceMono(
                          color: const Color(0xFF76808F),
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '+50 RAD MULTIPLIER',
                    style: GoogleFonts.spaceMono(
                      color: const Color(0xFF00F5D4),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CONDUIT CHARGE',
                      style: GoogleFonts.spaceMono(
                        color: const Color(0xFF76808F),
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
                                  : const Color(0xFF141822),
                              border: Border.all(
                                color: isFilled
                                    ? const Color(0xFF00F5D4)
                                    : const Color(0xFF232A38),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                isFilled ? '◆' : '◇',
                                style: TextStyle(
                                  color: isFilled ? const Color(0xFF00F5D4) : const Color(0xFF4A5260),
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
                        color: isCharged ? const Color(0xFF00F5D4) : statusColor,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: TacticalGlyph(
                        type: TacticalGlyphType.oath,
                        color: isCharged ? const Color(0xFF00F5D4) : statusColor,
                        size: 24,
                        glow: true,
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
                            color: AppColors.darkText,
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
                            color: isCharged ? const Color(0xFF00F5D4) : AppColors.darkSubText,
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
                          : statusColor.withValues(alpha: 0.12)),
                  border: Border.all(
                    color: isCharged ? const Color(0xFF00F5D4) : statusColor.withValues(alpha: 0.70),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.isAnswered
                        ? (widget.isHonored ? 'FINAL KEY SEALED // +50 RAD' : 'COMPROMISED // SHIELD CONSUMED')
                        : (isCharged
                            ? '⚡ TURN FINAL KEY // SEAL DAILY PROTOCOLS ⚡'
                            : 'LOCK IN EARLY OR COMPLETE ALL 4'),
                    style: GoogleFonts.spaceMono(
                      color: isCharged ? const Color(0xFF00F5D4) : statusColor,
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

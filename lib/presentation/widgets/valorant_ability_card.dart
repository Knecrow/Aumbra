import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/quest_model.dart';
import '../../core/constants/app_colors.dart';
import 'tactical_icons.dart';

/// Keybind letters mapped to the 4 protocol abilities
const List<String> kAbilityKeybinds = ['Q', 'E', 'C', 'F'];

/// A Riot Valorant inspired tactical Ability Buy-Menu Tile
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
    _touchScale = Tween<double>(begin: 1.0, end: 0.94).animate(
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

    final keybind = widget.index < kAbilityKeybinds.length
        ? kAbilityKeybinds[widget.index]
        : '${widget.index + 1}';

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
        child: CustomPaint(
          painter: _ValorantCardPainter(
            accentColor: accentColor,
            isCompleted: isCompleted,
            isSelected: widget.isSelected,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Top Row: Category Badge + Radianite Reward ─────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.emeraldPrimary.withValues(alpha: 0.20)
                            : (widget.isSelected
                                ? accentColor.withValues(alpha: 0.35)
                                : const Color(0xFF141822)),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.emeraldPrimary.withValues(alpha: 0.8)
                              : (widget.isSelected ? accentColor : Colors.white.withValues(alpha: 0.15)),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        widget.quest.category.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          color: isCompleted
                              ? AppColors.emeraldPrimary
                              : (widget.isSelected ? Colors.white : const Color(0xFF8E9BA6)),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),

                    // Radianite Points / Protocol Code
                    Text(
                      isCompleted ? 'SECURED' : '+25 RAD',
                      style: GoogleFonts.spaceMono(
                        color: isCompleted
                            ? AppColors.emeraldPrimary
                            : const Color(0xFF00F5D4), // Radianite Cyan
                        fontSize: 9.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Middle: Icon + Title ─────────────────────────────────
                Row(
                  children: [
                    // Ability Icon Plate
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.emeraldPrimary.withValues(alpha: 0.12)
                            : const Color(0xFF07090E),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.emeraldPrimary.withValues(alpha: 0.6)
                              : accentColor.withValues(alpha: 0.45),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: TacticalGlyph.fromCategory(
                          widget.quest.category,
                          color: isCompleted ? AppColors.emeraldPrimary : accentColor,
                          size: 18,
                          isCompleted: isCompleted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Title & Clean Category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.quest.title.toUpperCase(),
                            style: GoogleFonts.rajdhani(
                              color: AppColors.darkText,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.quest.category.toUpperCase(),
                            style: GoogleFonts.spaceMono(
                              color: AppColors.darkSubText,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Bottom Status Bar: [ READY ] vs [ LOCKED IN ] ────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                        : (widget.isSelected
                            ? accentColor.withValues(alpha: 0.15)
                            : const Color(0xFF080A10)),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.emeraldPrimary.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.06),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCompleted ? 'STATUS: COMPLETED' : (widget.isSelected ? 'STATUS: INSPECTING' : 'STATUS: READY'),
                        style: GoogleFonts.spaceMono(
                          color: isCompleted
                              ? AppColors.emeraldPrimary
                              : (widget.isSelected ? accentColor : const Color(0xFF6E788B)),
                          fontSize: 8.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Icon(
                        isCompleted ? Icons.lock_outline_rounded : Icons.radio_button_checked_rounded,
                        color: isCompleted
                            ? AppColors.emeraldPrimary
                            : (widget.isSelected ? accentColor : const Color(0xFF6E788B)),
                        size: 9.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

/// Riot Valorant Ultimate Ability Card [ X // ULTIMATE ] for The Honesty Oath
class ValorantUltimateCard extends StatefulWidget {
  final bool isAnswered;
  final bool isHonored;
  final Color rankColor;
  final VoidCallback onTap;

  const ValorantUltimateCard({
    super.key,
    required this.isAnswered,
    required this.isHonored,
    required this.rankColor,
    required this.onTap,
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
    final statusColor = widget.isAnswered
        ? (widget.isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
        : widget.rankColor;

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
              color: statusColor.withValues(alpha: widget.isAnswered ? 0.90 : 0.60),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.20),
                blurRadius: 24,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar
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
                          '[ ULTIMATE ]',
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 9.5,
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

              // Center Core Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF07090F),
                      border: Border.all(
                        color: statusColor,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: TacticalGlyph(
                        type: TacticalGlyphType.oath,
                        color: statusColor,
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
                          'DAILY PLEDGE OF TRUTH & HONOR',
                          style: GoogleFonts.spaceMono(
                            color: AppColors.darkSubText,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Bottom Trigger Button Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: widget.isAnswered
                      ? (widget.isHonored
                          ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                          : const Color(0xFFFF4655).withValues(alpha: 0.15))
                      : statusColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.70),
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.isAnswered
                        ? (widget.isHonored ? 'OATH SECURED // +50 RAD' : 'COMPROMISED // SHIELD USED')
                        : 'READY TO CAST // TAP TO LOCK IN',
                    style: GoogleFonts.spaceMono(
                      color: statusColor,
                      fontSize: 10.0,
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

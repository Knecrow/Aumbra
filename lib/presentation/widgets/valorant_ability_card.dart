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

/// Tactical vertical spine conduit connector on the LEFT axis linking cards directly
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
      child: Padding(
        padding: const EdgeInsets.only(left: 34.0), // Aligned with the center of the 42dp icon plate
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 2.5,
            height: height,
            decoration: BoxDecoration(
              color: activeColor,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withValues(alpha: 0.75),
                        blurRadius: 8,
                        spreadRadius: 1.0,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
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
        : (isCharged ? const Color(0xFF00F5D4) : const Color(0xFF232A38));

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
            color: const Color(0xFF0C0E15),
            border: Border.all(
              color: isCharged
                  ? const Color(0xFF00F5D4)
                  : (widget.isAnswered ? statusColor : const Color(0xFF232A38)),
              width: hasActiveGlow ? 1.6 : 1.0,
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
                : null,
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
                              : const Color(0xFF141822),
                          border: Border.all(
                            color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF232A38),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          isCharged ? '⚡ FINAL KEY' : '[ ULTIMATE ]',
                          style: GoogleFonts.spaceMono(
                            color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF76808F),
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
                        color: isCharged ? const Color(0xFF00F5D4) : const Color(0xFF232A38),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: TacticalGlyph(
                        type: TacticalGlyphType.oath,
                        color: isCharged
                            ? const Color(0xFF00F5D4)
                            : (widget.isAnswered ? statusColor : const Color(0xFF76808F)),
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
                          : const Color(0xFF141822)),
                  border: Border.all(
                    color: isCharged
                        ? const Color(0xFF00F5D4)
                        : (widget.isAnswered ? statusColor : const Color(0xFF232A38)),
                    width: isCharged ? 1.4 : 1.0,
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
                      color: isCharged
                          ? const Color(0xFF00F5D4)
                          : (widget.isAnswered ? statusColor : const Color(0xFF76808F)),
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


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/ranks.dart';
import '../../core/constants/app_colors.dart';

/// Animated rank glow badge displayed in the header (styled as a glowing system diamond with dual ring aura)
class RankGlowBadge extends StatefulWidget {
  final RankInfo rankInfo;
  final double size;

  const RankGlowBadge({
    super.key,
    required this.rankInfo,
    this.size = 60,
  });

  @override
  State<RankGlowBadge> createState() => _RankGlowBadgeState();
}

class _RankGlowBadgeState extends State<RankGlowBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: false);
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 6.28318).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.watch<UserProvider>().currentRankColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating halo ring
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.3 * _glowAnimation.value),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Rotating Diamond Frame
              Transform.rotate(
                angle: 3.14159265 / 4, // 45 degrees (Diamond)
                child: Container(
                  width: widget.size * 0.68,
                  height: widget.size * 0.68,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color, width: 2.2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5 * _glowAnimation.value),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              // Inner rank symbol icon
              Icon(
                _getRankIcon(widget.rankInfo.rankNumber),
                color: color,
                size: widget.size * 0.38,
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return Icons.auto_awesome;                  // Awakened: Celestial Rune
      case 2: return Icons.explore_outlined;               // Seeker: Astral Compass
      case 3: return Icons.bolt_outlined;                  // Strider: Gale Bolt Chevron
      case 4: return Icons.local_fire_department_outlined;  // Forged: Molten Flame
      case 5: return Icons.north_east;                     // Ascendant: Ascension Blade
      case 6: return Icons.shield_outlined;               // Exalted: Valarian Crest
      case 7: return Icons.diamond_outlined;               // Paragon: Arcane Crystal
      case 8: return Icons.menu_book_outlined;             // Sage: Eldritch Grimoire
      case 9: return Icons.wb_sunny_outlined;              // Saint: Solar Halo
      case 10: return Icons.all_inclusive;                 // Limitless: Ouroboros Infinity
      case 11: return Icons.hourglass_empty;               // Eternal: Chronos Hourglass
      case 12: return Icons.flare;                         // Transcendent: Aetherial Starburst
      case 13: return Icons.stars;                         // Celestial: Starlight Constellation
      case 14: return Icons.military_tech_outlined;        // Divine: Sovereign Paladin Crest
      case 15: return Icons.workspace_premium;             // Absolute: Sovereign Crown
      default: return Icons.auto_awesome;
    }
  }
}

/// Animated stat card for metrics display (Gaming HUD panel style)
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final iconColor = accentColor ?? (isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1));

    final effectiveColor = accentColor ?? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8));
    final bgColor = isDark
        ? effectiveColor.withValues(alpha: 0.12)
        : effectiveColor.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: subColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(icon, color: iconColor, size: 13),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor ?? (isDark ? AppColors.darkText : Colors.black87),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rank progress bar with animated fill (styled like HP/MP/EXP gauge)
class RankProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final String label;
  final String value;

  const RankProgressBar({
    super.key,
    required this.progress,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final trackColor = isDark
        ? const Color(0xFF22283D)
        : Colors.black.withValues(alpha: 0.12);
    final trackBorder = isDark
        ? const Color(0xFF384366)
        : Colors.black.withValues(alpha: 0.25);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: subColor, 
                fontSize: 10, 
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: trackBorder, width: 1.0),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: val,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.6),
                            color,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}


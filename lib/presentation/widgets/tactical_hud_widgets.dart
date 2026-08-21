import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Segmented energy meter styled like Riot Valorant's ultimate/ability charge bars
class TacticalSegmentedBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int totalSegments;
  final Color rankColor;
  final String label;
  final String readoutText;
  final double height;

  const TacticalSegmentedBar({
    super.key,
    required this.progress,
    required this.rankColor,
    this.totalSegments = 16,
    this.label = 'PROTOCOL_PROGRESS',
    this.readoutText = '',
    this.height = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    final lightColor = AppColors.getLightVariant(rankColor);
    final activeSegments = (progress.clamp(0.0, 1.0) * totalSegments).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Readout Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '// $label',
                  style: GoogleFonts.spaceMono(
                    color: const Color(0xFF8E9BA6),
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                if (readoutText.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    readoutText.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.rajdhani(
                color: lightColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Segmented Slanted Bar Cells
        SizedBox(
          height: height,
          child: Row(
            children: List.generate(totalSegments, (index) {
              final isActive = index < activeSegments;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < totalSegments - 1 ? 2.5 : 0),
                  child: Transform(
                    transform: Matrix4.skewX(-0.35),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive ? rankColor : const Color(0xFF141722),
                        border: Border.all(
                          color: isActive
                              ? lightColor.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.05),
                          width: 0.5,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: rankColor.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: -0.5,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Tactical Shields indicator styled like Valorant armor/shield HUD capsules
class TacticalShieldsPod extends StatelessWidget {
  final int shieldsRemaining;
  final Color rankColor;
  final VoidCallback? onTap;

  const TacticalShieldsPod({
    super.key,
    required this.shieldsRemaining,
    required this.rankColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF090B10),
          border: Border.all(
            color: rankColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AP //',
              style: GoogleFonts.spaceMono(
                color: const Color(0xFF7A8394),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (idx) {
                final isActive = idx < shieldsRemaining;
                return Padding(
                  padding: EdgeInsets.only(right: idx < 2 ? 3 : 0),
                  child: Icon(
                    isActive ? Icons.shield_rounded : Icons.shield_outlined,
                    color: isActive ? rankColor : Colors.white.withValues(alpha: 0.16),
                    size: 13,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tactical Streak pill styled with condensed military font and flame icon
class TacticalStreakPod extends StatelessWidget {
  final int streakDays;
  final Color rankColor;

  const TacticalStreakPod({
    super.key,
    required this.streakDays,
    required this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF090B10),
        border: Border.all(
          color: const Color(0xFFFF4655).withValues(alpha: 0.40), // Valorant Red accent
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFFF4655), // Valorant Red
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            '${streakDays}D',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFF8A94),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

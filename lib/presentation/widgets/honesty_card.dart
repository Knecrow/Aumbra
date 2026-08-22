import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class HonestyCard extends StatelessWidget {
  final bool isAnswered;
  final bool isHonored;
  final Color rankColor;
  final VoidCallback onHonored;
  final VoidCallback onReflect;

  const HonestyCard({
    super.key,
    required this.isAnswered,
    required this.isHonored,
    required this.rankColor,
    required this.onHonored,
    required this.onReflect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAnswered
              ? (isHonored
                  ? [const Color(0xFF0A1B14), const Color(0xFF050F0B)]
                  : [const Color(0xFF14100D), const Color(0xFF0D0A08)])
              : [const Color(0xFF0E0E0E), const Color(0xFF040404)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnswered
              ? (isHonored
                  ? AppColors.emeraldPrimary.withValues(alpha: 0.4)
                  : const Color(0xFFFF9100).withValues(alpha: 0.3))
              : rankColor.withValues(alpha: 0.30),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          if (isAnswered && isHonored)
            BoxShadow(
              color: AppColors.emeraldPrimary.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: -2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row with Shield Icon + Status Badge ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isAnswered
                          ? (isHonored
                              ? AppColors.emeraldPrimary.withValues(alpha: 0.16)
                              : const Color(0xFFFF9100).withValues(alpha: 0.16))
                          : rankColor.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isAnswered
                          ? (isHonored ? Icons.verified_user_rounded : Icons.history_edu_rounded)
                          : Icons.shield_rounded,
                      color: isAnswered
                          ? (isHonored ? AppColors.emeraldPrimary : const Color(0xFFFF9100))
                          : rankColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'HONESTY OATH',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),

              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isAnswered
                      ? (isHonored
                          ? AppColors.emeraldPrimary.withValues(alpha: 0.18)
                          : const Color(0xFFFF9100).withValues(alpha: 0.18))
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAnswered
                        ? (isHonored
                            ? AppColors.emeraldPrimary.withValues(alpha: 0.4)
                            : const Color(0xFFFF9100).withValues(alpha: 0.4))
                        : Colors.white.withValues(alpha: 0.10),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  isAnswered
                      ? (isHonored ? 'VERIFIED ✓' : 'LOGGED')
                      : 'DAILY CHECK',
                  style: GoogleFonts.inter(
                    color: isAnswered
                        ? (isHonored ? AppColors.emeraldLight : const Color(0xFFFFB74D))
                        : AppColors.darkSubText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Content / Question Body ─────────────────────────────────────
          if (!isAnswered) ...[
            Text(
              'Did you complete today\'s protocols with genuine, honest effort?',
              style: GoogleFonts.inter(
                color: const Color(0xFFC0CAD2),
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      onHonored();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            rankColor,
                            AppColors.getDeepVariant(rankColor),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'YES, HONORED ✓',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onReflect();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.darkCardElevated,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'REFLECT',
                          style: GoogleFonts.inter(
                            color: AppColors.darkSubText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isHonored
                        ? 'Integrity verified. Honor logged for today.'
                        : 'Reflection submitted. Regroup and rise tomorrow.',
                    style: GoogleFonts.inter(
                      color: isHonored ? AppColors.emeraldLight : const Color(0xFFFFB74D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onReflect,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'EDIT',
                      style: GoogleFonts.inter(
                        color: AppColors.darkSubText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

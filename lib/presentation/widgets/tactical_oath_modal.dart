import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/quest_provider.dart';
import 'tactical_icons.dart';

/// Shows the authentic Valorant Tactical Ultimate Oath Modal
void showTacticalHonestyOathModal({
  required BuildContext context,
  required QuestProvider questProvider,
  required Color rankColor,
}) {
  final answered = questProvider.oathAnswered;
  final honored = questProvider.oathAnswer == true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF07090F),
          border: Border.all(
            color: answered
                ? (honored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
                : rankColor.withValues(alpha: 0.8),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 36,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Header ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.20),
                        border: Border.all(color: rankColor, width: 1.0),
                      ),
                      child: Text(
                        'FINAL KEY',
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY HONESTY CHECK',
                      style: GoogleFonts.spaceMono(
                        color: const Color(0xFF8E9BA6),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8E9BA6), size: 20),
                  onPressed: () => Navigator.pop(ctx),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Aegis Shard Centerpiece ──────────────────────────────
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0E17),
                    border: Border.all(
                      color: answered
                          ? (honored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
                          : rankColor,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: TacticalGlyph(
                      type: TacticalGlyphType.oath,
                      color: answered
                          ? (honored ? AppColors.emeraldPrimary : const Color(0xFFFF4655))
                          : rankColor,
                      size: 28,
                      glow: true,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE INTEGRITY OATH',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+50 RAD BONUS · STREAK MULTIPLIER',
                        style: GoogleFonts.spaceMono(
                          color: const Color(0xFF00F5D4),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── The Creed Directive ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0D15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY INTEGRITY PLEDGE',
                    style: GoogleFonts.spaceMono(
                      color: rankColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Did you uphold absolute honesty and complete today\'s habits without deception or cutting corners?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Action Buttons ───────────────────────────────────────
            if (answered)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: honored
                      ? AppColors.emeraldPrimary.withValues(alpha: 0.15)
                      : const Color(0xFFFF4655).withValues(alpha: 0.15),
                  border: Border.all(
                    color: honored ? AppColors.emeraldPrimary : const Color(0xFFFF4655),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    honored
                        ? 'OATH HONORED · +50 RAD'
                        : 'OATH BROKEN · SHIELD CONSUMED',
                    style: GoogleFonts.spaceMono(
                      color: honored ? AppColors.emeraldPrimary : const Color(0xFFFF8A94),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  // Compromised Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        HapticFeedback.heavyImpact();
                        questProvider.answerOath(false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF4655),
                        side: const BorderSide(color: Color(0xFFFF4655), width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: Text(
                        'FELL SHORT',
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Vouch / Honored Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        HapticFeedback.heavyImpact();
                        questProvider.answerOath(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                      ),
                      child: Text(
                        'YES, I VOUCH',
                        style: GoogleFonts.spaceMono(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}

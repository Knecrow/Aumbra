import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/quest_model.dart';
import '../../core/constants/app_colors.dart';
import 'tactical_icons.dart';

/// Shows an authentic Valorant tactical "Ability Inspection & Execution Deck" modal
void showValorantInspectModal({
  required BuildContext context,
  required QuestModel quest,
  required int index,
  required Color rankColor,
  required VoidCallback onComplete,
  required VoidCallback onSwapQuest,
}) {
  final categoryColor = AppColors.getCategoryColor(quest.category);
  final isCompleted = quest.isCompleted;
  final keybind = index < 4 ? ['Q', 'E', 'C', 'F'][index] : '${index + 1}';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF090C12),
          border: Border.all(
            color: isCompleted ? AppColors.emeraldPrimary : categoryColor.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 30,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Header: Keybind + Category + Close Button ────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.20),
                        border: Border.all(color: categoryColor, width: 1.0),
                      ),
                      child: Text(
                        '[ $keybind ]',
                        style: GoogleFonts.spaceMono(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '// 0${index + 1} ${quest.category.toUpperCase()} PROTOCOL',
                      style: GoogleFonts.spaceMono(
                        color: const Color(0xFF8E9BA6),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
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

            // ── Title & Icon Hero ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06070B),
                    border: Border.all(
                      color: isCompleted ? AppColors.emeraldPrimary : categoryColor,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: TacticalGlyph.fromCategory(
                      quest.category,
                      color: isCompleted ? AppColors.emeraldPrimary : categoryColor,
                      size: 24,
                      isCompleted: isCompleted,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title.toUpperCase(),
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '+25 RADIANITE',
                            style: GoogleFonts.spaceMono(
                              color: const Color(0xFF00F5D4),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· DAILY PROTOCOL',
                            style: GoogleFonts.spaceMono(
                              color: const Color(0xFF7A8394),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Mission Lore & Instructions ──────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF06070B),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// MISSION_DIRECTIVE',
                    style: GoogleFonts.spaceMono(
                      color: categoryColor,
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    quest.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Heavy Tactical Action Buttons ────────────────────────
            if (isCompleted)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldPrimary.withValues(alpha: 0.15),
                  foregroundColor: AppColors.emeraldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.emeraldPrimary, width: 1.2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.emeraldPrimary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'PROTOCOL SECURED // TAP TO UNLOCK',
                        style: GoogleFonts.spaceMono(
                          color: AppColors.emeraldPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  HapticFeedback.heavyImpact();
                  onComplete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 18, color: Colors.black),
                    const SizedBox(width: 6),
                    Text(
                      'LOCK IN // EXECUTE PROTOCOL',
                      style: GoogleFonts.spaceMono(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    },
  );
}

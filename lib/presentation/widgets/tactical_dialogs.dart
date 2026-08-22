import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../providers/quest_provider.dart';
import 'tactical_icons.dart';

/// Shows tactical Shield Defense Matrix dialog
void showTacticalShieldDialog(BuildContext context, int shieldsRemaining, Color rankColor) {
  HapticFeedback.selectionClick();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF07090F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: rankColor.withValues(alpha: 0.6), width: 1.2),
      ),
      title: Row(
        children: [
          Container(width: 3, height: 16, color: rankColor),
          const SizedBox(width: 8),
          Text(
            'STREAK SHIELD MATRIX',
            style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (idx) {
              final active = idx < shieldsRemaining;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: active ? rankColor.withValues(alpha: 0.15) : const Color(0xFF0C0E17),
                    border: Border.all(
                      color: active ? rankColor : Colors.white.withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: TacticalGlyph(
                      type: TacticalGlyphType.shield,
                      color: active ? rankColor : Colors.white.withValues(alpha: 0.20),
                      size: 20,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'HOW SHIELDS WORK',
            style: GoogleFonts.spaceMono(color: rankColor, fontSize: 9.0, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Streak Shields automatically protect your streak if you miss a day. 3 shields recharge each month.',
            style: GoogleFonts.spaceMono(color: const Color(0xFF8E9BA6), fontSize: 11, height: 1.4),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: rankColor,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text('GOT IT', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    ),
  );
}

/// Shows tactical Edit Profile / Callsign dialog
void showTacticalEditProfileDialog(BuildContext context, UserProvider userProvider, Color rankColor) {
  HapticFeedback.selectionClick();
  final ctrl = TextEditingController(text: userProvider.user?.name ?? '');

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF07090F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: rankColor.withValues(alpha: 0.6), width: 1.2),
      ),
      title: Row(
        children: [
          Container(width: 3, height: 16, color: rankColor),
          const SizedBox(width: 8),
          Text(
            'EDIT PROFILE NAME',
            style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NAME / CALLSIGN',
            style: GoogleFonts.spaceMono(color: rankColor, fontSize: 9.0, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            autofocus: true,
            style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0C0E17),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: rankColor, width: 1.2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('CANCEL', style: GoogleFonts.spaceMono(color: const Color(0xFF7A8394), fontSize: 11)),
        ),
        ElevatedButton(
          onPressed: () async {
            final text = ctrl.text.trim();
            if (text.isNotEmpty) {
              await userProvider.updateProfile(name: text);
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: rankColor,
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text('SAVE CHANGES', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    ),
  );
}

/// Shows tactical Boss Raid Briefing dialog
void showTacticalBossDialog(BuildContext context, QuestProvider questProvider, Color rankColor) {
  final boss = questProvider.bossQuest;
  if (boss == null) return;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF07090F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0xFFFF4655), width: 1.4), // Valorant Red
      ),
      title: Row(
        children: [
          Container(width: 3, height: 16, color: const Color(0xFFFF4655)),
          const SizedBox(width: 8),
          Text(
            'ASCENSION CHALLENGE',
            style: GoogleFonts.spaceMono(color: const Color(0xFFFF4655), fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            boss.title.toUpperCase(),
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            boss.description,
            style: const TextStyle(color: Color(0xFF8E9BA6), fontSize: 13, height: 1.4),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('LATER', style: GoogleFonts.spaceMono(color: const Color(0xFF7A8394), fontSize: 11)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            questProvider.completeBossQuest();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4655),
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text('COMPLETE CHALLENGE', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 11)),
        ),
      ],
    ),
  );
}

/// Shows tactical Rank Lore / Tier contract dialog
void showTacticalRankLoreDialog(BuildContext context, UserProvider userProvider) {
  final rankInfo = userProvider.currentRankInfo;
  final rankColor = userProvider.currentRankColor;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF07090F),
          border: Border.all(color: rankColor.withValues(alpha: 0.8), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(width: 3, height: 14, color: rankColor),
                const SizedBox(width: 8),
                Text(
                  'RANK DOSSIER · RANK ${rankInfo.rankNumber}',
                  style: GoogleFonts.spaceMono(color: rankColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rankInfo.name.toUpperCase(),
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'TIER: ${rankInfo.depthLevel.toUpperCase()} · REQ: ${rankInfo.completionsRequired} DAYS',
              style: const TextStyle(color: Color(0xFF8E9BA6), fontSize: 12, height: 1.45),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: rankColor,
                foregroundColor: Colors.black,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text('CLOSE', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 11)),
            ),
          ],
        ),
      );
    },
  );
}

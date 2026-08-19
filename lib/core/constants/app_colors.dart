import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── DARK MODE ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF070A14);
  static const Color darkSurface = Color(0xFF0E1322);
  static const Color darkCard = Color(0xFF13182B);
  static const Color darkText = Color(0xFFF1F5F9);       // primary — high contrast crisp white
  static const Color darkSubText = Color(0xFF94A3B8);    // secondary — slate labels
  static const Color darkDimText = Color(0xFF475569);    // tertiary — meta/hints
  static const Color darkBorder = Color(0xFF1E293B);

  // Dynamic gradient background powered by the player's active rank color
  static RadialGradient buildRankAmbientGradient(Color rankColor) {
    return RadialGradient(
      center: const Alignment(-0.6, -0.7),
      radius: 1.4,
      colors: [
        rankColor.withValues(alpha: 0.22),
        const Color(0xFF0B0F1C),
        const Color(0xFF060810),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }

  static LinearGradient darkBackgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0C101D),
      Color(0xFF070A14),
      Color(0xFF04060C),
    ],
  );

  // Faux Glass (no blur)
  static Color darkFauxGlass = Colors.white.withValues(alpha: 0.04);
  static Color darkFauxGlassBorder = Colors.white.withValues(alpha: 0.08);

  // Real Glass (with blur — header, bottom nav, cards)
  static Color darkGlass = const Color(0xFF0F1424).withValues(alpha: 0.75);
  static Color darkGlassBorder = Colors.white.withValues(alpha: 0.12);

  // ─── WHITE MODE ──────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F5F9);
  static const Color lightText = Color(0xFF0F172A);      // primary
  static const Color lightSubText = Color(0xFF64748B);   // secondary
  static const Color lightDimText = Color(0xFF94A3B8);   // tertiary
  static const Color lightBorder = Color(0xFFE2E8F0);

  static Color lightFauxGlass = Colors.black.withValues(alpha: 0.03);
  static Color lightFauxGlassBorder = Colors.black.withValues(alpha: 0.06);

  static Color lightGlass = Colors.white.withValues(alpha: 0.85);
  static Color lightGlassBorder = Colors.black.withValues(alpha: 0.08);

  // ─── CATEGORY COLORS ─────────────────────────────────────────────────────
  static const Color mindColor = Color(0xFF38BDF8);       // Electric Sky Cyan
  static const Color bodyColor = Color(0xFFFF4757);       // Crimson Flame
  static const Color soulColor = Color(0xFFFFB142);       // Solar Amber
  static const Color environmentColor = Color(0xFF2ED573);  // Emerald Leaf
  static const Color socialColor = Color(0xFF70A1FF);      // Cobalt Blue
  static const Color planColor = Color(0xFFA55EEA);        // Arcane Violet
  static const Color reflectColor = Color(0xFFFF7F50);     // Sunset Coral
  static const Color customColor = Color(0xFFF1C40F);      // Sovereign Gold
  static const Color oathColor = Color(0xFF00D2D3);        // Deep Turquoise

  // ─── BADGE RARITY COLORS ─────────────────────────────────────────────────
  static const Color bronzeTier = Color(0xFFCD7F32);
  static const Color silverTier = Color(0xFFC0C0C0);
  static const Color goldTier = Color(0xFFFFD700);
  static const Color platinumTier = Color(0xFFE5E4E2);
  static const Color diamondTier = Color(0xFF00E5FF);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mind': return mindColor;
      case 'body': return bodyColor;
      case 'soul': return soulColor;
      case 'environment': return environmentColor;
      case 'social': return socialColor;
      case 'plan': return planColor;
      case 'reflect': return reflectColor;
      case 'custom': return customColor;
      case 'oath': return oathColor;
      default: return const Color(0xFF94A3B8);
    }
  }

  static IconData getCategoryIconData(String category) {
    switch (category.toLowerCase()) {
      case 'mind': return Icons.psychology_rounded;
      case 'body': return Icons.fitness_center_rounded;
      case 'soul': return Icons.self_improvement_rounded;
      case 'environment': return Icons.eco_rounded;
      case 'social': return Icons.people_rounded;
      case 'plan': return Icons.event_note_rounded;
      case 'reflect': return Icons.auto_stories_rounded;
      case 'custom': return Icons.star_rounded;
      case 'oath': return Icons.balance_rounded;
      default: return Icons.radio_button_checked_rounded;
    }
  }

  // ─── SHARED ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color accent = Color(0xFF00E5FF);
}


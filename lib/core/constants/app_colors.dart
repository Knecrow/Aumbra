import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── OBSIDIAN PURE BLACK DARK THEME ────────────────────────────────────
  static const Color darkBackground = Color(0xFF000000);       // Pure OLED black base
  static const Color darkSurface = Color(0xFF08080A);          // Deep black surface
  static const Color darkCard = Color(0xFF0D0D11);             // Sleek matte black card
  static const Color darkCardElevated = Color(0xFF121217);     // Elevated black card
  static const Color darkText = Color(0xFFF8F9FA);             // High-contrast crisp white
  static const Color darkSubText = Color(0xFF7E8299);          // Sleek ash / slate subtext
  static const Color darkDimText = Color(0xFF4A4E69);          // Tertiary dim text
  static const Color darkBorder = Color(0xFF1A1A22);           // Subtle card border
  static const Color darkBorderGold = Color(0x3DF5A623);       // Gold-tinted border (24% alpha)

  // ─── RADIANT SOLAR GOLD / AMBER ACCENTS ──────────────────────────────────
  static const Color goldPrimary = Color(0xFFF5A623);          // Solar Gold
  static const Color goldBright = Color(0xFFFFB800);           // Cyber Amber
  static const Color goldLight = Color(0xFFFFD56B);            // Champagne Gold Highlight
  static const Color goldDeep = Color(0xFFD48B16);             // Deep Antique Gold
  static const Color goldMuted = Color(0xFF9E782F);            // Muted Bronze Gold
  static const Color goldDark = Color(0xFF1A150D);             // Dark bronze surface tint

  // ─── SPORTY EMERALD & VIBRANT ACCENTS ─────────────────────────────────────
  static const Color emeraldPrimary = Color(0xFF00E676);       // Athletic Emerald
  static const Color emeraldLight = Color(0xFF69F0AE);         // Light Mint highlight

  // Ambient gold glow
  static Color goldGlow(double alpha) => const Color(0xFFF5A623).withValues(alpha: alpha);

  // Dynamic radiant background gradient
  static RadialGradient buildRankAmbientGradient(Color rankColor) {
    return RadialGradient(
      center: const Alignment(0.0, -0.6),
      radius: 1.3,
      colors: [
        rankColor.withValues(alpha: 0.12),
        const Color(0xFF060608),
        const Color(0xFF000000),
      ],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  // Dynamic radiant linear gradient based on the user's current rank color
  static LinearGradient buildRankGradient(Color rankColor) {
    final light = getLightVariant(rankColor);
    final deep = getDeepVariant(rankColor);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        light,
        rankColor,
        deep,
      ],
    );
  }

  static Color getLightVariant(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.20).clamp(0.0, 1.0)).withSaturation((hsl.saturation + 0.05).clamp(0.0, 1.0)).toColor();
  }

  static Color getDeepVariant(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
  }

  // Linear gold gradient for fallback/default buttons, active pills, and badges
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD56B),
      Color(0xFFF5A623),
      Color(0xFFD48B16),
    ],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF101015),
      Color(0xFF09090D),
    ],
  );

  static const LinearGradient quoteHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xCC1A1B28),
      Color(0xFA0F1018),
    ],
  );

  // Faux Glass (no blur)
  static Color darkFauxGlass = Colors.white.withValues(alpha: 0.035);
  static Color darkFauxGlassBorder = const Color(0xFFF5A623).withValues(alpha: 0.15);

  // Real Glass (with blur — header, bottom nav, cards)
  static Color darkGlass = const Color(0xFF10121C).withValues(alpha: 0.82);
  static Color darkGlassBorder = const Color(0xFFF5A623).withValues(alpha: 0.22);

  // ─── WHITE MODE (FALLBACK) ───────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEBECEF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightSubText = Color(0xFF64748B);
  static const Color lightDimText = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static Color lightFauxGlass = Colors.black.withValues(alpha: 0.03);
  static Color lightFauxGlassBorder = Colors.black.withValues(alpha: 0.06);
  static Color lightGlass = Colors.white.withValues(alpha: 0.85);
  static Color lightGlassBorder = Colors.black.withValues(alpha: 0.08);

  // ─── CATEGORY COLORS ─────────────────────────────────────────────────────
  static const Color mindColor = Color(0xFFF5A623);       // Mind / Focus — Solar Gold
  static const Color bodyColor = Color(0xFFFF5252);       // Body — Cyber Red
  static const Color soulColor = Color(0xFFFFB800);       // Soul — Radiant Amber
  static const Color environmentColor = Color(0xFF2ED573);// Environment — Emerald
  static const Color socialColor = Color(0xFF4A90E2);      // Social — Cobalt
  static const Color planColor = Color(0xFFB37FEB);        // Plan — Arcane Violet
  static const Color reflectColor = Color(0xFFFF8A65);     // Reflect — Sunset Orange
  static const Color customColor = Color(0xFFFFD56B);      // Custom — Imperial Gold
  static const Color oathColor = Color(0xFF00E5FF);        // Oath — Cyan Light

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
      default: return goldPrimary;
    }
  }

  static IconData getCategoryIconData(String category) {
    switch (category.toLowerCase()) {
      case 'mind': return Icons.memory_rounded;
      case 'body': return Icons.electric_bolt_rounded;
      case 'soul': return Icons.all_inclusive_rounded;
      case 'environment': return Icons.radar_rounded;
      case 'social': return Icons.diversity_3_rounded;
      case 'plan': return Icons.alt_route_rounded;
      case 'reflect': return Icons.center_focus_strong_rounded;
      case 'custom': return Icons.diamond_rounded;
      case 'oath': return Icons.verified_user_rounded;
      default: return Icons.token_rounded;
    }
  }

  // ─── SHARED ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFEF4444);
  static const Color accent = Color(0xFFFFB800);
}


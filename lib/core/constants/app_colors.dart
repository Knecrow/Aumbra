import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── PURE OLED BLACK THEME WITH DYNAMIC RANK ACCENTS ─────────────────────
  static const Color darkBackground    = Color(0xFF000000);
  static const Color darkSurface       = Color(0xFF060606);
  static const Color darkCard          = Color(0xFF0C0C0C);
  static const Color darkCardElevated  = Color(0xFF141414);
  static const Color darkText          = Color(0xFFFFFFFF);
  static const Color darkSubText       = Color(0xFF888888);
  static const Color darkDimText       = Color(0xFF444444);
  static const Color darkBorder        = Color(0x18FFFFFF);
  static const Color darkBorderGold    = Color(0x33F5A623);

  // ─── RADIANT SOLAR GOLD / AMBER ──────────────────────────────────────────
  static const Color goldPrimary  = Color(0xFFF5A623);
  static const Color goldBright   = Color(0xFFFFB800);
  static const Color goldLight    = Color(0xFFFFD56B);
  static const Color goldDeep     = Color(0xFFD48B16);
  static const Color goldMuted    = Color(0xFF9E782F);
  static const Color goldDark     = Color(0xFF1A150D);

  // ─── ACCENT RED (Sports Bike CTA color) ─────────────────────────────────
  static const Color accentRed     = Color(0xFFE53935);
  static const Color accentRedDark = Color(0xFFB71C1C);

  // ─── EMERALD ─────────────────────────────────────────────────────────────
  static const Color emeraldPrimary = Color(0xFF00E676);
  static const Color emeraldLight   = Color(0xFF69F0AE);

  // ─── GLASS CARD HELPER (Pure Onyx Glass with Rank Accent) ────────────────
  static BoxDecoration glassCard({
    required Color rankColor,
    double borderRadius = 20,
    bool elevated = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (elevated ? darkCardElevated : darkCard).withValues(alpha: 0.98),
          darkSurface.withValues(alpha: 0.95),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: rankColor.withValues(alpha: 0.22),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.70),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: rankColor.withValues(alpha: 0.08),
          blurRadius: 28,
          spreadRadius: -4,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Color goldGlow(double alpha) => const Color(0xFFF5A623).withValues(alpha: alpha);

  static RadialGradient buildRankAmbientGradient(Color rankColor) {
    return const RadialGradient(
      center: Alignment(0.0, -0.5),
      radius: 1.2,
      colors: [
        Color(0xFF000000),
        Color(0xFF000000),
      ],
      stops: [0.0, 1.0],
    );
  }

  static LinearGradient buildRankGradient(Color rankColor) {
    final light = getLightVariant(rankColor);
    final deep = getDeepVariant(rankColor);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [light, rankColor, deep],
    );
  }

  static Color getLightVariant(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + 0.20).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.05).clamp(0.0, 1.0))
        .toColor();
  }

  static Color getDeepVariant(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0)).toColor();
  }

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD56B), Color(0xFFF5A623), Color(0xFFD48B16)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0C0C0C), Color(0xFF040404)],
  );

  static const LinearGradient quoteHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF101010), Color(0xFF040404)],
  );

  static Color darkFauxGlass       = Colors.white.withValues(alpha: 0.03);
  static Color darkFauxGlassBorder = const Color(0xFFF5A623).withValues(alpha: 0.15);
  static Color darkGlass           = const Color(0xFF0C0C0C).withValues(alpha: 0.90);
  static Color darkGlassBorder     = const Color(0xFFF5A623).withValues(alpha: 0.22);

  // ─── LIGHT MODE (UNUSED) ─────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF5F6F8);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFEBECEF);
  static const Color lightText       = Color(0xFF0F172A);
  static const Color lightSubText    = Color(0xFF64748B);
  static const Color lightDimText    = Color(0xFF94A3B8);
  static const Color lightBorder     = Color(0xFFE2E8F0);

  static Color lightFauxGlass       = Colors.black.withValues(alpha: 0.03);
  static Color lightFauxGlassBorder = Colors.black.withValues(alpha: 0.06);
  static Color lightGlass           = Colors.white.withValues(alpha: 0.85);
  static Color lightGlassBorder     = Colors.black.withValues(alpha: 0.08);

  // ─── CATEGORY COLORS ─────────────────────────────────────────────────────
  static const Color mindColor        = Color(0xFFF5A623);
  static const Color bodyColor        = Color(0xFFFF4444);
  static const Color soulColor        = Color(0xFFFFB800);
  static const Color environmentColor = Color(0xFF2ED573);
  static const Color socialColor      = Color(0xFF4A90E2);
  static const Color planColor        = Color(0xFFB37FEB);
  static const Color reflectColor     = Color(0xFFFF8A65);
  static const Color customColor      = Color(0xFFFFD56B);
  static const Color oathColor        = Color(0xFF00E5FF);

  static const Color bronzeTier   = Color(0xFFCD7F32);
  static const Color silverTier   = Color(0xFFC0C0C0);
  static const Color goldTier     = Color(0xFFFFD700);
  static const Color platinumTier = Color(0xFFE5E4E2);
  static const Color diamondTier  = Color(0xFF00E5FF);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mind':        return mindColor;
      case 'body':        return bodyColor;
      case 'soul':        return soulColor;
      case 'environment': return environmentColor;
      case 'social':      return socialColor;
      case 'plan':        return planColor;
      case 'reflect':     return reflectColor;
      case 'custom':      return customColor;
      case 'oath':        return oathColor;
      default:            return goldPrimary;
    }
  }

  static IconData getCategoryIconData(String category) {
    switch (category.toLowerCase()) {
      case 'mind':        return Icons.memory_rounded;
      case 'body':        return Icons.electric_bolt_rounded;
      case 'soul':        return Icons.all_inclusive_rounded;
      case 'environment': return Icons.radar_rounded;
      case 'social':      return Icons.diversity_3_rounded;
      case 'plan':        return Icons.alt_route_rounded;
      case 'reflect':     return Icons.center_focus_strong_rounded;
      case 'custom':      return Icons.diamond_rounded;
      case 'oath':        return Icons.verified_user_rounded;
      default:            return Icons.token_rounded;
    }
  }

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF5A623);
  static const Color error   = Color(0xFFEF4444);
  static const Color accent  = Color(0xFFFFB800);
}

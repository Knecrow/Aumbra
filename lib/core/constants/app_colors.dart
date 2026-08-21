import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── UNIFIED RIOT VALORANT TACTICAL WHOLE-APP PALETTE ─────────────────────
  static const Color darkBackground    = Color(0xFF08090C); // Pure Obsidian Carbon Void
  static const Color darkSurface       = Color(0xFF0E1118); // Stealth Matte Surface
  static const Color darkCard          = Color(0xFF11141D); // Tactical Panel Base
  static const Color darkCardElevated  = Color(0xFF161A26); // Elevated Panel
  static const Color darkText          = Color(0xFFECE8E1); // Valorant Ghost Off-White
  static const Color darkSubText       = Color(0xFF76808F); // Muted Ice Steel
  static const Color darkDimText       = Color(0xFF4A5260); // Dim Grid Lines
  static const Color darkBorder        = Color(0xFF232A38); // Gunmetal Slate Border
  static const Color darkBorderGold    = Color(0x33F5A623);

  // ─── SIGNATURE VALORANT ACCENTS ──────────────────────────────────────────
  static const Color valorantRed   = Color(0xFFFF4655); // Valorant Signature Red (Boss / Alert)
  static const Color radianiteCyan = Color(0xFF00F5D4); // Radianite Mint (Energy / Success)
  static const Color emeraldPrimary = Color(0xFF00F5D4); // Unified with Radianite
  static const Color emeraldLight   = Color(0xFF69F0AE);

  // ─── GOLD / AMBER FALLBACK ───────────────────────────────────────────────
  static const Color goldPrimary  = Color(0xFFF5A623);
  static const Color goldBright   = Color(0xFFFFB800);
  static const Color goldLight    = Color(0xFFFFD56B);
  static const Color goldDeep     = Color(0xFFD48B16);
  static const Color goldDark     = Color(0xFF1A150D);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD56B), Color(0xFFF5A623), Color(0xFFD48B16)],
  );

  static Color darkFauxGlass       = const Color(0xFF11141D);
  static Color darkFauxGlassBorder = const Color(0xFF232A38);
  static Color lightFauxGlass      = const Color(0xFF11141D);
  static Color lightFauxGlassBorder = const Color(0xFF232A38);

  // ─── ACCENT RED ──────────────────────────────────────────────────────────
  static const Color accentRed     = Color(0xFFFF4655);
  static const Color accentRedDark = Color(0xFFB71C1C);

  // ─── GLASS & AMBIENT GRADIENTS (Pure Obsidian Stealth) ───────────────────
  static BoxDecoration glassCard({
    required Color rankColor,
    double borderRadius = 0,
    bool elevated = false,
  }) {
    return BoxDecoration(
      color: elevated ? darkCardElevated : darkCard,
      border: Border.all(
        color: rankColor.withValues(alpha: 0.25),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.70),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static RadialGradient buildRankAmbientGradient(Color rankColor) {
    return RadialGradient(
      center: const Alignment(0.0, -0.6),
      radius: 1.4,
      colors: [
        rankColor.withValues(alpha: 0.08),
        const Color(0xFF08090C),
      ],
      stops: const [0.0, 0.75],
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
        .withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.05).clamp(0.0, 1.0))
        .toColor();
  }

  static Color getDeepVariant(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11141D), Color(0xFF0E1118)],
  );

  static const LinearGradient quoteHeroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF141824), Color(0xFF08090C)],
  );

  // ─── LIGHT MODE FALLBACK ─────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFF08090C);
  static const Color lightSurface    = Color(0xFF0E1118);
  static const Color lightCard       = Color(0xFF11141D);
  static const Color lightText       = Color(0xFFECE8E1);
  static const Color lightSubText    = Color(0xFF76808F);
  static const Color lightDimText    = Color(0xFF4A5260);
  static const Color lightBorder     = Color(0xFF232A38);

  // ─── UNIFIED TACTICAL CATEGORY PALETTE ───────────────────────────────────
  static const Color mindColor        = Color(0xFF8B9BB4); // Muted Ice Silver-Blue
  static const Color bodyColor        = Color(0xFFFF5263); // Tactical Kinetic Crimson
  static const Color soulColor        = Color(0xFF00F5D4); // Radianite Cyan
  static const Color environmentColor = Color(0xFF2ED573); // Sector Mint
  static const Color socialColor      = Color(0xFF4A90E2);
  static const Color planColor        = Color(0xFFB37FEB);
  static const Color reflectColor     = Color(0xFFFF8A65);
  static const Color customColor      = Color(0xFFFFD56B);
  static const Color oathColor        = Color(0xFF00F5D4);

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mind':        return mindColor;
      case 'body':        return bodyColor;
      case 'soul':        return soulColor;
      case 'environment': return environmentColor;
      default:            return const Color(0xFF8B9BB4);
    }
  }

  static IconData getCategoryIconData(String category) {
    return Icons.token_rounded;
  }

  static const Color success = Color(0xFF00F5D4);
  static const Color warning = Color(0xFFF5A623);
  static const Color error   = Color(0xFFFF4655);
  static const Color accent  = Color(0xFF00F5D4);
}

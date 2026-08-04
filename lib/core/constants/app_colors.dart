import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── DARK MODE ───────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF04040A);
  static const Color darkSurface = Color(0xFF0A0A14);
  static const Color darkCard = Color(0xFF10101E);
  static const Color darkText = Color(0xFFE2E8F0);       // primary — off-white, easy on eyes
  static const Color darkSubText = Color(0xFF64748B);    // secondary — muted labels
  static const Color darkDimText = Color(0xFF334155);    // tertiary — meta/hints
  static const Color darkBorder = Color(0xFF1E1E34);

  // Gradient background for void dark cyber aesthetic
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF080814),
      Color(0xFF04040A),
      Color(0xFF020205),
    ],
  );

  // Faux Glass (no blur)
  static Color darkFauxGlass = Colors.white.withValues(alpha: 0.04);
  static Color darkFauxGlassBorder = Colors.white.withValues(alpha: 0.08);

  // Real Glass (with blur — header, bottom nav, popups)
  static Color darkGlass = const Color(0xFF0B0E1A).withValues(alpha: 0.7);
  static Color darkGlassBorder = Colors.white.withValues(alpha: 0.15);

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
  static const Color mindColor = Color(0xFF818CF8);
  static const Color bodyColor = Color(0xFFFF6B6B);
  static const Color soulColor = Color(0xFFFFB020);
  static const Color environmentColor = Color(0xFF10B981);
  static const Color socialColor = Color(0xFF38BDF8);
  static const Color planColor = Color(0xFFA855F7);
  static const Color reflectColor = Color(0xFFF97316);
  static const Color customColor = Color(0xFFFACC15);
  static const Color oathColor = Color(0xFF06B6D4);

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

  // ─── SHARED ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color accent = Color(0xFF00E5FF);
}


import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tactical Category Types for Valorant Glyphs
enum TacticalGlyphType {
  mind,
  body,
  soul,
  environment,
  oath,
  shield,
  boss,
  completed,
  streak,
  // Navigation Types
  navProtocol,
  navCareer,
  navArsenal,
  navConfig,
  // System / Settings Types
  memoryCore,
  cloudSync,
  securityLock,
  purgeDanger,
}

/// Custom vector-drawn tactical Valorant glyphs (No rounded generic material icons)
class TacticalGlyph extends StatelessWidget {
  final TacticalGlyphType type;
  final Color color;
  final double size;
  final bool glow;

  const TacticalGlyph({
    super.key,
    required this.type,
    required this.color,
    this.size = 24.0,
    this.glow = false,
  });

  /// Factory helper from quest category string
  factory TacticalGlyph.fromCategory(String category, {required Color color, double size = 24.0, bool isCompleted = false}) {
    if (isCompleted) {
      return TacticalGlyph(type: TacticalGlyphType.completed, color: AppColors.emeraldPrimary, size: size);
    }
    final c = category.toLowerCase().trim();
    if (c.contains('mind') || c.contains('intellect') || c.contains('focus')) {
      return TacticalGlyph(type: TacticalGlyphType.mind, color: color, size: size);
    }
    if (c.contains('body') || c.contains('phys') || c.contains('strength')) {
      return TacticalGlyph(type: TacticalGlyphType.body, color: color, size: size);
    }
    if (c.contains('soul') || c.contains('spirit') || c.contains('zen')) {
      return TacticalGlyph(type: TacticalGlyphType.soul, color: color, size: size);
    }
    if (c.contains('env') || c.contains('space') || c.contains('order')) {
      return TacticalGlyph(type: TacticalGlyphType.environment, color: color, size: size);
    }
    return TacticalGlyph(type: TacticalGlyphType.mind, color: color, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TacticalGlyphPainter(
        type: type,
        color: color,
        glow: glow,
      ),
    );
  }
}

class _TacticalGlyphPainter extends CustomPainter {
  final TacticalGlyphType type;
  final Color color;
  final bool glow;

  _TacticalGlyphPainter({
    required this.type,
    required this.color,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.08).clamp(1.2, 2.4)
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    if (glow) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (size.width * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawGlyph(canvas, size, glowPaint, fillPaint);
    }

    _drawGlyph(canvas, size, strokePaint, fillPaint);
  }

  void _drawGlyph(Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    switch (type) {
      // ── MIND: Concentric Neural Reticle & Crosshairs ──────────────
      case TacticalGlyphType.mind:
        final diamond = Path()
          ..moveTo(cx, h * 0.10)
          ..lineTo(w * 0.90, cy)
          ..lineTo(cx, h * 0.90)
          ..lineTo(w * 0.10, cy)
          ..close();
        canvas.drawPath(diamond, strokePaint);
        canvas.drawPath(diamond, fillPaint);
        canvas.drawCircle(Offset(cx, cy), w * 0.18, strokePaint);
        canvas.drawLine(Offset(cx, 0), Offset(cx, h * 0.22), strokePaint);
        canvas.drawLine(Offset(cx, h * 0.78), Offset(cx, h), strokePaint);
        canvas.drawLine(Offset(0, cy), Offset(w * 0.22, cy), strokePaint);
        canvas.drawLine(Offset(w * 0.78, cy), Offset(w, cy), strokePaint);
        break;

      // ── BODY: Sharp 45° Angular Kinetic Radianite Bolt ────────────
      case TacticalGlyphType.body:
        final bolt = Path()
          ..moveTo(w * 0.58, 0)
          ..lineTo(w * 0.18, h * 0.52)
          ..lineTo(w * 0.48, h * 0.52)
          ..lineTo(w * 0.38, h)
          ..lineTo(w * 0.82, h * 0.42)
          ..lineTo(w * 0.52, h * 0.42)
          ..close();
        canvas.drawPath(bolt, fillPaint);
        canvas.drawPath(bolt, strokePaint);
        break;

      // ── SOUL: Faceted Arcane Diamond Shard ────────────────────────
      case TacticalGlyphType.soul:
        final prism = Path()
          ..moveTo(cx, 0)
          ..lineTo(w * 0.88, h * 0.35)
          ..lineTo(cx, h)
          ..lineTo(w * 0.12, h * 0.35)
          ..close();
        canvas.drawPath(prism, fillPaint);
        canvas.drawPath(prism, strokePaint);
        canvas.drawLine(Offset(cx, 0), Offset(cx, h), strokePaint);
        canvas.drawLine(Offset(w * 0.12, h * 0.35), Offset(w * 0.88, h * 0.35), strokePaint);
        break;

      // ── ENVIRONMENT: Sector Coordinate Radar & Orbit Grid ─────────
      case TacticalGlyphType.environment:
        final frame = Path()
          ..moveTo(w * 0.25, 0)
          ..lineTo(w * 0.75, 0)
          ..lineTo(w, h * 0.25)
          ..lineTo(w, h * 0.75)
          ..lineTo(w * 0.75, h)
          ..lineTo(w * 0.25, h)
          ..lineTo(0, h * 0.75)
          ..lineTo(0, h * 0.25)
          ..close();
        canvas.drawPath(frame, strokePaint);
        canvas.drawCircle(Offset(cx, cy), w * 0.22, strokePaint);
        canvas.drawLine(Offset(cx, h * 0.15), Offset(cx, h * 0.85), strokePaint);
        canvas.drawLine(Offset(w * 0.15, cy), Offset(w * 0.85, cy), strokePaint);
        break;

      // ── OATH / SHIELD: Faceted Aegis Plate ─────────────────────────
      case TacticalGlyphType.oath:
      case TacticalGlyphType.shield:
        final aegis = Path()
          ..moveTo(cx, 0)
          ..lineTo(w * 0.92, h * 0.22)
          ..lineTo(w * 0.82, h * 0.72)
          ..lineTo(cx, h)
          ..lineTo(w * 0.18, h * 0.72)
          ..lineTo(w * 0.08, h * 0.22)
          ..close();
        canvas.drawPath(aegis, fillPaint);
        canvas.drawPath(aegis, strokePaint);
        canvas.drawLine(Offset(cx, h * 0.25), Offset(cx, h * 0.75), strokePaint);
        break;

      // ── BOSS: Aggressive Dual Combat Blades ───────────────────────
      case TacticalGlyphType.boss:
        canvas.drawLine(Offset(w * 0.15, 0), Offset(w * 0.85, h), strokePaint);
        canvas.drawLine(Offset(w * 0.85, 0), Offset(w * 0.15, h), strokePaint);
        final crown = Path()
          ..moveTo(cx, h * 0.25)
          ..lineTo(w * 0.75, h * 0.5)
          ..lineTo(cx, h * 0.75)
          ..lineTo(w * 0.25, h * 0.5)
          ..close();
        canvas.drawPath(crown, fillPaint);
        canvas.drawPath(crown, strokePaint);
        break;

      // ── COMPLETED: Sliced 45° Reticle Badge with Stencil Check ───
      case TacticalGlyphType.completed:
        final hex = Path()
          ..moveTo(cx, 0)
          ..lineTo(w, h * 0.25)
          ..lineTo(w, h * 0.75)
          ..lineTo(cx, h)
          ..lineTo(0, h * 0.75)
          ..lineTo(0, h * 0.25)
          ..close();
        canvas.drawPath(hex, fillPaint);
        canvas.drawPath(hex, strokePaint);
        final check = Path()
          ..moveTo(w * 0.28, cy)
          ..lineTo(w * 0.44, h * 0.68)
          ..lineTo(w * 0.74, h * 0.30);
        canvas.drawPath(check, strokePaint);
        break;

      // ── STREAK: Angular Laser Plasma Chevron ──────────────────────
      case TacticalGlyphType.streak:
        final flame = Path()
          ..moveTo(cx, 0)
          ..lineTo(w * 0.78, h * 0.38)
          ..lineTo(w * 0.62, h * 0.55)
          ..lineTo(w * 0.82, h)
          ..lineTo(cx, h * 0.78)
          ..lineTo(w * 0.18, h)
          ..lineTo(w * 0.38, h * 0.55)
          ..lineTo(w * 0.22, h * 0.38)
          ..close();
        canvas.drawPath(flame, fillPaint);
        canvas.drawPath(flame, strokePaint);
        break;

      // ── NAV: PROTOCOL (Combat Loadout Crosshairs) ─────────────────
      case TacticalGlyphType.navProtocol:
        final box = Path()
          ..moveTo(w * 0.2, 0)
          ..lineTo(w * 0.8, 0)
          ..lineTo(w, h * 0.2)
          ..lineTo(w, h * 0.8)
          ..lineTo(w * 0.8, h)
          ..lineTo(w * 0.2, h)
          ..lineTo(0, h * 0.8)
          ..lineTo(0, h * 0.2)
          ..close();
        canvas.drawPath(box, strokePaint);
        canvas.drawCircle(Offset(cx, cy), w * 0.20, fillPaint);
        canvas.drawCircle(Offset(cx, cy), w * 0.20, strokePaint);
        break;

      // ── NAV: CAREER (Telemetry Performance Pulse Wave) ───────────
      case TacticalGlyphType.navCareer:
        final pulse = Path()
          ..moveTo(0, cy)
          ..lineTo(w * 0.30, cy)
          ..lineTo(w * 0.45, h * 0.15)
          ..lineTo(w * 0.60, h * 0.85)
          ..lineTo(w * 0.75, cy)
          ..lineTo(w, cy);
        canvas.drawPath(pulse, strokePaint);
        canvas.drawCircle(Offset(w * 0.45, h * 0.15), 2.5, fillPaint);
        break;

      // ── NAV: ARSENAL (Act Rank Crown / Trophy Shard) ──────────────
      case TacticalGlyphType.navArsenal:
        final tierCrown = Path()
          ..moveTo(0, h * 0.30)
          ..lineTo(w * 0.30, h * 0.65)
          ..lineTo(cx, h * 0.10)
          ..lineTo(w * 0.70, h * 0.65)
          ..lineTo(w, h * 0.30)
          ..lineTo(w * 0.85, h * 0.90)
          ..lineTo(w * 0.15, h * 0.90)
          ..close();
        canvas.drawPath(tierCrown, fillPaint);
        canvas.drawPath(tierCrown, strokePaint);
        break;

      // ── NAV: CONFIG (Subsystem Mechanical Terminal Core) ──────────
      case TacticalGlyphType.navConfig:
        final terminal = Path()
          ..moveTo(w * 0.20, h * 0.20)
          ..lineTo(w * 0.80, h * 0.20)
          ..lineTo(w * 0.80, h * 0.80)
          ..lineTo(w * 0.20, h * 0.80)
          ..close();
        canvas.drawPath(terminal, strokePaint);
        // Prompt mark >_
        canvas.drawLine(Offset(w * 0.35, h * 0.40), Offset(w * 0.50, cy), strokePaint);
        canvas.drawLine(Offset(w * 0.50, cy), Offset(w * 0.35, h * 0.60), strokePaint);
        canvas.drawLine(Offset(w * 0.55, h * 0.60), Offset(w * 0.70, h * 0.60), strokePaint);
        break;

      // ── SETTINGS: Memory Core ─────────────────────────────────────
      case TacticalGlyphType.memoryCore:
        canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6), strokePaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.35, w * 0.3, h * 0.3), fillPaint);
        break;

      // ── SETTINGS: Cloud Sync ──────────────────────────────────────
      case TacticalGlyphType.cloudSync:
        canvas.drawCircle(Offset(cx, cy), w * 0.35, strokePaint);
        canvas.drawLine(Offset(cx, h * 0.2), Offset(cx, h * 0.8), strokePaint);
        canvas.drawLine(Offset(w * 0.2, cy), Offset(w * 0.8, cy), strokePaint);
        break;

      // ── SETTINGS: Security Lock ───────────────────────────────────
      case TacticalGlyphType.securityLock:
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.40, w * 0.70, h * 0.55), fillPaint);
        canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.40, w * 0.70, h * 0.55), strokePaint);
        final shackle = Path()
          ..moveTo(w * 0.30, h * 0.40)
          ..lineTo(w * 0.30, h * 0.20)
          ..lineTo(w * 0.70, h * 0.20)
          ..lineTo(w * 0.70, h * 0.40);
        canvas.drawPath(shackle, strokePaint);
        break;

      // ── SETTINGS: Purge Danger ────────────────────────────────────
      case TacticalGlyphType.purgeDanger:
        final triangle = Path()
          ..moveTo(cx, 0)
          ..lineTo(w, h * 0.90)
          ..lineTo(0, h * 0.90)
          ..close();
        canvas.drawPath(triangle, strokePaint);
        canvas.drawLine(Offset(cx, h * 0.30), Offset(cx, h * 0.60), strokePaint);
        canvas.drawCircle(Offset(cx, h * 0.75), 1.5, strokePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalGlyphPainter old) {
    return old.type != type || old.color != color || old.glow != glow;
  }
}

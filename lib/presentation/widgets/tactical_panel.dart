import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ChamferCorner {
  all,
  topLeftBottomRight,
  topRightBottomLeft,
  topOnly,
  bottomOnly,
  none,
}

/// A Riot Valorant inspired tactical card panel featuring 45° chamfered corners,
/// laser-sharp glowing borders, corner reticle crosshairs, and monospaced telemetry tags.
class TacticalPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color rankColor;
  final String? tacticalTag; // e.g. "// PROTOCOL: HUD · ACT 01"
  final String? statusBadge;  // e.g. "[ ONLINE ]"
  final double chamferSize;
  final ChamferCorner chamferCorner;
  final bool showCornerReticles;
  final bool showHeader;
  final VoidCallback? onTap;

  const TacticalPanel({
    super.key,
    required this.child,
    required this.rankColor,
    this.padding,
    this.margin,
    this.tacticalTag,
    this.statusBadge,
    this.chamferSize = 14.0,
    this.chamferCorner = ChamferCorner.all,
    this.showCornerReticles = true,
    this.showHeader = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = CustomPaint(
      painter: _TacticalPanelPainter(
        rankColor: rankColor,
        chamferSize: chamferSize,
        chamferCorner: chamferCorner,
        showCornerReticles: showCornerReticles,
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader && (tacticalTag != null || statusBadge != null)) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (tacticalTag != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 3,
                          height: 10,
                          color: rankColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tacticalTag!.toUpperCase(),
                          style: GoogleFonts.spaceMono(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  if (statusBadge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: rankColor.withValues(alpha: 0.40),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        statusBadge!.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          color: rankColor,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

class _TacticalPanelPainter extends CustomPainter {
  final Color rankColor;
  final double chamferSize;
  final ChamferCorner chamferCorner;
  final bool showCornerReticles;

  _TacticalPanelPainter({
    required this.rankColor,
    required this.chamferSize,
    required this.chamferCorner,
    required this.showCornerReticles,
  });

  Path _buildChamferPath(Rect rect) {
    final path = Path();
    final c = chamferSize;

    final cutTL = chamferCorner == ChamferCorner.all ||
        chamferCorner == ChamferCorner.topLeftBottomRight ||
        chamferCorner == ChamferCorner.topOnly;
    final cutTR = chamferCorner == ChamferCorner.all ||
        chamferCorner == ChamferCorner.topRightBottomLeft ||
        chamferCorner == ChamferCorner.topOnly;
    final cutBR = chamferCorner == ChamferCorner.all ||
        chamferCorner == ChamferCorner.topLeftBottomRight ||
        chamferCorner == ChamferCorner.bottomOnly;
    final cutBL = chamferCorner == ChamferCorner.all ||
        chamferCorner == ChamferCorner.topRightBottomLeft ||
        chamferCorner == ChamferCorner.bottomOnly;

    // Top-Left start
    if (cutTL) {
      path.moveTo(rect.left + c, rect.top);
    } else {
      path.moveTo(rect.left, rect.top);
    }

    // Top edge -> Top-Right
    if (cutTR) {
      path.lineTo(rect.right - c, rect.top);
      path.lineTo(rect.right, rect.top + c);
    } else {
      path.lineTo(rect.right, rect.top);
    }

    // Right edge -> Bottom-Right
    if (cutBR) {
      path.lineTo(rect.right, rect.bottom - c);
      path.lineTo(rect.right - c, rect.bottom);
    } else {
      path.lineTo(rect.right, rect.bottom);
    }

    // Bottom edge -> Bottom-Left
    if (cutBL) {
      path.lineTo(rect.left + c, rect.bottom);
      path.lineTo(rect.left, rect.bottom - c);
    } else {
      path.lineTo(rect.left, rect.bottom);
    }

    // Left edge -> Close to Top-Left
    if (cutTL) {
      path.lineTo(rect.left, rect.top + c);
      path.lineTo(rect.left + c, rect.top);
    } else {
      path.lineTo(rect.left, rect.top);
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = _buildChamferPath(rect);

    // 1. Deep Void Obsidian Fill Gradient
    const fillGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0D1017),
        Color(0xFF06070B),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 2. Subtle Glow Shadow
    final shadowPaint = Paint()
      ..color = rankColor.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path, shadowPaint);

    // 3. Crisp Laser Perimeter Border
    final borderPaint = Paint()
      ..color = rankColor.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(path, borderPaint);

    // 4. Tactical Top Accent Line
    final topAccentPaint = Paint()
      ..color = rankColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final topLength = (size.width * 0.22).clamp(18.0, 50.0);
    canvas.drawLine(
      Offset(rect.left + chamferSize + 4, rect.top),
      Offset(rect.left + chamferSize + 4 + topLength, rect.top),
      topAccentPaint,
    );

    // 5. Tactical Corner Reticles & Crosshair Ticks
    if (showCornerReticles) {
      final reticlePaint = Paint()
        ..color = rankColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      const rSize = 6.0;
      // Top-Left Reticle tick
      canvas.drawLine(
        Offset(rect.left + chamferSize + 2, rect.top + 6),
        Offset(rect.left + chamferSize + 2 + rSize, rect.top + 6),
        reticlePaint,
      );

      // Bottom-Right Reticle tick
      canvas.drawLine(
        Offset(rect.right - chamferSize - 2 - rSize, rect.bottom - 6),
        Offset(rect.right - chamferSize - 2, rect.bottom - 6),
        reticlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TacticalPanelPainter oldDelegate) {
    return oldDelegate.rankColor != rankColor ||
        oldDelegate.chamferSize != chamferSize ||
        oldDelegate.chamferCorner != chamferCorner;
  }
}

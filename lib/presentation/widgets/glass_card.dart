import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? glowColor;
  final double borderRadius;
  final bool showCornerBrackets;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.glowColor,
    this.borderRadius = 16.0,
    this.showCornerBrackets = false,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? Colors.white.withValues(alpha: 0.07);

    final List<BoxShadow> shadows = glowColor != null
        ? [
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.20),
              blurRadius: 22,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.50),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ];

    Widget containerWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: gradient ?? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D0D0D), Color(0xFF050505)],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder, width: 1.0),
        boxShadow: shadows,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: containerWidget,
      );
    }

    return containerWidget;
  }
}

// ── Corner Bracket Decorator (kept for backwards compatibility) ──────────────
class _CornerBracket extends StatelessWidget {
  final Color color;
  final double angle;

  const _CornerBracket({required this.color, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: 8,
        height: 8,
        child: CustomPaint(
          painter: _BracketPainter(color: color),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;

  _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final defaultBorder = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.lightGlassBorder;
    final effectiveBorder = borderColor ?? defaultBorder;
    final defaultBg = isDark ? AppColors.darkCard : const Color(0xFFF1F5F9);

    final List<BoxShadow> shadows = glowColor != null
        ? [
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ];

    Widget containerWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? defaultBg : null,
        gradient: gradient ?? (isDark ? AppColors.darkCardGradient : null),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: Stack(
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
          if (showCornerBrackets && isDark) ...[
            Positioned(
              top: 4,
              left: 4,
              child: _CornerBracket(color: effectiveBorder, angle: 0),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: _CornerBracket(color: effectiveBorder, angle: 1.5708),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: _CornerBracket(color: effectiveBorder, angle: 3.14159),
            ),
            Positioned(
              bottom: 4,
              left: 4,
              child: _CornerBracket(color: effectiveBorder, angle: 4.71239),
            ),
          ],
        ],
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

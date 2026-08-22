import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ambient slow-drifting floating embers that make dark backgrounds feel alive
class TacticalParticleCanvas extends StatefulWidget {
  final Color rankColor;
  final int particleCount;
  final Widget child;

  const TacticalParticleCanvas({
    super.key,
    required this.rankColor,
    this.particleCount = 22,
    required this.child,
  });

  @override
  State<TacticalParticleCanvas> createState() => _TacticalParticleCanvasState();
}

class _TacticalParticleCanvasState extends State<TacticalParticleCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late List<_AmbientParticle> _particles;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _particles = List.generate(widget.particleCount, (_) => _createParticle());
  }

  _AmbientParticle _createParticle({bool randomY = true}) {
    return _AmbientParticle(
      x: _rng.nextDouble(),
      y: randomY ? _rng.nextDouble() : 1.05 + _rng.nextDouble() * 0.1,
      speed: 0.04 + _rng.nextDouble() * 0.06,
      drift: (_rng.nextDouble() - 0.5) * 0.03,
      size: 1.2 + _rng.nextDouble() * 2.2,
      opacity: 0.15 + _rng.nextDouble() * 0.40,
      phase: _rng.nextDouble() * math.pi * 2,
    );
  }

  @override
  void didUpdateWidget(covariant TacticalParticleCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.particleCount != widget.particleCount) {
      _particles = List.generate(widget.particleCount, (_) => _createParticle());
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animCtrl,
            builder: (context, _) {
              return CustomPaint(
                painter: _ParticlePainter(
                  particles: _particles,
                  rankColor: widget.rankColor,
                  time: _animCtrl.value,
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AmbientParticle {
  double x;
  double y;
  double speed;
  double drift;
  double size;
  double opacity;
  double phase;

  _AmbientParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.drift,
    required this.size,
    required this.opacity,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_AmbientParticle> particles;
  final Color rankColor;
  final double time;

  _ParticlePainter({
    required this.particles,
    required this.rankColor,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Calculate animated position
      final currentY = ((p.y - time * p.speed) % 1.1) - 0.05;
      final currentX = (p.x + math.sin(time * math.pi * 2 + p.phase) * p.drift).clamp(0.0, 1.0);

      final px = currentX * size.width;
      final py = currentY * size.height;

      final breathe = 0.6 + 0.4 * math.sin(time * math.pi * 4 + p.phase);
      final alpha = (p.opacity * breathe).clamp(0.05, 0.7);

      final paint = Paint()
        ..color = rankColor.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size > 2.0 ? 3.0 : 1.5);

      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.fill;

      // Glow circle
      canvas.drawCircle(Offset(px, py), p.size * 1.6, paint);
      // Sharp core
      canvas.drawCircle(Offset(px, py), p.size * 0.7, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

/// Floating XP popup that bursts and floats up when an action/quest is completed
class FloatingRadianitePopup extends StatefulWidget {
  final Offset origin;
  final String text;
  final Color color;
  final VoidCallback onDismiss;

  const FloatingRadianitePopup({
    super.key,
    required this.origin,
    required this.text,
    required this.color,
    required this.onDismiss,
  });

  @override
  State<FloatingRadianitePopup> createState() => _FloatingRadianitePopupState();
}

class _FloatingRadianitePopupState extends State<FloatingRadianitePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _slideAnim = Tween<double>(begin: 0, end: -45).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.15), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
    ]).animate(_ctrl);

    _fadeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);

    _ctrl.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.origin.dx - 40,
      top: widget.origin.dy + _slideAnim.value,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF07090E),
            border: Border.all(color: widget.color, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: widget.color, size: 14),
              const SizedBox(width: 4),
              Text(
                widget.text,
                style: GoogleFonts.spaceMono(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

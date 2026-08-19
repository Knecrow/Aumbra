import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/ranks.dart';
import '../../core/constants/app_colors.dart';

/// Animated solar halo badge for rank & avatar display with optional circular ascension progress ring
class RankGlowBadge extends StatefulWidget {
  final RankInfo rankInfo;
  final double size;
  final bool showOuterHalo;
  final double? progress; // 0.0 to 1.0 progress to next rank

  const RankGlowBadge({
    super.key,
    required this.rankInfo,
    this.size = 64,
    this.showOuterHalo = true,
    this.progress,
  });

  @override
  State<RankGlowBadge> createState() => _RankGlowBadgeState();
}

class _RankGlowBadgeState extends State<RankGlowBadge>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotCtrl;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine),
    );

    _rotCtrl = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotCtrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = widget.rankInfo.color;
    final lightColor = AppColors.getLightVariant(rankColor);
    final progressVal = widget.progress;

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _rotCtrl]),
      builder: (context, child) {
        final glow = _pulseAnimation.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer radiant rank ambient aura
              if (widget.showOuterHalo)
                Container(
                  width: widget.size * 0.90,
                  height: widget.size * 0.90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: rankColor.withValues(alpha: 0.35 * glow),
                        blurRadius: widget.size * 0.35,
                        spreadRadius: widget.size * 0.05,
                      ),
                      BoxShadow(
                        color: lightColor.withValues(alpha: 0.20 * glow),
                        blurRadius: widget.size * 0.5,
                        spreadRadius: widget.size * 0.1,
                      ),
                    ],
                  ),
                ),

              // ── CIRCULAR ASCENSION PROGRESS RING AROUND PROFILE ──
              if (progressVal != null)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _AscensionProgressRingPainter(
                    progress: progressVal,
                    trackColor: Colors.white.withValues(alpha: 0.08),
                    progressColor: rankColor,
                    glowColor: lightColor,
                    strokeWidth: 2.8,
                  ),
                )
              else if (widget.showOuterHalo)
                // Rotating outer solar ring with gradient stroke
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: widget.size * 0.92,
                    height: widget.size * 0.92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: lightColor.withValues(alpha: 0.6 * glow),
                        width: 1.8,
                      ),
                    ),
                  ),
                ),

              // Inner obsidian core disc
              Container(
                width: widget.size * (progressVal != null ? 0.72 : 0.70),
                height: widget.size * (progressVal != null ? 0.72 : 0.70),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0D0E15),
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF1E1F2C),
                      Color(0xFF090A0F),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getRankIcon(widget.rankInfo.rankNumber),
                    color: lightColor,
                    size: widget.size * 0.36,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return Icons.auto_awesome_rounded;
      case 2: return Icons.explore_rounded;
      case 3: return Icons.bolt_rounded;
      case 4: return Icons.local_fire_department_rounded;
      case 5: return Icons.north_east_rounded;
      case 6: return Icons.shield_rounded;
      case 7: return Icons.diamond_rounded;
      case 8: return Icons.menu_book_rounded;
      case 9: return Icons.wb_sunny_rounded;
      case 10: return Icons.all_inclusive_rounded;
      case 11: return Icons.hourglass_empty_rounded;
      case 12: return Icons.flare_rounded;
      case 13: return Icons.stars_rounded;
      case 14: return Icons.military_tech_rounded;
      case 15: return Icons.workspace_premium_rounded;
      default: return Icons.auto_awesome_rounded;
    }
  }
}

/// Custom painter that renders a glowing circular progress track & arc around profile avatar
class _AscensionProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final Color glowColor;
  final double strokeWidth;

  const _AscensionProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glowColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2 * 0.94;

    // Background full circular track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    // Glow blur behind progress arc
    final glowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );

    // Foreground sharp gradient progress arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + sweepAngle,
        colors: [
          progressColor,
          glowColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AscensionProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.glowColor != glowColor;
  }
}

/// Overall Progress Card with circular radial gauge & attribute list (Matching Dashboard from reference)
class OverallProgressCard extends StatelessWidget {
  final double completionRate; // 0.0 to 1.0
  final int completedQuests;
  final int totalQuests;
  final int currentStreak;
  final int shieldsRemaining;
  final Color? rankColor;

  const OverallProgressCard({
    super.key,
    required this.completionRate,
    required this.completedQuests,
    required this.totalQuests,
    required this.currentStreak,
    required this.shieldsRemaining,
    this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRankColor = rankColor ?? context.watch<UserProvider>().currentRankColor;
    final lightColor = AppColors.getLightVariant(effectiveRankColor);
    final percent = (completionRate * 100).round();
    final disciplinePct = (percent).clamp(0, 100);
    final habitPct = totalQuests > 0 ? ((completedQuests / totalQuests) * 100).round() : 0;
    final mindsetPct = (currentStreak * 12).clamp(20, 100);
    final healthPct = ((shieldsRemaining / 3) * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        gradient: AppColors.darkCardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OVERALL PROGRESS',
            style: TextStyle(
              color: AppColors.darkSubText,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Radial circular gauge
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background track
                    const SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 7,
                        color: Color(0xFF222533),
                      ),
                    ),
                    // Progress arc
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: completionRate.clamp(0.0, 1.0),
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        color: effectiveRankColor,
                      ),
                    ),
                    // Center label
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'COMPLETE',
                          style: TextStyle(
                            color: AppColors.darkSubText,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Attribute breakdown column
              Expanded(
                child: Column(
                  children: [
                    _AttributeRow(label: 'Discipline', value: '$disciplinePct%', color: effectiveRankColor),
                    const SizedBox(height: 8),
                    _AttributeRow(label: 'Habits', value: '$habitPct%', color: lightColor),
                    const SizedBox(height: 8),
                    _AttributeRow(label: 'Mindset', value: '$mindsetPct%', color: AppColors.goldBright),
                    const SizedBox(height: 8),
                    _AttributeRow(label: 'Shields', value: '$healthPct%', color: const Color(0xFF38BDF8)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AttributeRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.darkSubText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.darkText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Focus Streak Card matching the golden droplet widget in the reference image
class FocusStreakCard extends StatelessWidget {
  final int streakDays;
  final int weeklyProgressPercent;
  final Color? rankColor;

  const FocusStreakCard({
    super.key,
    required this.streakDays,
    this.weeklyProgressPercent = 83,
    this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRankColor = rankColor ?? context.watch<UserProvider>().currentRankColor;
    final lightColor = AppColors.getLightVariant(effectiveRankColor);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        gradient: AppColors.darkCardGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DISCIPLINE STREAK',
                  style: TextStyle(
                    color: AppColors.darkSubText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$streakDays',
                      style: TextStyle(
                        color: effectiveRankColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'DAYS',
                      style: TextStyle(
                        color: AppColors.darkSubText,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Radiant Rank Orb / Droplet Graphic
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  lightColor.withValues(alpha: 0.4),
                  effectiveRankColor.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: effectiveRankColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.buildRankGradient(effectiveRankColor),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveRankColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated stat card for metrics display (Cyber HUD panel style)
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? accentColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.goldPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        gradient: AppColors.darkCardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.darkSubText,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: effectiveAccent, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rank progress bar with animated fill (styled with radiant gold glow)
class RankProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final String label;
  final String value;

  const RankProgressBar({
    super.key,
    required this.progress,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color == const Color(0xFF00E5FF) ? AppColors.goldPrimary : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.darkSubText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF1E202C),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: val,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.goldLight,
                            effectiveColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}



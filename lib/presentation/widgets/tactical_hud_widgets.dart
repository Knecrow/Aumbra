import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Segmented energy meter styled like Riot Valorant's ultimate/ability charge bars
class TacticalSegmentedBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int totalSegments;
  final Color rankColor;
  final String label;
  final String readoutText;
  final double height;

  const TacticalSegmentedBar({
    super.key,
    required this.progress,
    required this.rankColor,
    this.totalSegments = 16,
    this.label = 'PROTOCOL_PROGRESS',
    this.readoutText = '',
    this.height = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    final lightColor = AppColors.getLightVariant(rankColor);
    final activeSegments = (progress.clamp(0.0, 1.0) * totalSegments).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Readout Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '// $label',
                  style: GoogleFonts.spaceMono(
                    color: const Color(0xFF8E9BA6),
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                if (readoutText.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    readoutText.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.rajdhani(
                color: lightColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Segmented Slanted Bar Cells
        SizedBox(
          height: height,
          child: Row(
            children: List.generate(totalSegments, (index) {
              final isActive = index < activeSegments;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < totalSegments - 1 ? 2.5 : 0),
                  child: Transform(
                    transform: Matrix4.skewX(-0.35),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive ? rankColor : const Color(0xFF141722),
                        border: Border.all(
                          color: isActive
                              ? lightColor.withValues(alpha: 0.8)
                              : Colors.white.withValues(alpha: 0.05),
                          width: 0.5,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: rankColor.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: -0.5,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Tactical Shields indicator styled like Valorant armor/shield HUD capsules
class TacticalShieldsPod extends StatelessWidget {
  final int shieldsRemaining;
  final Color rankColor;
  final VoidCallback? onTap;

  const TacticalShieldsPod({
    super.key,
    required this.shieldsRemaining,
    required this.rankColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF090B10),
          border: Border.all(
            color: rankColor.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'AP //',
              style: GoogleFonts.spaceMono(
                color: const Color(0xFF7A8394),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (idx) {
                final isActive = idx < shieldsRemaining;
                return Padding(
                  padding: EdgeInsets.only(right: idx < 2 ? 3 : 0),
                  child: Icon(
                    isActive ? Icons.shield_rounded : Icons.shield_outlined,
                    color: isActive ? rankColor : Colors.white.withValues(alpha: 0.16),
                    size: 13,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tactical Streak pill styled with condensed military font and flame icon
class TacticalStreakPod extends StatelessWidget {
  final int streakDays;
  final Color rankColor;

  const TacticalStreakPod({
    super.key,
    required this.streakDays,
    required this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF090B10),
        border: Border.all(
          color: const Color(0xFFFF4655).withValues(alpha: 0.40), // Valorant Red accent
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Color(0xFFFF4655), // Valorant Red
            size: 13,
          ),
          const SizedBox(width: 3),
          Text(
            '${streakDays}D',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFF8A94),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tactical visual power circuit conduit that connects the 2x2 daily ability cards
/// down into the central Honesty Oath / Final Key Reactor
class TacticalConduitBridge extends StatelessWidget {
  final int completedCount;
  final int totalQuests;
  final Color rankColor;

  const TacticalConduitBridge({
    super.key,
    required this.completedCount,
    this.totalQuests = 4,
    required this.rankColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = rankColor;

    return SizedBox(
      height: 20,
      child: CustomPaint(
        painter: _ConduitBridgePainter(
          completedCount: completedCount,
          totalQuests: totalQuests,
          activeColor: activeColor,
        ),
      ),
    );
  }
}

class _ConduitBridgePainter extends CustomPainter {
  final int completedCount;
  final int totalQuests;
  final Color activeColor;

  _ConduitBridgePainter({
    required this.completedCount,
    required this.totalQuests,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final leftX = size.width * 0.25;
    final rightX = size.width * 0.75;
    final centerX = size.width * 0.5;
    final midY = size.height * 0.45;
    final bottomY = size.height;

    const inactiveColor = Color(0xFF232A38);

    final leftActive = completedCount >= 1;
    final rightActive = completedCount >= 2;
    final centerActive = completedCount > 0;

    final leftPaint = Paint()
      ..color = leftActive ? activeColor : inactiveColor
      ..strokeWidth = leftActive ? 1.5 : 1.0
      ..style = PaintingStyle.stroke;

    final rightPaint = Paint()
      ..color = rightActive ? activeColor : inactiveColor
      ..strokeWidth = rightActive ? 1.5 : 1.0
      ..style = PaintingStyle.stroke;

    final centerPaint = Paint()
      ..color = centerActive ? activeColor : inactiveColor
      ..strokeWidth = centerActive ? 1.8 : 1.0
      ..style = PaintingStyle.stroke;

    // 1. Left Vertical Feed from left abilities column
    canvas.drawLine(Offset(leftX, 0), Offset(leftX, midY), leftPaint);
    // Left Horizontal to Center
    canvas.drawLine(Offset(leftX, midY), Offset(centerX, midY), leftPaint);

    // 2. Right Vertical Feed from right abilities column
    canvas.drawLine(Offset(rightX, 0), Offset(rightX, midY), rightPaint);
    // Right Horizontal to Center
    canvas.drawLine(Offset(rightX, midY), Offset(centerX, midY), rightPaint);

    // 3. Central Injector down into the Reactor Core
    canvas.drawLine(Offset(centerX, midY), Offset(centerX, bottomY), centerPaint);

    // 4. Central Diamond Power Junction Node
    final nodePaint = Paint()
      ..color = centerActive ? activeColor : const Color(0xFF141822)
      ..style = PaintingStyle.fill;

    final nodeStroke = Paint()
      ..color = centerActive ? activeColor : const Color(0xFF232A38)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(centerX, midY - 3.5)
      ..lineTo(centerX + 3.5, midY)
      ..lineTo(centerX, midY + 3.5)
      ..lineTo(centerX - 3.5, midY)
      ..close();

    canvas.drawPath(path, nodePaint);
    canvas.drawPath(path, nodeStroke);
  }

  @override
  bool shouldRepaint(covariant _ConduitBridgePainter old) {
    return old.completedCount != completedCount ||
        old.totalQuests != totalQuests ||
        old.activeColor != activeColor;
  }
}

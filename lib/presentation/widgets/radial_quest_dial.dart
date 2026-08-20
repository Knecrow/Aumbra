import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/quest_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ranks.dart';

/// Hero 250px Segmented Energy Dial with Ascension Pulse Shockwave & Embedded Profile Core
class RadialQuestDial extends StatefulWidget {
  final List<QuestModel> quests;
  final QuestModel? bossQuest;
  final bool bossQuestUnlocked;
  final Color rankColor;
  final RankInfo rankInfo;
  final double ascProgress;
  final Function(String questId) onComplete;
  final Function(String questId) onUncomplete;
  final VoidCallback? onBossChallenge;
  final VoidCallback? onCenterTap;

  const RadialQuestDial({
    super.key,
    required this.quests,
    this.bossQuest,
    this.bossQuestUnlocked = false,
    required this.rankColor,
    required this.rankInfo,
    this.ascProgress = 0.0,
    required this.onComplete,
    required this.onUncomplete,
    this.onBossChallenge,
    this.onCenterTap,
  });

  @override
  State<RadialQuestDial> createState() => _RadialQuestDialState();
}

class _RadialQuestDialState extends State<RadialQuestDial>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnimation;
  late AnimationController _switchCtrl;
  late Animation<double> _switchFade;
  late AnimationController _shockwaveCtrl;
  late Animation<double> _shockwaveAnim;
  int? _lastSealedIndex;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine),
    );

    _switchCtrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _switchFade = CurvedAnimation(parent: _switchCtrl, curve: Curves.easeOut);
    _switchCtrl.forward();

    _shockwaveCtrl = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    _shockwaveAnim = CurvedAnimation(parent: _shockwaveCtrl, curve: Curves.easeOutQuad);

    _autoSelectActiveQuest();
  }

  @override
  void didUpdateWidget(covariant RadialQuestDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.quests.length) {
      _selectedIndex = math.max(0, widget.quests.length - 1);
    }
  }

  void _autoSelectActiveQuest() {
    final firstUncompleted = widget.quests.indexWhere((q) => !q.isCompleted);
    if (firstUncompleted != -1) {
      _selectedIndex = firstUncompleted;
    } else {
      _selectedIndex = 0;
    }
  }

  void _selectQuest(int index) {
    if (index < 0 || index >= widget.quests.length || index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    _switchCtrl.reset();
    setState(() => _selectedIndex = index);
    _switchCtrl.forward();
  }

  void _triggerSeal(QuestModel activeQuest) {
    HapticFeedback.heavyImpact();
    _lastSealedIndex = _selectedIndex;
    _shockwaveCtrl.forward(from: 0.0);
    widget.onComplete(activeQuest.id);

    // Auto rotate to next pending objective
    Future.delayed(const Duration(milliseconds: 320), () {
      if (mounted) {
        final nextUncompleted = widget.quests.indexWhere((q) => !q.isCompleted);
        if (nextUncompleted != -1) {
          _selectQuest(nextUncompleted);
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _switchCtrl.dispose();
    _shockwaveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'All protocols completed.',
            style: TextStyle(color: AppColors.darkSubText, fontSize: 13),
          ),
        ),
      );
    }

    final activeQuest = widget.quests[_selectedIndex.clamp(0, widget.quests.length - 1)];
    final completedCount = widget.quests.where((q) => q.isCompleted).length;
    final totalCount = widget.quests.length;
    final allDone = completedCount == totalCount;
    final lightRankColor = AppColors.getLightVariant(widget.rankColor);
    final isCurrentCompleted = activeQuest.isCompleted;

    const dialSize = 220.0;
    const strokeWidth = 10.5;
    const ringRadius = (dialSize - strokeWidth) / 2 * 0.88;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. HERO 220PX RADIAL ENERGY REACTOR WHEEL ──────────────────────
        AnimatedBuilder(
          animation: Listenable.merge([_pulseCtrl, _shockwaveCtrl]),
          builder: (context, child) {
            final pulse = _pulseAnimation.value;
            final shockwaveProgress = _shockwaveAnim.value;

            return SizedBox(
              width: dialSize,
              height: dialSize,
              child: GestureDetector(
                onTapUp: (details) => _handleDialTap(details, dialSize),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient Core Glow Bloom
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.rankColor.withValues(alpha: (allDone ? 0.40 : 0.22) * pulse),
                            blurRadius: 36,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),

                    // Custom Segmented Energy Ring Painter (with Shockwave Surge)
                    CustomPaint(
                      size: const Size(dialSize, dialSize),
                      painter: _SegmentedEnergyRingPainter(
                        quests: widget.quests,
                        selectedIndex: _selectedIndex,
                        rankColor: widget.rankColor,
                        pulse: pulse,
                        shockwaveProgress: shockwaveProgress,
                        shockwaveIndex: _lastSealedIndex,
                      ),
                    ),

                    // Orbital Category Rune Nodes along the Ring Perimeter
                    ...List.generate(totalCount, (i) {
                      final q = widget.quests[i];
                      final isSel = i == _selectedIndex;
                      final isDone = q.isCompleted;

                      final midAngle = (-math.pi / 2) + (i * ((2 * math.pi) / totalCount)) + (math.pi / totalCount);
                      final nx = (dialSize / 2) + (ringRadius * math.cos(midAngle));
                      final ny = (dialSize / 2) + (ringRadius * math.sin(midAngle));

                      return Positioned(
                        left: nx - 14,
                        top: ny - 14,
                        child: GestureDetector(
                          onTap: () => _selectQuest(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? widget.rankColor
                                  : (isSel ? const Color(0xFF1C1F30) : const Color(0xFF0F1018)),
                              border: Border.all(
                                color: isDone
                                    ? Colors.black.withValues(alpha: 0.8)
                                    : (isSel ? lightRankColor : Colors.white.withValues(alpha: 0.12)),
                                width: isSel ? 1.6 : 1.0,
                              ),
                              boxShadow: [
                                if (isSel || isDone)
                                  BoxShadow(
                                    color: widget.rankColor.withValues(alpha: isDone ? 0.45 : 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                AppColors.getCategoryIconData(q.category),
                                color: isDone
                                    ? Colors.black
                                    : (isSel ? lightRankColor : AppColors.darkSubText),
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    // Center Core: Hero Quest Type Rune (Sci-Fi Reactor Core)
                    GestureDetector(
                      onTap: widget.onCenterTap,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0D0F18),
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFF1A1D2D),
                              Color(0xFF090A10),
                            ],
                          ),
                          border: Border.all(
                            color: widget.rankColor.withValues(alpha: 0.35 * pulse),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.rankColor.withValues(alpha: 0.30 * pulse),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            AppColors.getCategoryIconData(activeQuest.category),
                            color: widget.rankColor,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // ── 2. STRUCTURED DIRECT ACTION CONSOLE DECK ──────────────────────
        FadeTransition(
          opacity: _switchFade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Category / Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: widget.rankColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: widget.rankColor.withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      activeQuest.isBossQuest ? 'BOSS' : 'OBJECTIVE',
                      style: TextStyle(
                        color: lightRankColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Objective Title
                  Text(
                    activeQuest.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isCurrentCompleted ? AppColors.darkSubText : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      decoration: isCurrentCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.darkSubText,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Single Sporty Action Button
                  GestureDetector(
                    onTap: () {
                      if (isCurrentCompleted) {
                        HapticFeedback.lightImpact();
                        widget.onUncomplete(activeQuest.id);
                      } else {
                        _triggerSeal(activeQuest);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isCurrentCompleted
                            ? null
                            : AppColors.buildRankGradient(widget.rankColor),
                        color: isCurrentCompleted ? const Color(0xFF141724) : null,
                        borderRadius: BorderRadius.circular(14),
                        border: isCurrentCompleted
                            ? Border.all(color: widget.rankColor.withValues(alpha: 0.4), width: 1.0)
                            : null,
                        boxShadow: isCurrentCompleted
                            ? null
                            : [
                                BoxShadow(
                                  color: widget.rankColor.withValues(alpha: 0.40),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCurrentCompleted ? Icons.lock_rounded : Icons.bolt_rounded,
                            color: isCurrentCompleted ? lightRankColor : Colors.black,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCurrentCompleted ? 'COMPLETED' : 'COMPLETE',
                            style: TextStyle(
                              color: isCurrentCompleted ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── 3. BOSS TRIAL BUTTON (IF PRESENT) ──────────────────────────────
        if (widget.bossQuest != null && widget.bossQuestUnlocked) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: widget.onBossChallenge,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.buildRankGradient(widget.rankColor),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.rankColor.withValues(alpha: 0.30),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.military_tech_rounded, color: Colors.black, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'BOSS TRIAL: ${widget.bossQuest!.title.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleDialTap(TapUpDetails details, double dialSize) {
    final center = Offset(dialSize / 2, dialSize / 2);
    final touchPos = details.localPosition;
    final delta = touchPos - center;
    final distance = delta.distance;

    // Tap on center opens profile
    if (distance < 50) {
      widget.onCenterTap?.call();
      return;
    }

    if (distance > 135) return;

    final n = widget.quests.length;
    if (n == 0) return;

    var angle = math.atan2(delta.dy, delta.dx) + (math.pi / 2);
    if (angle < 0) angle += 2 * math.pi;

    final segmentAngle = (2 * math.pi) / n;
    final clickedIndex = (angle / segmentAngle).floor() % n;

    _selectQuest(clickedIndex);
  }
}

/// Custom painter that renders the N segmented energy arcs + Ascension Pulse shockwave
class _SegmentedEnergyRingPainter extends CustomPainter {
  final List<QuestModel> quests;
  final int selectedIndex;
  final Color rankColor;
  final double pulse;
  final double shockwaveProgress;
  final int? shockwaveIndex;

  const _SegmentedEnergyRingPainter({
    required this.quests,
    required this.selectedIndex,
    required this.rankColor,
    required this.pulse,
    this.shockwaveProgress = 0.0,
    this.shockwaveIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = quests.length;
    if (count == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 11.0;
    final radius = (size.width - strokeWidth) / 2 * 0.89;
    const gapAngle = 0.13;

    final segmentSweep = ((2 * math.pi) / count) - gapAngle;
    final lightRankColor = AppColors.getLightVariant(rankColor);

    // 0. Concentric Sci-Fi HUD Guide Rings
    final guideInnerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 9, guideInnerPaint);

    final guideOuterPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius + 9, guideOuterPaint);

    for (int i = 0; i < count; i++) {
      final quest = quests[i];
      final isSelected = i == selectedIndex;
      final isCompleted = quest.isCompleted;

      final startAngle = (-math.pi / 2) + (i * ((2 * math.pi) / count)) + (gapAngle / 2);

      // 1. Background Arc Track
      final trackPaint = Paint()
        ..color = isCompleted
            ? rankColor.withValues(alpha: 0.22)
            : const Color(0xFF131520)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 2 : strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentSweep,
        false,
        trackPaint,
      );

      // Subtle hairline border for incomplete segments
      if (!isCompleted) {
        final outlinePaint = Paint()
          ..color = isSelected
              ? lightRankColor.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentSweep,
          false,
          outlinePaint,
        );
      }

      // 2. Completed / Active Energy Arc
      if (isCompleted) {
        final glowPaint = Paint()
          ..color = rankColor.withValues(alpha: 0.45 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 5.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentSweep,
          false,
          glowPaint,
        );

        final fillPaint = Paint()
          ..shader = LinearGradient(
              colors: [
                lightRankColor,
                rankColor,
              ],
            ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? strokeWidth + 2 : strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentSweep,
          false,
          fillPaint,
        );
      }

      // 3. Selection Indicator Halo Arc
      if (isSelected) {
        final selectorPaint = Paint()
          ..color = (isCompleted ? lightRankColor : rankColor).withValues(alpha: 0.70 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + 9),
          startAngle,
          segmentSweep,
          false,
          selectorPaint,
        );
      }
    }

    // 4. Radial Shockwave Surge Animation (on Seal)
    if (shockwaveProgress > 0.0 && shockwaveProgress < 1.0 && shockwaveIndex != null) {
      final surgeRadius = radius + (shockwaveProgress * 28.0);
      final alpha = (1.0 - shockwaveProgress).clamp(0.0, 1.0);
      final surgePaint = Paint()
        ..color = lightRankColor.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - shockwaveProgress) * 4.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      final startAngle = (-math.pi / 2) + (shockwaveIndex! * ((2 * math.pi) / count)) + (gapAngle / 2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: surgeRadius),
        startAngle,
        segmentSweep,
        false,
        surgePaint,
      );

      // Expanding core ring pulse
      final corePulseRadius = 40.0 + (shockwaveProgress * 30.0);
      final corePaint = Paint()
        ..color = rankColor.withValues(alpha: alpha * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (1.0 - shockwaveProgress) * 3.0;

      canvas.drawCircle(center, corePulseRadius, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedEnergyRingPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.quests != quests ||
        oldDelegate.pulse != pulse ||
        oldDelegate.shockwaveProgress != shockwaveProgress ||
        oldDelegate.rankColor != rankColor;
  }
}

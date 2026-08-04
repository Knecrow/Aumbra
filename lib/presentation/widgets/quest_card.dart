import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quest_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';

class QuestCard extends StatefulWidget {
  final QuestModel quest;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;

  const QuestCard({
    super.key,
    required this.quest,
    this.onComplete,
    this.onUncomplete,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard>
    with TickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  late Animation<double> _arrowAnim;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeInOut);
    _arrowAnim = Tween<double>(begin: 0, end: 0.25).animate(_expandAnim);

    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 90),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isExpanded) {
      _expandCtrl.reverse();
    } else {
      _expandCtrl.forward();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mind': return Icons.psychology_outlined;
      case 'body': return Icons.fitness_center_outlined;
      case 'soul': return Icons.self_improvement_outlined;
      case 'environment': return Icons.eco_outlined;
      case 'social': return Icons.people_outline;
      case 'plan': return Icons.event_note_outlined;
      case 'reflect': return Icons.auto_stories_outlined;
      case 'custom': return Icons.star_outline;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final rankColor = context.watch<UserProvider>().currentRankColor;
    final categoryColor = AppColors.getCategoryColor(widget.quest.category);
    final effectiveCategoryColor =
        widget.quest.isBossQuest ? rankColor : categoryColor;

    final bgColor = widget.quest.isCompleted
        ? const Color(0x1F10B981) // green tint
        : isDark
            ? rankColor.withValues(alpha: 0.12)
            : rankColor.withValues(alpha: 0.08);

    final textColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.forward(),
        onTapUp: (_) => _scaleCtrl.reverse(),
        onTapCancel: () => _scaleCtrl.reverse(),
        onTap: widget.quest.isCompleted ? null : _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Content ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          // Category icon with category color
                          Icon(
                            widget.quest.isBossQuest ? Icons.flash_on : _getCategoryIcon(widget.quest.category),
                            color: effectiveCategoryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),

                          // Quest name + category label
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.quest.isBossQuest
                                      ? 'BOSS QUEST'
                                      : widget.quest.category.toUpperCase(),
                                  style: TextStyle(
                                    color: effectiveCategoryColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.quest.title,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                    decoration: widget.quest.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: subColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Right side: checkmark or expand arrow
                          if (widget.quest.isCompleted)
                            GestureDetector(
                              onTap: () => widget.onUncomplete?.call(),
                              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 22),
                            )
                          else
                            RotationTransition(
                              turns: _arrowAnim,
                              child: Icon(
                                Icons.chevron_right,
                                color: subColor,
                                size: 20,
                              ),
                            ),
                        ],
                      ),


                      // ── Expanded section ──
                      SizeTransition(
                        sizeFactor: _expandAnim,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              height: 1,
                              color: isDark ? const Color(0x1AFFFFFF) : const Color(0x1F000000),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.quest.description,
                              style: TextStyle(
                                color: subColor,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  widget.onComplete?.call();
                                  setState(() => _isExpanded = false);
                                  _expandCtrl.reverse();
                                },
                                icon: const Text('⚡', style: TextStyle(fontSize: 14)),
                                label: const Text(
                                  'COMPLETE DIRECTIVE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    fontSize: 12,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: effectiveCategoryColor.withValues(alpha: 0.2),
                                  foregroundColor: effectiveCategoryColor,
                                  side: BorderSide(color: effectiveCategoryColor, width: 1.2),
                                  elevation: 4,
                                  shadowColor: effectiveCategoryColor.withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quest_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';

class QuestCard extends StatefulWidget {
  final QuestModel quest;
  final int index;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;

  const QuestCard({
    super.key,
    required this.quest,
    this.index = 0,
    this.onComplete,
    this.onUncomplete,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> with TickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
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
      case 'mind':        return Icons.psychology_rounded;
      case 'body':        return Icons.fitness_center_rounded;
      case 'soul':        return Icons.self_improvement_rounded;
      case 'environment': return Icons.eco_rounded;
      case 'social':      return Icons.people_rounded;
      case 'plan':        return Icons.event_note_rounded;
      case 'reflect':     return Icons.auto_stories_rounded;
      case 'custom':      return Icons.star_rounded;
      default:            return Icons.radio_button_checked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final rankColor = context.watch<UserProvider>().currentRankColor;
    final categoryColor = AppColors.getCategoryColor(widget.quest.category);
    final effectiveColor = widget.quest.isBossQuest ? rankColor : categoryColor;

    final textColor = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final subColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isCompleted = widget.quest.isCompleted;

    final cardBg = isCompleted
        ? const Color(0x2810B981)
        : const Color(0x880C1020);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (widget.index * 50).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, animVal, child) {
        return Opacity(
          opacity: animVal,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - animVal)),
            child: child,
          ),
        );
      },
      child: ScaleTransition(
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
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.08),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Category icon — no border, just tinted bg circle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: effectiveColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.quest.isBossQuest
                              ? Icons.bolt_rounded
                              : _getCategoryIcon(widget.quest.category),
                          color: effectiveColor,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title only
                      Expanded(
                        child: Text(
                          widget.quest.title,
                          style: TextStyle(
                            color: isCompleted
                                ? subColor
                                : textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: subColor,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Check or arrow — tapping checkbox marks complete directly!
                      if (isCompleted)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onUncomplete?.call(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981), size: 22),
                          ),
                        )
                      else
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onComplete?.call(),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.radio_button_unchecked_rounded,
                              color: subColor.withValues(alpha: 0.4),
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),

                // Expanded section
                SizeTransition(
                  sizeFactor: _expandAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        child: GestureDetector(
                          onTap: () {
                            widget.onComplete?.call();
                            setState(() => _isExpanded = false);
                            _expandCtrl.reverse();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: effectiveColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt_rounded,
                                    color: effectiveColor, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Mark Complete',
                                  style: TextStyle(
                                    color: effectiveColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

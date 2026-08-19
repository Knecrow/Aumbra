import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quest_model.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';

class QuestCard extends StatefulWidget {
  final QuestModel quest;
  final int index;
  final bool isGrouped;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;

  const QuestCard({
    super.key,
    required this.quest,
    this.index = 0,
    this.isGrouped = false,
    this.onComplete,
    this.onUncomplete,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> with SingleTickerProviderStateMixin {
  late AnimationController _expandCtrl;
  late Animation<double> _expandAnim;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandCtrl.forward();
      } else {
        _expandCtrl.reverse();
      }
    });
  }

  void _handleCheckboxTap() {
    if (widget.quest.isCompleted) {
      widget.onUncomplete?.call();
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = context.watch<UserProvider>().currentRankColor;
    final categoryColor = AppColors.getCategoryColor(widget.quest.category);
    final effectiveColor = widget.quest.isBossQuest ? rankColor : categoryColor;
    final isCompleted = widget.quest.isCompleted;

    return Container(
      margin: widget.isGrouped
          ? EdgeInsets.zero
          : const EdgeInsets.only(bottom: 10),
      decoration: widget.isGrouped
          ? BoxDecoration(
              color: isCompleted
                  ? Colors.white.withValues(alpha: 0.015)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            )
          : BoxDecoration(
              color: isCompleted ? const Color(0xFF0D0F18) : AppColors.darkCard,
              gradient: isCompleted ? null : AppColors.darkCardGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: widget.quest.isBossQuest && !isCompleted
                  ? [
                      BoxShadow(
                        color: rankColor.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── MAIN INTERACTIVE ROW ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isGrouped ? 12 : 16,
              vertical: widget.isGrouped ? 8 : 12,
            ),
            child: Row(
              children: [
                // ── CHECKBOX WITH GENEROUS HIT-TARGET ──
                InkWell(
                  onTap: _handleCheckboxTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isCompleted ? rankColor : const Color(0xFF1B1E30),
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: rankColor.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  spreadRadius: 0.5,
                                ),
                              ]
                            : null,
                      ),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: isCompleted ? 1.0 : 0.0,
                        curve: Curves.easeOutBack,
                        child: const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.black,
                            size: 15,
                            weight: 900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // ── EXPANDABLE CONTENT AREA ──
                Expanded(
                  child: InkWell(
                    onTap: _toggleExpand,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          // Crisp Vector Category Glyph (No Acrylic Box)
                          Icon(
                            widget.quest.isBossQuest
                                ? Icons.bolt_rounded
                                : AppColors.getCategoryIconData(widget.quest.category),
                            color: isCompleted
                                ? effectiveColor.withValues(alpha: 0.4)
                                : effectiveColor,
                            size: 18,
                          ),
                          const SizedBox(width: 12),

                          // Quest Title & Category Label
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.quest.title,
                                  style: TextStyle(
                                    color: isCompleted
                                        ? AppColors.darkSubText.withValues(alpha: 0.8)
                                        : Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w700,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    decorationColor: AppColors.darkSubText,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.quest.category.toUpperCase(),
                                  style: TextStyle(
                                    color: effectiveColor.withValues(alpha: isCompleted ? 0.4 : 0.8),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Animated Rotating Chevron Indicator
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 220),
                            turns: _isExpanded ? 0.5 : 0.0,
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.darkSubText.withValues(alpha: 0.6),
                              size: 20,
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

          // ── EXPANDED ACCORDION TRAY ────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                widget.isGrouped ? 14 : 16,
                0,
                widget.isGrouped ? 14 : 16,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF090A10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.quest.description,
                      style: const TextStyle(
                        color: AppColors.darkSubText,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Complete / Uncomplete Quick Action Button
                  GestureDetector(
                    onTap: () {
                      _handleCheckboxTap();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        gradient: isCompleted ? null : AppColors.buildRankGradient(rankColor),
                        color: isCompleted ? const Color(0xFF191C28) : null,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isCompleted
                            ? null
                            : [
                                BoxShadow(
                                  color: rankColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted ? Icons.replay_rounded : Icons.verified_rounded,
                            color: isCompleted ? Colors.white : Colors.black,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted ? 'Mark as Incomplete' : 'Complete Quest',
                            style: TextStyle(
                              color: isCompleted ? Colors.white : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
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
        ],
      ),
    );
  }
}


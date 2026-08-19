import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/constants/badges.dart';
import '../../../core/constants/ranks.dart';
import '../../../core/constants/app_colors.dart';

class HallOfFameScreen extends StatelessWidget {
  const HallOfFameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final user = userProvider.user;
    final rankColor = userProvider.currentRankColor;

    if (user == null) return const SizedBox.shrink();

    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark ? AppColors.darkSubText : AppColors.lightSubText;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark
            ? BoxDecoration(gradient: AppColors.buildRankAmbientGradient(rankColor))
            : null,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TITLES & BADGES',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 2),
                      Text(
                        '${user.unlockedBadges.length}/${kBadges.length} badges  ·  ${user.unlockedTitles.length}/${kTitles.length} titles unlocked',
                        style: TextStyle(color: subColor, fontSize: 12),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ─── BADGES ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('BADGES & UNLOCKABLES',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              _buildBadgeGrid(
                  context, user.unlockedBadges, isDark, textColor, subColor, rankColor),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ─── TITLES ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('EARNED PATHS & TITLES',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              _buildTitlesList(context, user.unlockedTitles, isDark, textColor, subColor, rankColor),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),

              // ─── RANK COLOR PREVIEW ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text('SYSTEM CLASSIFICATIONS',
                      style: TextStyle(
                          color: subColor,
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              _buildRankColorGrid(context, user.currentRank, isDark, textColor, subColor),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGrid(
    BuildContext context,
    List<String> unlocked,
    bool isDark,
    Color textColor,
    Color subColor,
    Color rankColor,
  ) {
    // Group by category
    final categories = <String>{};
    for (final b in kBadges) {
      categories.add(b.category);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: categories.map((cat) {
            final catBadges = kBadges.where((b) => b.category == cat).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    cat.toUpperCase(),
                    style: TextStyle(
                        color: rankColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: catBadges.length,
                  itemBuilder: (ctx, i) {
                    final badge = catBadges[i];
                    final earned = unlocked.contains(badge.id);
                    return GestureDetector(
                      onTap: () => _showBadgeDetailModal(context, badge, earned, rankColor, isDark),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: earned
                              ? rankColor.withValues(alpha: 0.15)
                              : const Color(0x880C1020),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              badge.icon,
                              style: TextStyle(
                                  fontSize: 26,
                                  color: earned ? null : Colors.white.withValues(alpha: 0.15)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              badge.name,
                              style: TextStyle(
                                color: earned ? textColor : subColor.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.description,
                              style: TextStyle(
                                color: earned
                                    ? subColor
                                    : subColor.withValues(alpha: 0.4),
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTitlesList(
    BuildContext context,
    List<String> unlocked,
    bool isDark,
    Color textColor,
    Color subColor,
    Color rankColor,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: kTitles.map((title) {
            final earned = unlocked.contains(title.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: earned
                    ? rankColor.withValues(alpha: 0.12)
                    : const Color(0x880C1020),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    earned ? '✦' : '◇',
                    style: TextStyle(
                        color: earned ? rankColor : subColor.withValues(alpha: 0.3),
                        fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.name,
                          style: TextStyle(
                            color:
                                earned ? textColor : subColor.withValues(alpha: 0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          title.description,
                          style: TextStyle(
                            color: earned
                                ? subColor
                                : subColor.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (earned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rankColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'EARNED',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    )
                  else
                    Text(
                      'LOCKED',
                      style: TextStyle(
                        color: subColor.withValues(alpha: 0.25),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRankColorGrid(BuildContext context, int currentRank, bool isDark,
      Color textColor, Color subColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: kRanks.length,
          itemBuilder: (ctx, i) {
            final rank = kRanks[i];
            final isReached = currentRank >= rank.rankNumber;
            final color = rank.color;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isReached
                        ? color.withValues(alpha: 0.2)
                        : const Color(0x880C1020),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isReached ? color : color.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                  Text(
                    rank.name,
                    style: TextStyle(
                      color: isReached ? color : subColor.withValues(alpha: 0.4),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
        ),
      ),
    );
  }

  void _showBadgeDetailModal(
    BuildContext context,
    BadgeInfo badge,
    bool earned,
    Color rankColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F1222) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: earned ? rankColor.withValues(alpha: 0.15) : (isDark ? const Color(0x14FFFFFF) : const Color(0x14000000)),
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 34,
                    color: earned ? null : Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: earned ? rankColor.withValues(alpha: 0.15) : const Color(0x15FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                earned ? 'UNLOCKED' : 'LOCKED',
                style: TextStyle(
                  color: earned ? rankColor : const Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              badge.description,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: rankColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

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
            ? const BoxDecoration(gradient: AppColors.darkBackgroundGradient)
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
                      Text('TITLES',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 2),
                      Text(
                        '${user.unlockedBadges.length}/${kBadges.length} badges  ·  ${user.unlockedTitles.length}/${kTitles.length} titles',
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
                  child: Text('[ SYSTEM CLASSIFICATIONS ]',
                      style: TextStyle(
                          color: subColor,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900)),
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
                    final bgColor = earned
                        ? rankColor.withValues(alpha: 0.15)
                        : (isDark ? const Color(0xFF090A16) : const Color(0xFFF1F5F9));
                    final borderColor = earned
                        ? rankColor.withValues(alpha: 0.5)
                        : (isDark ? const Color(0xFF1E2036) : const Color(0xFFE2E8F0));

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor, width: 1),
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
            final bgColor = earned
                ? rankColor.withValues(alpha: 0.12)
                : (isDark ? const Color(0xFF090A16) : const Color(0xFFF1F5F9));
            final borderColor = earned
                ? rankColor.withValues(alpha: 0.4)
                : (isDark ? const Color(0xFF1E2036) : const Color(0xFFE2E8F0));

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor, width: earned ? 1.5 : 1.0),
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
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: rankColor.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        'EARNED',
                        style: TextStyle(
                          color: rankColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
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
                        ? color.withValues(alpha: 0.3)
                        : const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isReached
                          ? color.withValues(alpha: 0.5)
                          : const Color(0x14FFFFFF),
                      width: currentRank == rank.rankNumber ? 1.8 : 1,
                    ),
                    boxShadow: isReached
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
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
}

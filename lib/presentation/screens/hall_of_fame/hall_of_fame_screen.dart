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
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: rankColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HALL OF FAME',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${user.unlockedBadges.length}/${kBadges.length} Badges  ·  ${user.unlockedTitles.length}/${kTitles.length} Titles',
                        style: TextStyle(color: AppColors.getLightVariant(rankColor), fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ─── BADGES ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 12,
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('BADGES',
                          style: TextStyle(
                              color: AppColors.darkSubText,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              _buildBadgeGrid(
                  context, user.unlockedBadges, isDark, textColor, subColor, rankColor),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ─── TITLES ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 12,
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('TITLES',
                          style: TextStyle(
                              color: AppColors.darkSubText,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              _buildTitlesList(context, user.unlockedTitles, isDark, textColor, subColor, rankColor),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ─── RANK COLOR PREVIEW ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 12,
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('CLASSIFICATIONS',
                          style: TextStyle(
                              color: AppColors.darkSubText,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
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
    final categories = <String>{};
    for (final b in kBadges) {
      categories.add(b.category);
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            gradient: AppColors.darkCardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: categories.toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final cat = entry.value;
              final catBadges = kBadges.where((b) => b.category == cat).toList();
              final earnedCount = catBadges.where((b) => unlocked.contains(b.id)).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (idx > 0) ...[
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                    const SizedBox(height: 14),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.military_tech_rounded, color: rankColor, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            cat.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$earnedCount / ${catBadges.length} UNLOCKED',
                        style: TextStyle(
                          color: AppColors.getLightVariant(rankColor),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List.generate(catBadges.length, (i) {
                      final badge = catBadges[i];
                      final earned = unlocked.contains(badge.id);

                      return Column(
                        children: [
                          InkWell(
                            onTap: () => _showBadgeDetailModal(context, badge, earned, rankColor, isDark),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                              child: Row(
                                children: [
                                  // Gaming Trophy/Badge Icon Disc
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: earned ? const Color(0xFF0E0E0E) : const Color(0xFF050505),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: earned
                                          ? [
                                              BoxShadow(
                                                color: rankColor.withValues(alpha: 0.20),
                                                blurRadius: 10,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        badge.iconData,
                                        size: 20,
                                        color: earned
                                            ? AppColors.getLightVariant(rankColor)
                                            : AppColors.darkDimText.withValues(alpha: 0.25),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Badge Name & Requirement
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          badge.name,
                                          style: TextStyle(
                                            color: earned ? Colors.white : AppColors.darkDimText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          badge.description,
                                          style: TextStyle(
                                            color: earned
                                                ? AppColors.darkSubText
                                                : AppColors.darkDimText.withValues(alpha: 0.4),
                                            fontSize: 11,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Gaming Status Pill / Lock Icon
                                  if (earned)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: rankColor.withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle_rounded,
                                              color: AppColors.getLightVariant(rankColor), size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'UNLOCKED',
                                            style: TextStyle(
                                              color: AppColors.getLightVariant(rankColor),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.darkDimText.withValues(alpha: 0.3),
                                        size: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (i < catBadges.length - 1)
                            Divider(height: 1, color: Colors.white.withValues(alpha: 0.04)),
                        ],
                      );
                    }),
                  ),
                ],
              );
            }).toList(),
          ),
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
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            gradient: AppColors.darkCardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(kTitles.length, (i) {
              final title = kTitles[i];
              final earned = unlocked.contains(title.id);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          earned ? Icons.workspace_premium_rounded : Icons.workspace_premium_outlined,
                          color: earned ? rankColor : AppColors.darkDimText.withValues(alpha: 0.4),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title.name,
                                style: TextStyle(
                                  color: earned ? Colors.white : AppColors.darkDimText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                title.description,
                                style: TextStyle(
                                  color: earned ? AppColors.darkSubText : AppColors.darkDimText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (earned)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: AppColors.buildRankGradient(rankColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'EARNED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          )
                        else
                          Text(
                            'LOCKED',
                            style: TextStyle(
                              color: AppColors.darkDimText.withValues(alpha: 0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (i < kTitles.length - 1)
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.04)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildRankColorGrid(BuildContext context, int currentRank, bool isDark,
      Color textColor, Color subColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            gradient: AppColors.darkCardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
                          ? const Color(0xFF0F0F0F)
                          : const Color(0xFF050505),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isReached ? color : color.withValues(alpha: 0.2),
                          boxShadow: isReached
                              ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rank.name,
                  style: TextStyle(
                    color: isReached ? Colors.white : AppColors.darkDimText,
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
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: earned ? AppColors.goldPrimary.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
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
                color: earned ? rankColor.withValues(alpha: 0.15) : const Color(0x14FFFFFF),
                boxShadow: earned
                    ? [
                        BoxShadow(
                          color: rankColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  badge.iconData,
                  size: 34,
                  color: earned ? AppColors.getLightVariant(rankColor) : Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: earned ? AppColors.goldPrimary.withValues(alpha: 0.15) : const Color(0x15FFFFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                earned ? 'UNLOCKED' : 'LOCKED',
                style: TextStyle(
                  color: earned ? AppColors.goldLight : AppColors.darkSubText,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              badge.description,
              style: const TextStyle(
                color: AppColors.darkSubText,
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
            child: const Text('CLOSE', style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}


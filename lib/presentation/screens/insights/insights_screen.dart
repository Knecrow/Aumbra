import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/ranks.dart';
import '../../widgets/rank_widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  Map<String, int> _categoryBreakdown = {};
  List<Map<String, dynamic>> _streakHistory = [];
  List<Map<String, dynamic>> _heatmapData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final up = context.read<UserProvider>();
    final cat = await up.getCategoryBreakdown();
    final streak = await up.getStreakHistory();
    final heatmap = await up.getHeatmapData();

    if (mounted) {
      setState(() {
        _categoryBreakdown = cat;
        _streakHistory = streak;
        _heatmapData = heatmap;
        _loading = false;
      });
    }
  }

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
    const cardBg = Color(0x880C1020);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark
            ? BoxDecoration(gradient: AppColors.buildRankAmbientGradient(rankColor))
            : null,
        child: SafeArea(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: rankColor))
              : CustomScrollView(
                  slivers: [
                    // Title
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('INSIGHTS',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text('Attributes & performance',
                                style: TextStyle(color: subColor, fontSize: 12)),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    // ─── STAT CARDS ───────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    value: user.totalQuestsCompleted.toString(),
                                    label: 'Total Completed',
                                    icon: Icons.check_circle_rounded,
                                    accentColor: rankColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: StatCard(
                                    value: user.longestStreak.toString(),
                                    label: 'Longest Streak',
                                    icon: Icons.local_fire_department_rounded,
                                    accentColor: const Color(0xFFFF9100),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    value: userProvider.daysSinceStart.toString(),
                                    label: 'Days Active',
                                    icon: Icons.bolt_rounded,
                                    accentColor: const Color(0xFF00E676),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: StatCard(
                                    value: userProvider.estimatedDaysToAbsolute.toString(),
                                    label: 'Days to Absolute',
                                    icon: Icons.workspace_premium_rounded,
                                    accentColor: const Color(0xFFE040FB),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ─── STREAK HISTORY LINE CHART ─────────────────────────
                  if (_streakHistory.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Streak Record',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            Container(
                              height: 160,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _buildStreakChart(rankColor, isDark),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                  // ─── COMPLETION HEATMAP ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Completion Heatmap',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            Container(
                              height: 160,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _buildHeatmap(rankColor, isDark, subColor),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // ─── CATEGORY DONUT CHART ─────────────────────────────
                  if (_categoryBreakdown.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category Attributes',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            Container(
                              height: 220,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _buildCategoryDonut(textColor),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                  // ─── RANK PROGRESSION ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rank Progression',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rank ${user.currentRank} of 15 — ${getRankInfo(user.currentRank).name}',
                                  style: TextStyle(
                                      color: rankColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 12),
                                // Simple step visualization
                                Row(
                                  children: List.generate(15, (i) {
                                    final reached = user.currentRank > i;
                                    final current = user.currentRank == i + 1;
                                    final rankCol = kRanks[i].color;
                                    return Expanded(
                                      child: Container(
                                        height: current ? 24 : 16,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          color: reached || current
                                              ? rankCol.withValues(alpha: 0.8)
                                              : const Color(0x11FFFFFF),
                                          borderRadius: BorderRadius.circular(1),
                                          border: current
                                              ? Border.all(color: rankCol, width: 1.5)
                                              : null,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Awakened',
                                        style: TextStyle(color: subColor, fontSize: 9)),
                                    const Text('Absolute',
                                        style: TextStyle(
                                            color: Color(0xFFFFD700), fontSize: 9)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildStreakChart(Color rankColor, bool isDark) {
    if (_streakHistory.isEmpty) {
      return Center(
          child: Text('No data yet', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _streakHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), (_streakHistory[i]['streak_value'] as int).toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0x0DFFFFFF),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (val, meta) => Text(
                val.toInt().toString(),
                style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: rankColor,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: rankColor.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmap(Color rankColor, bool isDark, Color subColor) {
    // Build last 84 days (12 weeks)
    final today = DateTime.now();
    final days = <DateTime>[];
    for (int i = 83; i >= 0; i--) {
      days.add(today.subtract(Duration(days: i)));
    }

    // Map date strings to completion data
    final completionMap = <String, int>{};
    for (final row in _heatmapData) {
      completionMap[row['date'] as String] =
          (row['all_completed'] as int?) ?? 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((d) {
            return Expanded(
              child: Text(d,
                  style: TextStyle(color: subColor, fontSize: 9),
                  textAlign: TextAlign.center),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: days.length,
            itemBuilder: (ctx, i) {
              final day = days[i];
              final dateStr =
                  '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
              final status = completionMap[dateStr];

              Color cellColor;
              if (status == null) {
                cellColor = const Color(0x0DFFFFFF);
              } else if (status == 1) {
                cellColor = const Color(0xFF26de81);
              } else {
                cellColor = const Color(0xFFFF6B6B).withValues(alpha: 0.5);
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _heatLegend(const Color(0xFF26de81), 'Complete', isDark),
            const SizedBox(width: 12),
            _heatLegend(const Color(0xFFFF6B6B).withValues(alpha: 0.5), 'Partial', isDark),
            const SizedBox(width: 12),
            _heatLegend(
                const Color(0x0DFFFFFF),
                'No data', isDark),
          ],
        ),
      ],
    );
  }

  Widget _heatLegend(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
      ],
    );
  }

  Widget _buildCategoryDonut(Color textColor) {
    if (_categoryBreakdown.isEmpty) {
      return const Center(child: Text('No data yet'));
    }

    final sections = <PieChartSectionData>[];
    final total = _categoryBreakdown.values.fold(0, (a, b) => a + b);

    _categoryBreakdown.forEach((cat, count) {
      final color = AppColors.getCategoryColor(cat);
      final pct = (count / total * 100).toStringAsFixed(0);
      sections.add(PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: '$pct%',
        radius: 55,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
      ));
    });

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categoryBreakdown.entries.map((e) {
              final color = AppColors.getCategoryColor(e.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${e.key} (${e.value})',
                        style: TextStyle(color: textColor, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

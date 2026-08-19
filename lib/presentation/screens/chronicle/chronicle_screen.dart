import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/history_entry.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/rank_widgets.dart';

class ChronicleScreen extends StatefulWidget {
  const ChronicleScreen({super.key});

  @override
  State<ChronicleScreen> createState() => _ChronicleScreenState();
}

class _ChronicleScreenState extends State<ChronicleScreen> {
  List<HistoryEntry> _history = [];
  Map<String, int> _categoryBreakdown = {};
  List<Map<String, dynamic>> _streakHistory = [];
  bool _loading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    final up = context.read<UserProvider>();
    final history = await up.getHistory();
    final cat = await up.getCategoryBreakdown();
    final streak = await up.getStreakHistory();

    if (mounted) {
      setState(() {
        _history = history;
        _categoryBreakdown = cat;
        _streakHistory = streak;
        _loading = false;
        _isRefreshing = false;
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
                            Text('STATS',
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0)),
                            const SizedBox(height: 2),
                            Text('Activity, attributes & history',
                                style: TextStyle(
                                    color: subColor,
                                    fontSize: 12)),
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
                                    label: 'Total Quests',
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
                                    label: 'Days Awakened',
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

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // ─── WEEKLY ACTIVITY GRAPH ──────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildActivityChart(rankColor, isDark, subColor, textColor),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // ─── STREAK HISTORY LINE CHART ─────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Streak Record',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Daily streak progress over time',
                                style: TextStyle(color: subColor, fontSize: 11)),
                            const SizedBox(height: 12),
                            Container(
                              height: 160,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0x880C1020),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _buildStreakChart(rankColor, isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // ─── CATEGORY ATTRIBUTES DONUT ─────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Attributes',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Quest completion by category',
                                style: TextStyle(color: subColor, fontSize: 11)),
                            const SizedBox(height: 12),
                            Container(
                              height: 210,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0x880C1020),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _buildCategoryDonut(textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // ─── THE MIRROR ───────────────────────────────────────────
                    if (_history.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('The Mirror',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text('First vs most recent',
                                  style: TextStyle(color: subColor, fontSize: 11)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMirrorCard(
                                      'First Quest',
                                      _history.last,
                                      isDark,
                                      textColor,
                                      subColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMirrorCard(
                                      'Most Recent',
                                      _history.first,
                                      isDark,
                                      textColor,
                                      subColor,
                                      isRecent: true,
                                      rankColor: rankColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // ─── HISTORY TIMELINE ────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                            Text(
                              'QUEST RECORDS',
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 13,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _history.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(60),
                                child: Column(
                                  children: [
                                    Icon(Icons.auto_stories_rounded,
                                        size: 40,
                                        color: rankColor.withValues(alpha: 0.6)),
                                    const SizedBox(height: 16),
                                    Text('Your chronicle is empty.',
                                        style: TextStyle(
                                            color: subColor, fontSize: 14, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text('Complete your first quest to begin.',
                                        style: TextStyle(
                                            color: subColor.withValues(alpha: 0.6),
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final entry = _history[index];
                                final isNewDay = index == 0 ||
                                    DateFormat('yyyy-MM-dd').format(entry.completedDate) !=
                                        DateFormat('yyyy-MM-dd').format(_history[index - 1].completedDate);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 3),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isNewDay) ...[
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
                                          child: Text(
                                            DateFormat('MMM d').format(entry.completedDate).toUpperCase(),
                                            style: TextStyle(
                                              color: subColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                      _buildHistoryItem(
                                          entry, isDark, textColor, subColor, rankColor),
                                    ],
                                  ),
                                );
                              },
                              childCount: _history.length,
                            ),
                          ),

                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMirrorCard(
    String label,
    HistoryEntry entry,
    bool isDark,
    Color textColor,
    Color subColor, {
    bool isRecent = false,
    Color? rankColor,
  }) {
    final color = isRecent ? (rankColor ?? const Color(0xFF94A3B8)) : const Color(0xFF94A3B8);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRecent ? (rankColor ?? const Color(0xFF94A3B8)).withValues(alpha: 0.12) : const Color(0x880C1020),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            entry.questTitle,
            style: TextStyle(
                color: textColor, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat('MMM d, yyyy').format(entry.completedDate),
            style: TextStyle(color: subColor, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.rankAtTime,
              style: TextStyle(
                  color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
      HistoryEntry entry, bool isDark, Color textColor, Color subColor, Color rankColor) {
    final categoryColor = AppColors.getCategoryColor(entry.questCategory);
    final categoryIcon = AppColors.getCategoryIconData(entry.questCategory);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x880C1020),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.questTitle,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.questCategory.toUpperCase()} · ${entry.rankAtTime}',
                  style: TextStyle(color: subColor, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('h:mm a').format(entry.completedDate),
            style: TextStyle(color: subColor, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(Color rankColor, bool isDark, Color subColor, Color textColor) {
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final Map<String, int> dayCounts = {};
    for (final entry in _history) {
      final d = DateTime(entry.completedDate.year, entry.completedDate.month, entry.completedDate.day);
      final key = DateFormat('yyyy-MM-dd').format(d);
      dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    }

    double maxY = 4;
    for (final day in last7Days) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      final count = dayCounts[key] ?? 0;
      if (count > maxY) maxY = count.toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Activity',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Quests completed over the last 7 days',
          style: TextStyle(color: subColor, fontSize: 11),
        ),
        const SizedBox(height: 12),
        Container(
          height: 170,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            color: const Color(0x880C1020),
            borderRadius: BorderRadius.circular(16),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY + 1,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => isDark ? const Color(0xFF1E2036) : Colors.black87,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.round()} quests',
                      const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= last7Days.length) return const SizedBox.shrink();
                      final day = last7Days[idx];
                      final isToday = day.day == now.day && day.month == now.month;
                      final label = isToday ? 'TODAY' : DateFormat('E').format(day).toUpperCase();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: isToday ? rankColor : subColor,
                            fontSize: 9,
                            fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(last7Days.length, (i) {
                final day = last7Days[i];
                final key = DateFormat('yyyy-MM-dd').format(day);
                final count = (dayCounts[key] ?? 0).toDouble();
                final isToday = day.day == now.day && day.month == now.month;

                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: count,
                      gradient: count > 0
                          ? LinearGradient(
                              colors: [
                                isToday ? rankColor : rankColor.withValues(alpha: 0.9),
                                isToday ? rankColor.withValues(alpha: 0.4) : rankColor.withValues(alpha: 0.2),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: count > 0
                          ? null
                          : (isDark ? const Color(0xFF141828) : const Color(0xFFE2E8F0)),
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildStreakChart(Color rankColor, bool isDark) {
    final spots = <FlSpot>[];
    if (_streakHistory.isEmpty) {
      spots.addAll([
        const FlSpot(0, 0),
        const FlSpot(1, 1),
        const FlSpot(2, 1),
        const FlSpot(3, 2),
        const FlSpot(4, 3),
      ]);
    } else {
      for (int i = 0; i < _streakHistory.length; i++) {
        spots.add(FlSpot(i.toDouble(), (_streakHistory[i]['streak_value'] as int).toDouble()));
      }
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

  Widget _buildCategoryDonut(Color textColor) {
    final data = _categoryBreakdown.isEmpty
        ? {'Mind': 1, 'Body': 1, 'Soul': 1, 'Environment': 1, 'Oath': 1}
        : _categoryBreakdown;

    final sections = <PieChartSectionData>[];
    final total = data.values.fold(0, (a, b) => a + b);

    data.forEach((cat, count) {
      final color = AppColors.getCategoryColor(cat);
      final pct = (count / total * 100).toStringAsFixed(0);
      sections.add(PieChartSectionData(
        color: color,
        value: count.toDouble(),
        title: '$pct%',
        radius: 50,
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
            centerSpaceRadius: 36,
            sectionsSpace: 2,
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((e) {
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

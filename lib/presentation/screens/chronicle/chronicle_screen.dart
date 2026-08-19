import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/history_entry.dart';
import '../../../core/constants/app_colors.dart';

class ChronicleScreen extends StatefulWidget {
  const ChronicleScreen({super.key});

  @override
  State<ChronicleScreen> createState() => _ChronicleScreenState();
}

class _ChronicleScreenState extends State<ChronicleScreen> {
  List<HistoryEntry> _history = [];
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
    final streak = await up.getStreakHistory();

    if (mounted) {
      setState(() {
        _history = history;
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
    final rankInfo = userProvider.currentRankInfo;
    final rankColor = userProvider.currentRankColor;

    if (user == null) return const SizedBox.shrink();

    final completionsReq = rankInfo.completionsRequired;
    final userCompletions = user.rankCompletions;
    final ascProgress = completionsReq > 0 ? (userCompletions / completionsReq).clamp(0.0, 1.0) : 1.0;

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
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    // ─── TITLE ────────────────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                        child: Row(
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
                              'CHRONICLE',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── PANEL 1: UNIFIED 4-METRIC COMMAND DECK ───────────────────────
                    SliverToBoxAdapter(
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
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      'TOTAL QUESTS',
                                      user.totalQuestsCompleted.toString(),
                                      Icons.verified_rounded,
                                      rankColor,
                                    ),
                                  ),
                                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.06)),
                                  Expanded(
                                    child: _buildMetricTile(
                                      'LONGEST STREAK',
                                      '${user.longestStreak}d',
                                      Icons.local_fire_department_rounded,
                                      const Color(0xFFFF9100),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      'DAYS AWAKENED',
                                      userProvider.daysSinceStart.toString(),
                                      Icons.bolt_rounded,
                                      const Color(0xFF00E676),
                                    ),
                                  ),
                                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.06)),
                                  Expanded(
                                    child: _buildMetricTile(
                                      'ASCENSION',
                                      '${(ascProgress * 100).round()}%',
                                      Icons.military_tech_rounded,
                                      rankColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 18)),

                    // ─── PANEL 2: UNIFIED ACTIVITY & STREAK TRENDS ────────────────────
                    SliverToBoxAdapter(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.query_stats_rounded, color: rankColor, size: 16),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'TRAJECTORY',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'LAST 7 DAYS',
                                    style: TextStyle(
                                      color: AppColors.getLightVariant(rankColor),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 160,
                                child: _buildActivityChart(rankColor, isDark, subColor, textColor),
                              ),
                              const SizedBox(height: 16),
                              Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(Icons.show_chart_rounded, color: rankColor, size: 15),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'STREAK GROWTH',
                                    style: TextStyle(
                                      color: AppColors.darkSubText,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 120,
                                child: _buildStreakChart(rankColor, isDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 18)),

                    // ─── PANEL 3: UNIFIED MISSION ARCHIVE & MIRROR ────────────────────
                    SliverToBoxAdapter(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.auto_stories_rounded, color: rankColor, size: 16),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ARCHIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${_history.length} LOGGED',
                                    style: TextStyle(
                                      color: AppColors.getLightVariant(rankColor),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Grouped History entries
                              if (_history.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'No mission entries logged yet.',
                                      style: TextStyle(color: AppColors.darkSubText, fontSize: 12),
                                    ),
                                  ),
                                )
                              else
                                Column(
                                  children: List.generate(_history.length.clamp(0, 10), (i) {
                                    final entry = _history[i];
                                    return Column(
                                      children: [
                                        _buildHistoryRow(entry, isDark, textColor, subColor, rankColor),
                                        if (i < _history.length.clamp(0, 10) - 1)
                                          Divider(height: 1, color: Colors.white.withValues(alpha: 0.04)),
                                      ],
                                    );
                                  }),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkSubText,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(
    HistoryEntry entry,
    bool isDark,
    Color textColor,
    Color subColor,
    Color rankColor,
  ) {
    final categoryColor = AppColors.getCategoryColor(entry.questCategory);
    final categoryIcon = AppColors.getCategoryIconData(entry.questCategory);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(
            categoryIcon,
            color: categoryColor,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.questTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.questCategory.toUpperCase()} · ${DateFormat('MMM d, h:mm a').format(entry.completedDate)}',
                  style: const TextStyle(color: AppColors.darkSubText, fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              entry.rankAtTime.toUpperCase(),
              style: TextStyle(
                color: AppColors.getLightVariant(rankColor),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
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

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF14141A),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} quests',
                TextStyle(color: AppColors.getLightVariant(rankColor), fontSize: 11, fontWeight: FontWeight.bold),
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
                      color: isToday ? rankColor : AppColors.darkSubText,
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
                          isToday ? AppColors.getLightVariant(rankColor) : rankColor,
                          isToday ? rankColor : AppColors.getDeepVariant(rankColor),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: count > 0 ? null : const Color(0xFF0E0E14),
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
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
                style: const TextStyle(color: AppColors.darkSubText, fontSize: 10),
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
            gradient: AppColors.buildRankGradient(rankColor),
            barWidth: 3.0,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  rankColor.withValues(alpha: 0.25),
                  rankColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/history_entry.dart';
import '../../widgets/tactical_panel.dart';
import '../../widgets/tactical_icons.dart';
import '../../widgets/tactical_particle_canvas.dart';

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
      body: TacticalParticleCanvas(
        rankColor: rankColor,
        particleCount: 18,
        child: Container(
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
                              'STATS & PROGRESS',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── PANEL 1: CAREER SCOREBOARD ───────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TacticalPanel(
                          rankColor: rankColor,
                          showHeader: true,
                          tacticalTag: 'PERFORMANCE OVERVIEW',
                          statusBadge: 'ACS ${(user.totalQuestsCompleted * 25 + user.currentStreak * 10)}',
                          chamferSize: 14.0,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      'HABITS COMPLETED',
                                      user.totalQuestsCompleted.toString(),
                                      TacticalGlyphType.completed,
                                      rankColor,
                                    ),
                                  ),
                                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.08)),
                                  Expanded(
                                    child: _buildMetricTile(
                                      'BEST STREAK',
                                      '${user.longestStreak}D',
                                      TacticalGlyphType.streak,
                                      const Color(0xFFFF4655), // Valorant Red
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricTile(
                                      'DAYS ACTIVE',
                                      userProvider.daysSinceStart.toString(),
                                      TacticalGlyphType.body,
                                      const Color(0xFF00E676),
                                    ),
                                  ),
                                  Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.08)),
                                  Expanded(
                                    child: _buildMetricTile(
                                      'RANK PROGRESS',
                                      '${(ascProgress * 100).round()}%',
                                      TacticalGlyphType.navArsenal,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TacticalPanel(
                          rankColor: rankColor,
                          showHeader: true,
                          tacticalTag: '7-DAY ACTIVITY TREND',
                          statusBadge: 'ACTIVE',
                          chamferSize: 14.0,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 150,
                                child: _buildActivityChart(rankColor, isDark, subColor, textColor),
                              ),
                              const SizedBox(height: 14),
                              Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.show_chart_rounded, color: rankColor, size: 15),
                                  const SizedBox(width: 6),
                                  Text(
                                    'STREAK GROWTH',
                                    style: GoogleFonts.spaceMono(
                                      color: AppColors.darkSubText,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TacticalPanel(
                          rankColor: rankColor,
                          showHeader: true,
                          tacticalTag: 'COMPLETION HISTORY',
                          statusBadge: '${_history.length} LOGGED',
                          chamferSize: 14.0,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Grouped History entries
                              if (_history.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'No entries logged yet.',
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
                                          const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    TacticalGlyphType glyphType,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TacticalGlyph(type: glyphType, color: color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.spaceMono(
                  color: AppColors.darkSubText,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 22,
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

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF06070B),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 0.8),
      ),
      child: Row(
        children: [
          TacticalGlyph.fromCategory(
            entry.questCategory,
            color: categoryColor,
            size: 16,
            isCompleted: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.questTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '// ${entry.questCategory.toUpperCase()} · ${DateFormat('MMM d, h:mm a').format(entry.completedDate).toUpperCase()}',
                  style: GoogleFonts.spaceMono(color: const Color(0xFF7A8394), fontSize: 9),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              border: Border.all(color: rankColor.withValues(alpha: 0.6), width: 0.8),
            ),
            child: Text(
              'S-TIER',
              style: GoogleFonts.spaceMono(
                color: AppColors.getLightVariant(rankColor),
                fontSize: 8.5,
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
            getTooltipColor: (_) => const Color(0xFF0C0E14),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()} PROTOCOLS',
                GoogleFonts.spaceMono(color: rankColor, fontSize: 10, fontWeight: FontWeight.bold),
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
                    style: GoogleFonts.spaceMono(
                      color: isToday ? rankColor : const Color(0xFF76808F),
                      fontSize: 8.5,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x0CFFFFFF), strokeWidth: 0.8),
        ),
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
                color: count > 0 ? null : const Color(0xFF161A26),
                width: 14,
                borderRadius: BorderRadius.zero,
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
        const FlSpot(5, 5),
        const FlSpot(6, 7),
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
            strokeWidth: 0.8,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx % 2 != 0 || idx >= spots.length) return const SizedBox.shrink();
                return Text(
                  'D${idx + 1}',
                  style: GoogleFonts.spaceMono(color: const Color(0xFF76808F), fontSize: 8.5, fontWeight: FontWeight.w700),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: rankColor,
            barWidth: 2.2,
            isStrokeCapRound: false,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: Colors.white,
                  strokeWidth: 1.5,
                  strokeColor: rankColor,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  rankColor.withValues(alpha: 0.22),
                  Colors.transparent,
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


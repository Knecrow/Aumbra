import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/chronicle/chronicle_screen.dart';
import '../screens/hall_of_fame/hall_of_fame_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback onSignOut;
  const MainNavigation({super.key, required this.onSignOut});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _tabs = [
    _TabItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: 'HUD'),
    _TabItem(icon: Icons.show_chart_rounded, activeIcon: Icons.show_chart_rounded, label: 'STATS'),
    _TabItem(icon: Icons.workspace_premium_rounded, activeIcon: Icons.workspace_premium_rounded, label: 'TITLES'),
    _TabItem(icon: Icons.tune_rounded, activeIcon: Icons.tune_rounded, label: 'SYSTEM'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    _fadeCtrl.reverse().then((_) {
      setState(() => _currentIndex = index);
      _fadeCtrl.forward();
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const ChronicleScreen();
      case 2: return const HallOfFameScreen();
      case 3: return SettingsScreen(onSignOut: widget.onSignOut);
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final reduce = themeProvider.reduceEffects;
    final rankColor = userProvider.currentRankColor;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(_fadeAnim),
          child: IndexedStack(
            index: _currentIndex,
            children: List.generate(4, (i) => _buildPage(i)),
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(reduce, rankColor),
    );
  }

  Widget _buildBottomNav(bool reduce, Color rankColor) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    final navContent = Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xDC0B0E1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? rankColor.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Stack(
            children: [
              // Smooth sliding indicator pill
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment(-1.0 + (_currentIndex * (2.0 / (_tabs.length - 1))), 0),
                child: FractionallySizedBox(
                  widthFactor: 1.0 / _tabs.length,
                  heightFactor: 0.8,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withValues(alpha: 0.15),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab items row
              Row(
                children: List.generate(_tabs.length, (i) {
                  final isSelected = i == _currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _onTabTap(i),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _tabs[i].icon,
                            color: isSelected ? rankColor : inactiveColor,
                            size: 19,
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: isSelected ? rankColor : inactiveColor,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                            child: Text(_tabs[i].label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );

    if (reduce) return Padding(padding: const EdgeInsets.only(bottom: 0), child: navContent);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: navContent,
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';
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
    _TabItem(icon: Icons.home_outlined, label: 'HUD'),
    _TabItem(icon: Icons.analytics_outlined, label: 'STATS'),
    _TabItem(icon: Icons.military_tech_outlined, label: 'TITLES'),
    _TabItem(icon: Icons.settings_outlined, label: 'SYSTEM'),
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
        color: isDark ? const Color(0xDC0B0E1A) : const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? rankColor.withValues(alpha: 0.25) : AppColors.lightGlassBorder,
          width: 1.2,
        ),
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
          height: 62,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final isSelected = i == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTabTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: isSelected
                              ? BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: rankColor.withValues(alpha: 0.15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: rankColor.withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                )
                              : null,
                          child: Icon(
                            _tabs[i].icon,
                            color: isSelected ? rankColor : inactiveColor,
                            size: isSelected ? 20 : 19,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isSelected ? rankColor : inactiveColor,
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                          child: Text(_tabs[i].label),
                        ),
                        // Sharp active indicator bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(top: 3),
                          width: isSelected ? 18 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: rankColor,
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: isSelected ? [
                              BoxShadow(color: rankColor, blurRadius: 4)
                            ] : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
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
  final String label;
  const _TabItem({required this.icon, required this.label});
}

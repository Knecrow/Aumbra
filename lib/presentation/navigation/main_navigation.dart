import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/chronicle/chronicle_screen.dart';
import '../screens/hall_of_fame/hall_of_fame_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/tactical_icons.dart';

class MainNavigation extends StatefulWidget {
  final VoidCallback onSignOut;
  const MainNavigation({super.key, required this.onSignOut});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0: return const HomeScreen(key: ValueKey('home'));
      case 1: return const ChronicleScreen(key: ValueKey('chronicle'));
      case 2: return const HallOfFameScreen(key: ValueKey('hall_of_fame'));
      case 3: return SettingsScreen(key: const ValueKey('settings'), onSignOut: widget.onSignOut);
      default: return const HomeScreen(key: ValueKey('home'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final reduce = themeProvider.reduceEffects;
    final rankColor = userProvider.currentRankColor;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: _buildPage(_currentIndex),
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomDock(reduce, rankColor),
    );
  }

  Widget _buildBottomDock(bool reduce, Color rankColor) {
    const inactiveColor = Color(0xFF76808F);
    final lightRankColor = AppColors.getLightVariant(rankColor);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0C0E14).withValues(alpha: 0.82),
            border: Border.all(
              color: rankColor.withValues(alpha: 0.35),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.85),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: rankColor.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 1. Habits / Daily
                  _NavTabItem(
                    glyphType: TacticalGlyphType.navProtocol,
                    label: 'HABITS',
                    isSelected: _currentIndex == 0,
                    onTap: () => _onTabTap(0),
                    activeColor: lightRankColor,
                    rankColor: rankColor,
                    inactiveColor: inactiveColor,
                  ),

                  // 2. Stats / Progress
                  _NavTabItem(
                    glyphType: TacticalGlyphType.navCareer,
                    label: 'STATS',
                    isSelected: _currentIndex == 1,
                    onTap: () => _onTabTap(1),
                    activeColor: lightRankColor,
                    rankColor: rankColor,
                    inactiveColor: inactiveColor,
                  ),

                  // 3. Badges / Ranks
                  _NavTabItem(
                    glyphType: TacticalGlyphType.navArsenal,
                    label: 'BADGES',
                    isSelected: _currentIndex == 2,
                    onTap: () => _onTabTap(2),
                    activeColor: lightRankColor,
                    rankColor: rankColor,
                    inactiveColor: inactiveColor,
                  ),

                  // 4. Settings
                  _NavTabItem(
                    glyphType: TacticalGlyphType.navConfig,
                    label: 'SETTINGS',
                    isSelected: _currentIndex == 3,
                    onTap: () => _onTabTap(3),
                    activeColor: lightRankColor,
                    rankColor: rankColor,
                    inactiveColor: inactiveColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ── VALORANT TACTICAL NAV TAB ITEM ──────────────────────────────────────────
class _NavTabItem extends StatefulWidget {
  final TacticalGlyphType glyphType;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;
  final Color rankColor;
  final Color inactiveColor;

  const _NavTabItem({
    required this.glyphType,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.rankColor,
    required this.inactiveColor,
  });

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem> with SingleTickerProviderStateMixin {
  late AnimationController _touchCtrl;
  late Animation<double> _touchScale;

  @override
  void initState() {
    super.initState();
    _touchCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _touchScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _touchCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _touchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _touchCtrl.forward(),
        onTapUp: (_) {
          _touchCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _touchCtrl.reverse(),
        child: ScaleTransition(
          scale: _touchScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.rankColor.withValues(alpha: 0.16)
                  : Colors.transparent,
              border: widget.isSelected
                  ? Border(
                      top: BorderSide(
                        color: widget.rankColor,
                        width: 2.4,
                      ),
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TacticalGlyph(
                  type: widget.glyphType,
                  color: widget.isSelected ? widget.activeColor : widget.inactiveColor,
                  size: 20,
                  glow: widget.isSelected,
                ),
                const SizedBox(height: 3),
                Text(
                  widget.label,
                  style: GoogleFonts.spaceMono(
                    color: widget.isSelected ? widget.activeColor : widget.inactiveColor,
                    fontSize: 9.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── TACTILE CENTER EMBLEM BUTTON ──────────────────────────────────────────────
class _CenterEmblemButton extends StatefulWidget {
  final Color rankColor;
  final Color lightRankColor;
  final VoidCallback onTap;

  const _CenterEmblemButton({
    required this.rankColor,
    required this.lightRankColor,
    required this.onTap,
  });

  @override
  State<_CenterEmblemButton> createState() => _CenterEmblemButtonState();
}

class _CenterEmblemButtonState extends State<_CenterEmblemButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _touchCtrl;
  late Animation<double> _touchScale;

  @override
  void initState() {
    super.initState();
    _touchCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _touchScale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _touchCtrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _touchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _touchCtrl.forward(),
      onTapUp: (_) {
        _touchCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _touchCtrl.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _touchScale,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.buildRankGradient(widget.rankColor),
            boxShadow: [
              BoxShadow(
                color: widget.rankColor.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: widget.lightRankColor.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.change_history_rounded,
              color: Colors.black,
              size: 26,
              weight: 800,
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/tactical_panel.dart';
import '../../widgets/tactical_hud_widgets.dart';
import '../../widgets/tactical_icons.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  const SettingsScreen({super.key, required this.onSignOut});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _localStorage = LocalStorageService();
  late TextEditingController _apiKeyCtrl;
  bool _apiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _apiKeyCtrl = TextEditingController();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await _localStorage.getGeminiApiKey();
    if (mounted) {
      setState(() {
        _apiKeyCtrl.text = key ?? '';
      });
    }
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final rankColor = userProvider.currentRankColor;
    final rankInfo = userProvider.currentRankInfo;
    final lightRankColor = AppColors.getLightVariant(rankColor);
    final completionsReq = rankInfo.completionsRequired;
    final userCompletions = user?.rankCompletions ?? 0;
    final ascProgress = completionsReq > 0 ? (userCompletions / completionsReq).clamp(0.0, 1.0) : 1.0;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.buildRankAmbientGradient(rankColor)),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              // ─── TITLE ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      color: rankColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SETTINGS // SYSTEM CONFIG',
                      style: GoogleFonts.spaceMono(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ─── PROFILE CARD (TACTICAL PANEL) ───────────────────────────────
              TacticalPanel(
                rankColor: rankColor,
                showHeader: true,
                tacticalTag: 'USER PROFILE',
                statusBadge: 'ACTIVE',
                chamferSize: 14.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Tactical Faceted Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF07090E),
                            border: Border.all(
                              color: rankColor.withValues(alpha: 0.50),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: TacticalGlyph(
                              type: TacticalGlyphType.soul,
                              color: lightRankColor,
                              size: 24,
                              glow: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name.toUpperCase(),
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: rankColor.withValues(alpha: 0.14),
                                  border: Border.all(
                                    color: rankColor.withValues(alpha: 0.45),
                                    width: 0.9,
                                  ),
                                ),
                                child: Text(
                                  '[ ${rankInfo.name.toUpperCase()} ]',
                                  style: GoogleFonts.spaceMono(
                                    color: lightRankColor,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TacticalSegmentedBar(
                      progress: ascProgress,
                      rankColor: rankColor,
                      label: 'RANK_EXP',
                      readoutText: '$userCompletions / $completionsReq DAYS',
                      totalSegments: 14,
                      height: 6.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── PANEL 1: AI CORE & CLOUD SYNC HUB ──────────────────────────
              TacticalPanel(
                rankColor: rankColor,
                showHeader: true,
                tacticalTag: 'AI & CLOUD BACKUP',
                statusBadge: user.cloudBackupEnabled ? 'SYNCED' : 'LOCAL',
                chamferSize: 14.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TacticalGlyph(type: TacticalGlyphType.memoryCore, color: rankColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'GEMINI AI API KEY',
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _apiKeyCtrl,
                      obscureText: !_apiKeyVisible,
                      style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'AIzaSy...',
                        hintStyle: const TextStyle(color: AppColors.darkDimText),
                        filled: true,
                        fillColor: const Color(0xFF07090E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                              color: rankColor.withValues(alpha: 0.6), width: 1.2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _apiKeyVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.darkSubText,
                            size: 18,
                          ),
                          onPressed: () =>
                              setState(() => _apiKeyVisible = !_apiKeyVisible),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveApiKey,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: rankColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            child: Text('SAVE KEY', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 10)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearApiKey,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF4655),
                              side: const BorderSide(color: Color(0xFFFF4655), width: 1),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero),
                            ),
                            child: Text('CLEAR', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                    const SizedBox(height: 12),

                    // Cloud Sync Row
                    _settingRowWithWidget(
                      'Cloud Sync (Firebase)',
                      Colors.white,
                      AppColors.darkSubText,
                      Switch(
                        value: user.cloudBackupEnabled,
                        activeThumbColor: rankColor,
                        onChanged: (v) =>
                            userProvider.toggleCloudBackup(v),
                      ),
                    ),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow(
                      'Export Data as JSON',
                      Icons.file_download_outlined,
                      Colors.white,
                      AppColors.darkSubText,
                      onTap: _exportData,
                    ),
                    if (!FirebaseService().isSignedIn) ...[
                      Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                      _settingRow(
                        'Sign in with Google',
                        Icons.login_rounded,
                        Colors.white,
                        AppColors.darkSubText,
                        onTap: _signInWithGoogle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── PANEL 2: APPEARANCE & SHIELDS HUB ──────────────────────────
              TacticalPanel(
                rankColor: rankColor,
                showHeader: true,
                tacticalTag: 'APPEARANCE & SHIELDS',
                statusBadge: 'ACTIVE',
                chamferSize: 14.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _settingRowWithWidget(
                      'Reduce Visual Effects',
                      Colors.white,
                      AppColors.darkSubText,
                      Switch(
                        value: context.watch<ThemeProvider>().reduceEffects,
                        activeThumbColor: rankColor,
                        onChanged: (v) => context.read<ThemeProvider>().setReduceEffects(v),
                      ),
                    ),
                    if (user.currentRank >= 15) ...[
                      Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                      _settingRow(
                        'Aura Color',
                        Icons.palette_outlined,
                        Colors.white,
                        AppColors.darkSubText,
                        trailing: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: userProvider.currentRankColor,
                          ),
                        ),
                        onTap: () => _showAuraPicker(context, userProvider),
                      ),
                    ],
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Streak Shields',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Protects your streak if you miss a day (3/mo)',
                                  style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 9.5)),
                            ],
                          ),
                          TacticalShieldsPod(
                            shieldsRemaining: user.shieldsRemaining,
                            rankColor: rankColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ─── PANEL 3: ABOUT & SECURITY ────────────────────────────
              TacticalPanel(
                rankColor: rankColor,
                showHeader: true,
                tacticalTag: 'ABOUT & SECURITY',
                statusBadge: 'SECURE',
                chamferSize: 14.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _settingRow('Aumbra v1.0.0', Icons.info_outline_rounded, Colors.white, AppColors.darkSubText),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Privacy Policy', Icons.security_rounded, Colors.white, AppColors.darkSubText, onTap: () {}),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Terms of Service', Icons.description_rounded, Colors.white, AppColors.darkSubText, onTap: () {}),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Sign Out', Icons.logout_rounded, Colors.white, AppColors.darkSubText,
                        onTap: _confirmSignOut),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Purge All Data', Icons.delete_sweep_rounded,
                        const Color(0xFFFF4655), AppColors.darkSubText,
                        onTap: _confirmDeleteAll,
                        textColor: const Color(0xFFFF4655)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
  }

  IconData _getRankAvatarIcon(int rank) {
    switch (rank) {
      case 1: return Icons.auto_awesome_rounded;
      case 2: return Icons.explore_rounded;
      case 3: return Icons.bolt_rounded;
      case 4: return Icons.local_fire_department_rounded;
      case 5: return Icons.north_east_rounded;
      case 6: return Icons.shield_rounded;
      case 7: return Icons.diamond_rounded;
      case 8: return Icons.menu_book_rounded;
      case 9: return Icons.wb_sunny_rounded;
      case 10: return Icons.all_inclusive_rounded;
      case 11: return Icons.hourglass_empty_rounded;
      case 12: return Icons.flare_rounded;
      case 13: return Icons.stars_rounded;
      case 14: return Icons.military_tech_rounded;
      case 15: return Icons.workspace_premium_rounded;
      default: return Icons.auto_awesome_rounded;
    }
  }

  Widget _sectionHeader(String label, Color subColor, Color rankColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
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
          Text(label,
              style: const TextStyle(
                  color: AppColors.darkSubText,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _settingsCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C0C0C), Color(0xFF050505)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _settingRowWithWidget(
      String label, Color textColor, Color subColor, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        trailing,
      ],
    );
  }

  Widget _settingRow(String label, IconData icon, Color labelColor, Color subColor,
      {VoidCallback? onTap, Color? textColor, Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor ?? const Color(0xFF76808F)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: textColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.darkSubText.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  // ─── ACTIONS ──────────────────────────────────────────────────────────────

  Future<void> _saveApiKey() async {
    await _localStorage.setGeminiApiKey(_apiKeyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Core Key Saved.')),
      );
    }
  }

  Future<void> _clearApiKey() async {
    await _localStorage.clearGeminiApiKey();
    _apiKeyCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Core Key Cleared.')),
      );
    }
  }

  Future<void> _exportData() async {
    try {
      final data = await context.read<UserProvider>().exportData();
      final json = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/aumbra_export.json');
      await file.writeAsString(json);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final firebase = FirebaseService();
    final user = await firebase.signInWithGoogle();
    if (user != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${user.email}')),
      );
    }
  }

  void _confirmSignOut() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF090B10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.accentRed.withValues(alpha: 0.6), width: 1.2),
        ),
        title: Row(
          children: [
            Container(width: 3, height: 16, color: AppColors.accentRed),
            const SizedBox(width: 8),
            Text(
              'TERMINATE SESSION',
              style: GoogleFonts.spaceMono(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        content: Text(
          'Agent session will disconnect. Local offline telemetry remains stored in memory core.',
          style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 11, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProvider>().signOut();
              widget.onSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text('SIGN OUT', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF090B10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFFFF4655), width: 1.4),
        ),
        title: Row(
          children: [
            Container(width: 3, height: 16, color: const Color(0xFFFF4655)),
            const SizedBox(width: 8),
            Text(
              'CRITICAL PURGE // SYSTEM WIPE',
              style: GoogleFonts.spaceMono(
                color: const Color(0xFFFF4655),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        content: Text(
          'WARNING: This protocol permanently wipes all combat records, telemetry, rank progress, and badges from local and cloud nodes. This action cannot be reversed.',
          style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 11, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('ABORT', style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProvider>().deleteAllData();
              widget.onSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4655),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text('PURGE EVERYTHING', style: GoogleFonts.spaceMono(fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showAuraPicker(BuildContext context, UserProvider userProvider) {
    final colors = [
      Colors.red, Colors.orange, Colors.yellow, Colors.green,
      Colors.teal, Colors.cyan, Colors.blue, Colors.indigo,
      Colors.purple, Colors.pink, Colors.white, Colors.grey,
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
        ),
        title: const Text('Choose Your Aura',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () {
                userProvider.setAuraColor(c);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/firebase_service.dart';
import '../../../core/constants/app_colors.dart';

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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              // ─── TITLE ──────────────────────────────────────────────────────
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
                    'SETTINGS',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── PANEL 1: AI CORE & CLOUD SYNC HUB ──────────────────────────
              _sectionHeader('AI & CLOUD', subColor, rankColor),
              _settingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.memory_rounded, color: rankColor, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'GEMINI AI API KEY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _apiKeyCtrl,
                      obscureText: !_apiKeyVisible,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'AIzaSy...',
                        hintStyle: const TextStyle(color: AppColors.darkDimText),
                        filled: true,
                        fillColor: const Color(0xFF090A10),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.08), width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('SAVE KEY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearApiKey,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF6B6B),
                              side: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('CLEAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                    const SizedBox(height: 14),

                    // Cloud Sync Row
                    _settingRowWithWidget(
                      'Cloud Sync (Firebase)',
                      textColor,
                      subColor,
                      Switch(
                        value: user.cloudBackupEnabled,
                        activeThumbColor: rankColor,
                        onChanged: (v) =>
                            userProvider.toggleCloudBackup(v),
                      ),
                    ),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow(
                      'Export Chronicle as JSON',
                      Icons.file_download_outlined,
                      textColor,
                      subColor,
                      onTap: _exportData,
                    ),
                    if (!FirebaseService().isSignedIn) ...[
                      Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                      _settingRow(
                        'Sign in with Google',
                        Icons.login_rounded,
                        textColor,
                        subColor,
                        onTap: _signInWithGoogle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ─── PANEL 2: APPEARANCE & SHIELDS HUB ──────────────────────────
              _sectionHeader('APPEARANCE & SHIELDS', subColor, rankColor),
              _settingsCard(
                child: Column(
                  children: [
                    _settingRowWithWidget(
                      'Reduce Visual Effects',
                      textColor,
                      subColor,
                      Switch(
                        value: themeProvider.reduceEffects,
                        activeThumbColor: rankColor,
                        onChanged: (v) => themeProvider.setReduceEffects(v),
                      ),
                    ),
                    if (user.currentRank >= 15) ...[
                      Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                      _settingRow(
                        'Aura Color',
                        Icons.palette_outlined,
                        textColor,
                        subColor,
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Integrity Shields',
                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                              SizedBox(height: 2),
                              Text('Prevents streak loss (3/mo)',
                                  style: TextStyle(color: AppColors.darkSubText, fontSize: 11)),
                            ],
                          ),
                          Row(
                            children: List.generate(3, (i) {
                              final available = i < user.shieldsRemaining;
                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  available ? Icons.shield_rounded : Icons.shield_outlined,
                                  color: available ? rankColor : AppColors.darkDimText.withValues(alpha: 0.3),
                                  size: 18,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ─── PANEL 3: DOSSIER & SECURITY HUB ────────────────────────────
              _sectionHeader('SECURITY & DATA', subColor, rankColor),
              _settingsCard(
                child: Column(
                  children: [
                    _settingRow('Aumbra Protocol v1.0.0', Icons.terminal_rounded, textColor, subColor),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Privacy Policy', Icons.security_rounded, textColor, subColor, onTap: () {}),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Terms of Service', Icons.description_rounded, textColor, subColor, onTap: () {}),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Sign Out', Icons.logout_rounded, textColor, subColor,
                        onTap: _confirmSignOut),
                    Divider(height: 16, color: Colors.white.withValues(alpha: 0.04)),
                    _settingRow('Purge All Data', Icons.delete_sweep_rounded,
                        const Color(0xFFFF6B6B), subColor,
                        onTap: _confirmDeleteAll,
                        textColor: const Color(0xFFFF6B6B)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
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
        color: AppColors.darkCard,
        gradient: AppColors.darkCardGradient,
        borderRadius: BorderRadius.circular(18),
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor ?? AppColors.goldPrimary),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
        ),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text('You will stay in offline mode. Your local data is safe.',
            style: TextStyle(color: AppColors.darkSubText, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.darkSubText))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProvider>().signOut();
              widget.onSignOut();
            },
            child: const Text('SIGN OUT',
                style: TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF6B6B), width: 1.2),
        ),
        title: const Text('Purge All Data',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text(
          'This will permanently delete all your progress, history, badges, and account. This action cannot be reversed.',
          style: TextStyle(color: AppColors.darkSubText, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.darkSubText))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProvider>().deleteAllData();
              widget.onSignOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('PURGE EVERYTHING', style: TextStyle(fontWeight: FontWeight.w900)),
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


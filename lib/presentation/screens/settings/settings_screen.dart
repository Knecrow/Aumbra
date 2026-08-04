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
// glass_card removed — settings uses native containers

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
    final sectionBg = isDark ? const Color(0xFF0A0C1A) : const Color(0xFFF1F5F9);
    final sectionBorder = isDark ? const Color(0xFF1E2036) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: isDark
            ? BoxDecoration(gradient: AppColors.darkBackgroundGradient)
            : null,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            children: [
              // Title
              Text('[ SYSTEM UTILITY: SETTINGS ]',
                  style: TextStyle(
                      color: rankColor,
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('SYSTEM PREFERENCES',
                  style: TextStyle(
                      color: textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 24),

              // ─── GEMINI API KEY ─────────────────────────────────────────────
            _sectionHeader('GEMINI API KEY', subColor),
            _settingsCard(
              isDark,
              sectionBg,
              sectionBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stored locally only. Never sent to any server.',
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _apiKeyCtrl,
                    obscureText: !_apiKeyVisible,
                    style: TextStyle(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'AIza...',
                      hintStyle: TextStyle(color: subColor),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06), width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06), width: 1.2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _apiKeyVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: subColor,
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
                        child: OutlinedButton(
                          onPressed: _saveApiKey,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: rankColor,
                            side: BorderSide(color: rankColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Save Key'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearApiKey,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B6B),
                            side: const BorderSide(color: Color(0xFFFF6B6B)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Clear Key'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── CLOUD BACKUP ───────────────────────────────────────────────
            _sectionHeader('CLOUD BACKUP', subColor),
            _settingsCard(
              isDark,
              sectionBg,
              sectionBorder,
              child: Column(
                children: [
                  _settingRowWithWidget(
                    'Cloud Backup (Firebase)',
                    textColor,
                    subColor,
                    Switch(
                      value: user.cloudBackupEnabled,
                      activeThumbColor: rankColor,
                      onChanged: (v) =>
                          userProvider.toggleCloudBackup(v),
                    ),
                  ),
                  const Divider(height: 20),
                  _settingRow(
                    'Export Chronicle as JSON',
                    '📤',
                    textColor,
                    subColor,
                    onTap: _exportData,
                  ),
                  if (!FirebaseService().isSignedIn) ...[
                    const Divider(height: 20),
                    _settingRow(
                      'Sign in with Google',
                      '🔐',
                      textColor,
                      subColor,
                      onTap: _signInWithGoogle,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── APPEARANCE ─────────────────────────────────────────────────
            _sectionHeader('APPEARANCE', subColor),
            _settingsCard(
              isDark,
              sectionBg,
              sectionBorder,
              child: Column(
                children: [
                  _settingRowWithWidget(
                    isDark ? 'Dark Mode' : 'White Mode',
                    textColor,
                    subColor,
                    Switch(
                      value: isDark,
                      activeThumbColor: rankColor,
                      onChanged: (v) => themeProvider.setDarkMode(v),
                    ),
                  ),
                  const Divider(height: 20),
                  _settingRowWithWidget(
                    'Reduce Effects',
                    textColor,
                    subColor,
                    Switch(
                      value: themeProvider.reduceEffects,
                      activeThumbColor: rankColor,
                      onChanged: (v) => themeProvider.setReduceEffects(v),
                    ),
                  ),
                  // Aura color picker (Absolute rank only)
                  if (user.currentRank >= 15) ...[
                    const Divider(height: 20),
                    _settingRow(
                      'Aura Color (Absolute)',
                      '🌈',
                      textColor,
                      subColor,
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: userProvider.currentRankColor,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      ),
                      onTap: () => _showAuraPicker(context, userProvider),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── SHIELDS ────────────────────────────────────────────────────
            _sectionHeader('SHIELDS', subColor),
            _settingsCard(
              isDark,
              sectionBg,
              sectionBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shields this month',
                          style: TextStyle(color: textColor, fontSize: 14)),
                      Row(
                        children: List.generate(3, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              i < user.shieldsRemaining ? '🛡️' : '⬜',
                              style: const TextStyle(fontSize: 20),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${user.shieldsRemaining} / 3 remaining · Resets on the 1st of each month',
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── ACCOUNT ────────────────────────────────────────────────────
            _sectionHeader('ACCOUNT', subColor),
            _settingsCard(
              isDark,
              sectionBg,
              sectionBorder,
              child: Column(
                children: [
                  _settingRow('Sign Out', '🚪', textColor, subColor,
                      onTap: _confirmSignOut),
                  const Divider(height: 20),
                  _settingRow('Delete All Data', '🗑️',
                      const Color(0xFFFF6B6B), subColor,
                      onTap: _confirmDeleteAll,
                      textColor: const Color(0xFFFF6B6B)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── ABOUT ──────────────────────────────────────────────────────
            _sectionHeader('ABOUT', subColor),
            _settingsCard(
              isDark,
              sectionBg,
              sectionBorder,
              child: Column(
                children: [
                  _settingRow('Aumbra v1.0.0', 'ℹ️', textColor, subColor),
                  const Divider(height: 20),
                  _settingRow('100% Free. No ads. No paywalls.', '❤️', textColor, subColor),
                  const Divider(height: 20),
                  _settingRow('Privacy Policy', '🔒', textColor, subColor,
                      onTap: () {}),
                  const Divider(height: 20),
                  _settingRow('Terms of Service', '📄', textColor, subColor,
                      onTap: () {}),
                  const Divider(height: 20),
                  _settingRow('Contact Support', '✉️', textColor, subColor,
                      onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _sectionHeader(String label, Color subColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('[ $label ]',
          style: TextStyle(
              color: subColor,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800)),
    );
  }

  Widget _settingsCard(bool isDark, Color bg, Color border,
      {required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border, width: 1.2),
      ),
      child: child,
    );
  }

  Widget _settingRowWithWidget(
      String label, Color textColor, Color subColor, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor, fontSize: 14)),
        trailing,
      ],
    );
  }

  Widget _settingRow(String label, String icon, Color labelColor, Color subColor,
      {VoidCallback? onTap, Color? textColor, Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: textColor ?? labelColor, fontSize: 14)),
          ),
          if (trailing != null) trailing,
          if (onTap != null && trailing == null)
            Icon(Icons.chevron_right,
                color: subColor.withValues(alpha: 0.5), size: 18),
        ],
      ),
    );
  }

  // ─── ACTIONS ──────────────────────────────────────────────────────────────

  Future<void> _saveApiKey() async {
    await _localStorage.setGeminiApiKey(_apiKeyCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved locally.')),
      );
    }
  }

  Future<void> _clearApiKey() async {
    await _localStorage.clearGeminiApiKey();
    _apiKeyCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key cleared.')),
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
        title: const Text('Sign Out'),
        content: const Text('You will stay in offline mode. Your local data is safe.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<UserProvider>().signOut();
              widget.onSignOut();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Delete All Data',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text(
          'This will permanently delete all your progress, history, badges, and account. This cannot be undone.',
          style: TextStyle(color: Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white))),
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
            child: const Text('DELETE EVERYTHING'),
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
        backgroundColor: const Color(0xFF111111),
        title: const Text('Choose Your Aura',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

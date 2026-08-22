import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/tactical_panel.dart';
import '../../widgets/tactical_particle_canvas.dart';

// ── Onboarding accent colour ─────────────────────────────────────────────────
const _kAccent = AppColors.goldPrimary; // Solar gold

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form data
  final _nameController = TextEditingController();
  final _careerController = TextEditingController();
  final _interestsController = TextEditingController();
  final _apiKeyController = TextEditingController();
  double _fitnessLevel = 5.0;
  String _dailyTime = '30';
  bool _hasComputer = true;

  final List<String> _dailyTimes = ['15', '30', '60', '120'];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _careerController.dispose();
    _interestsController.dispose();
    _apiKeyController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 7) {
      _fadeController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      _fadeController.forward();
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final userProvider = context.read<UserProvider>();
      final localStorage = LocalStorageService();

      if (_apiKeyController.text.isNotEmpty) {
        await localStorage.setGeminiApiKey(_apiKeyController.text.trim());
      }

      final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final user = UserModel(
        uid: uid,
        name: _nameController.text.trim().isEmpty ? 'NOVA' : _nameController.text.trim(),
        career: _careerController.text.trim().isEmpty ? 'Student' : _careerController.text.trim(),
        interests: _interestsController.text.trim().isEmpty ? 'Self-improvement' : _interestsController.text.trim(),
        fitnessLevel: _fitnessLevel.round(),
        dailyTime: _dailyTime,
        hasComputer: _hasComputer,
        startDate: DateTime.now(),
        shieldsLastReset: DateTime.now(),
      );

      await userProvider.saveUser(user);
      await localStorage.setOnboardingComplete(true);
      await localStorage.setCurrentUserId(uid);
    } catch (e) {
      debugPrint('Onboarding complete error: $e');
    } finally {
      if (mounted) widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06070B),
      body: TacticalParticleCanvas(
        rankColor: _kAccent,
        particleCount: 22,
        child: Stack(
          children: [
            // ── Pages ────────────────────────────────────────────────────────
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildWelcomePage(),
                _buildNamePage(),
                _buildCareerPage(),
                _buildInterestsPage(),
                _buildFitnessPage(),
                _buildDailyTimePage(),
                _buildComputerPage(),
                _buildApiKeyPage(),
              ],
            ),

            // ── Progress indicator ────────────────────────────────────────────
            if (_currentPage > 0)
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(8, (i) {
                    final isCurrent = i == _currentPage;
                    final isPassed = i < _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCurrent ? 24 : 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _kAccent
                            : (isPassed ? _kAccent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.10)),
                        boxShadow: isCurrent
                            ? [BoxShadow(color: _kAccent.withValues(alpha: 0.6), blurRadius: 8)]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Welcome page ────────────────────────────────────────────────────────────
  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Faceted Solar Crest Logo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Aura Glow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.35),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    // Outer Rotated Diamond Frame
                    Transform.rotate(
                      angle: 0.785398, // 45 deg
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E111A),
                          border: Border.all(
                            color: _kAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Inner Rotated Core
                    Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _kAccent.withValues(alpha: 0.18),
                          border: Border.all(
                            color: _kAccent.withValues(alpha: 0.7),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.bolt_rounded, color: Colors.white, size: 30),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Title
              Text(
                'AUMBRA',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'DISCIPLINE · POWER · ASCENSION',
                style: GoogleFonts.spaceMono(
                  color: AppColors.getLightVariant(_kAccent),
                  fontSize: 10.5,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 36),
              // Tactical initialization panel
              TacticalPanel(
                rankColor: _kAccent,
                showHeader: true,
                tacticalTag: 'INITIALIZATION PROTOCOL',
                statusBadge: 'STAGE 01',
                chamferSize: 14.0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'You\'ve been asleep long enough.\nIt\'s time to awaken.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                    const SizedBox(height: 12),
                    Text(
                      'No competition. No subscriptions.\nOnly unwavering self-discipline.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceMono(
                        color: AppColors.darkSubText,
                        fontSize: 11.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildNextButton('START YOUR JOURNEY'),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  // ── Input pages ─────────────────────────────────────────────────────────────
  Widget _buildNamePage() => _buildInputPage(
        icon: Icons.person_rounded,
        title: 'What should we\ncall you?',
        subtitle: 'Your name or callsign.',
        child: _glassTextField(
          controller: _nameController,
          hint: 'e.g. Alex, Sarah, Nova',
          icon: Icons.person_outline_rounded,
          capitalization: TextCapitalization.words,
        ),
      );

  Widget _buildCareerPage() => _buildInputPage(
        icon: Icons.work_rounded,
        title: 'What is\nyour path?',
        subtitle: 'Your craft, field, or main focus. Helps calibrate daily pillars.',
        child: _glassTextField(
          controller: _careerController,
          hint: 'e.g. Software Engineer, Medical Student, Designer',
          icon: Icons.work_outline_rounded,
          capitalization: TextCapitalization.words,
        ),
      );

  Widget _buildInterestsPage() => _buildInputPage(
        icon: Icons.auto_awesome_rounded,
        title: 'What fuels\nyour growth?',
        subtitle: 'Hobbies and focus areas — the more specific, the sharper your daily habits.',
        child: _glassTextField(
          controller: _interestsController,
          hint: 'e.g. Strength training, coding, reading, mindfulness',
          icon: Icons.favorite_outline_rounded,
          maxLines: 3,
          capitalization: TextCapitalization.sentences,
        ),
      );

  Widget _buildFitnessPage() => _buildInputPage(
        icon: Icons.fitness_center_rounded,
        title: 'Discipline &\nFitness Level',
        subtitle: 'Rate your baseline physical endurance and daily discipline.',
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BEGINNER',
                    style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 10, fontWeight: FontWeight.w700)),
                Text('ELITE DISCIPLINE',
                    style: GoogleFonts.spaceMono(color: _kAccent, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _kAccent,
                inactiveTrackColor: _kAccent.withValues(alpha: 0.15),
                thumbColor: _kAccent,
                overlayColor: _kAccent.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: Slider(
                value: _fitnessLevel,
                min: 1,
                max: 10,
                divisions: 9,
                label: _fitnessLevel.round().toString(),
                onChanged: (val) => setState(() => _fitnessLevel = val),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C0F17),
                  border: Border.all(color: _kAccent.withValues(alpha: 0.6), width: 1.0),
                ),
                child: Text(
                  '${_fitnessLevel.round()} / 10',
                  style: GoogleFonts.rajdhani(
                    color: _kAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDailyTimePage() {
    final labels = {'15': '15 MIN', '30': '30 MIN', '60': '1 HOUR', '120': '2+ HOURS'};
    final sublabels = {
      '15': 'Quick daily wins',
      '30': 'Balanced standard growth',
      '60': 'Serious focused grind',
      '120': 'Maximum daily focus',
    };
    return _buildInputPage(
      icon: Icons.schedule_rounded,
      title: 'Daily Habit\nTime Allocation',
      subtitle: 'Target time dedicated to daily pillars.',
      child: Column(
        children: _dailyTimes.map((time) {
          final isSelected = _dailyTime == time;
          return GestureDetector(
            onTap: () => setState(() => _dailyTime = time),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kAccent.withValues(alpha: 0.12)
                    : const Color(0xFF0C0F17),
                border: Border.all(
                  color: isSelected ? _kAccent : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 1.4 : 0.8,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels[time] ?? '',
                        style: GoogleFonts.rajdhani(
                          color: isSelected ? Colors.white : const Color(0xFFADB5BD),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sublabels[time] ?? '',
                        style: GoogleFonts.spaceMono(
                          color: isSelected ? _kAccent : AppColors.darkSubText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: _kAccent,
                      ),
                      child: const Icon(Icons.check, color: Colors.black, size: 14),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComputerPage() => _buildInputPage(
        icon: Icons.laptop_mac_rounded,
        title: 'Computer / PC\nAccess',
        subtitle: 'Ensures daily habits match your available tools.',
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _hasComputer = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _hasComputer
                            ? _kAccent.withValues(alpha: 0.12)
                            : const Color(0xFF0C0F17),
                        border: Border.all(
                          color: _hasComputer ? _kAccent : Colors.white.withValues(alpha: 0.08),
                          width: _hasComputer ? 1.4 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.laptop_mac_rounded,
                            size: 30,
                            color: _hasComputer ? _kAccent : AppColors.darkSubText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'YES',
                            style: GoogleFonts.spaceMono(
                              color: _hasComputer ? Colors.white : AppColors.darkSubText,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _hasComputer = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: !_hasComputer
                            ? _kAccent.withValues(alpha: 0.12)
                            : const Color(0xFF0C0F17),
                        border: Border.all(
                          color: !_hasComputer ? _kAccent : Colors.white.withValues(alpha: 0.08),
                          width: !_hasComputer ? 1.4 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.smartphone_rounded,
                            size: 30,
                            color: !_hasComputer ? _kAccent : AppColors.darkSubText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MOBILE ONLY',
                            style: GoogleFonts.spaceMono(
                              color: !_hasComputer ? Colors.white : AppColors.darkSubText,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildApiKeyPage() => _buildInputPage(
        icon: Icons.key_rounded,
        title: 'Gemini AI Key\n(Optional)',
        subtitle: 'Stored strictly on-device. Generates personalized tailored habits.',
        showNext: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0C0F17),
                border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1.0),
              ),
              child: TextField(
                controller: _apiKeyController,
                obscureText: true,
                style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: TextStyle(color: AppColors.darkDimText),
                  prefixIcon: Icon(Icons.key_outlined, color: _kAccent, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Link text
            RichText(
              text: TextSpan(
                style: GoogleFonts.spaceMono(color: AppColors.darkSubText, fontSize: 11),
                children: [
                  const TextSpan(text: 'Get your free API key at '),
                  TextSpan(
                    text: 'aistudio.google.com',
                    style: const TextStyle(
                      color: _kAccent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(Uri.parse('https://aistudio.google.com')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Skip note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF080A10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _kAccent, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can skip this and add your key anytime in Settings.',
                      style: GoogleFonts.spaceMono(
                        color: AppColors.darkSubText,
                        fontSize: 10.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Final ENTER AUMBRA button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(18),
                  elevation: 6,
                  shadowColor: _kAccent.withValues(alpha: 0.4),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  'ENTER AUMBRA',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  // ── Shared input page shell ──────────────────────────────────────────────────
  Widget _buildInputPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    bool showNext = true,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 76, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E111A),
                  border: Border.all(color: _kAccent, width: 1.2),
                ),
                child: Center(
                  child: Icon(icon, color: _kAccent, size: 20),
                ),
              ),
              const SizedBox(height: 18),
              // Title
              Text(
                title,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                subtitle,
                style: GoogleFonts.spaceMono(
                  color: AppColors.darkSubText,
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 14),
              if (showNext) _buildNextButton('CONTINUE'),
            ],
          ),
        ),
      ),
    );
  }

  // ── Glass text field ──────────────────────────────────────────────────────────
  Widget _glassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C0F17),
        border: Border.all(color: _kAccent.withValues(alpha: 0.5), width: 1.0),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLines: maxLines,
        textCapitalization: capitalization,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.spaceMono(color: AppColors.darkDimText, fontSize: 13),
          prefixIcon: Icon(icon, color: _kAccent, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Next / Continue button ────────────────────────────────────────────────────
  Widget _buildNextButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(16),
          elevation: 4,
          shadowColor: _kAccent.withValues(alpha: 0.3),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}


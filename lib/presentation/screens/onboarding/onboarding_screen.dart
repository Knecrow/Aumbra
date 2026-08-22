import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../core/constants/app_colors.dart';

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
      duration: const Duration(milliseconds: 500),
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
        duration: const Duration(milliseconds: 400),
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
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // ── Ambient background glow ──────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _AmbientPainter()),
          ),

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
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 20 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? _kAccent
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: i == _currentPage
                          ? [BoxShadow(color: _kAccent.withValues(alpha: 0.6), blurRadius: 8)]
                          : null,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ── Welcome page ────────────────────────────────────────────────────────────
  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow ring
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Golden solar halo
                    Transform.rotate(
                      angle: 3.14159 / 4,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: _kAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _kAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.bolt_rounded, color: AppColors.goldLight, size: 36),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Title
              ShaderMask(
                shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
                child: const Text(
                  'AUMBRA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'DISCIPLINE · POWER · ASCENSION',
                style: TextStyle(
                  color: AppColors.goldLight.withValues(alpha: 0.7),
                  fontSize: 12,
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 48),
              // Glass info card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  gradient: AppColors.darkCardGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'You\'ve been asleep long enough.\nIt\'s time to awaken.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        height: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.06)),
                    const SizedBox(height: 12),
                    const Text(
                      'No competition. No subscriptions.\nOnly unwavering self-discipline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.darkSubText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildNextButton('START YOUR JOURNEY'),
              const SizedBox(height: 40),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Beginner',
                    style: TextStyle(color: AppColors.darkSubText, fontSize: 12)),
                Text('Elite Discipline',
                    style: TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.goldPrimary,
                inactiveTrackColor: AppColors.goldPrimary.withValues(alpha: 0.15),
                thumbColor: AppColors.goldPrimary,
                overlayColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${_fitnessLevel.round()} / 10',
                  style: const TextStyle(
                    color: AppColors.goldLight,
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
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.goldPrimary.withValues(alpha: 0.14)
                    : AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.goldPrimary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels[time] ?? '',
                        style: TextStyle(
                          color: isSelected ? AppColors.goldLight : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sublabels[time] ?? '',
                        style: TextStyle(
                          color: isSelected ? AppColors.goldPrimary : AppColors.darkSubText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.goldPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.black, size: 14),
                    ),
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
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _hasComputer
                            ? AppColors.goldPrimary.withValues(alpha: 0.14)
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasComputer ? AppColors.goldPrimary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.laptop_mac_rounded,
                            size: 32,
                            color: _hasComputer ? AppColors.goldPrimary : AppColors.darkSubText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'YES',
                            style: TextStyle(
                              color: _hasComputer ? AppColors.goldLight : AppColors.darkSubText,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
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
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: !_hasComputer
                            ? AppColors.goldPrimary.withValues(alpha: 0.14)
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !_hasComputer ? AppColors.goldPrimary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.smartphone_rounded,
                            size: 32,
                            color: !_hasComputer ? AppColors.goldPrimary : AppColors.darkSubText,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MOBILE ONLY',
                            style: TextStyle(
                              color: !_hasComputer ? AppColors.goldLight : AppColors.darkSubText,
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
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _apiKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'AIzaSy...',
                  hintStyle: TextStyle(color: AppColors.darkDimText),
                  prefixIcon: Icon(Icons.key_outlined, color: AppColors.goldPrimary, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Link text
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.darkSubText, fontSize: 13),
                children: [
                  const TextSpan(text: 'Get your free API key at '),
                  TextSpan(
                    text: 'aistudio.google.com',
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.goldPrimary, size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can skip this and add your key anytime in Settings.',
                      style: TextStyle(
                        color: AppColors.darkSubText,
                        fontSize: 12,
                        height: 1.5,
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
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(18),
                  elevation: 8,
                  shadowColor: AppColors.goldPrimary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'ENTER AUMBRA',
                  style: TextStyle(
                    fontSize: 15,
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
          padding: const EdgeInsets.fromLTRB(28, 80, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.goldPrimary, size: 22),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.darkSubText,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: child,
                ),
              ),
              const SizedBox(height: 16),
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
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLines: maxLines,
        textCapitalization: capitalization,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.darkDimText, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.goldPrimary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          backgroundColor: AppColors.goldPrimary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(16),
          elevation: 6,
          shadowColor: AppColors.goldPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }
}

// ── Ambient background painter ──────────────────────────────────────────────────
class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deep obsidian dark fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.darkBackground,
    );

    // Top-center solar gold glow
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.55,
      Paint()
        ..color = AppColors.goldPrimary.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90),
    );

    // Bottom-center ambient amber glow
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.85),
      size.width * 0.45,
      Paint()
        ..color = AppColors.goldDark.withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/local_storage_service.dart';

// ── Onboarding accent colour ─────────────────────────────────────────────────
const _kAccent = Color(0xFF6C63FF); // electric indigo – no rank yet at this stage

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
        name: _nameController.text.trim().isEmpty ? 'Warrior' : _nameController.text.trim(),
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
      backgroundColor: const Color(0xFF070A14),
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
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? _kAccent
                          : _kAccent.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: i == _currentPage
                          ? [BoxShadow(color: _kAccent.withValues(alpha: 0.5), blurRadius: 8)]
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
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withValues(alpha: 0.35),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Diamond
                    Transform.rotate(
                      angle: 3.14159 / 4,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _kAccent.withValues(alpha: 0.12),
                          border: Border.all(
                            color: _kAccent.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00E5FF), size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF9B8FFF), Color(0xFF00E5FF)],
                ).createShader(bounds),
                child: const Text(
                  'AUMBRA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Awaken your destiny.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 15,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 52),
              // Glass info card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'You\'ve been asleep long enough.\nIt\'s time to awaken.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 18,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withValues(alpha: 0.08)),
                    const SizedBox(height: 12),
                    Text(
                      'No competition. No leaderboards.\nNo subscriptions. Just you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildNextButton('Begin Awakening'),
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
        title: 'What shall we\ncall you?',
        subtitle: 'Your name in the system. You can skip this.',
        child: _glassTextField(
          controller: _nameController,
          hint: 'Your name (optional)',
          icon: Icons.person_outline_rounded,
          capitalization: TextCapitalization.words,
        ),
      );

  Widget _buildCareerPage() => _buildInputPage(
        icon: Icons.work_rounded,
        title: 'What is\nyour path?',
        subtitle: 'Your career, study, or field. Helps craft relevant quests.',
        child: _glassTextField(
          controller: _careerController,
          hint: 'e.g. Software Engineer, Medical Student, Artist',
          icon: Icons.work_outline_rounded,
          capitalization: TextCapitalization.words,
        ),
      );

  Widget _buildInterestsPage() => _buildInputPage(
        icon: Icons.auto_awesome_rounded,
        title: 'What fuels\nyour soul?',
        subtitle: 'Hobbies and interests — the more detail, the better your quests.',
        child: _glassTextField(
          controller: _interestsController,
          hint: 'e.g. Guitar, running, anime, cooking, photography',
          icon: Icons.favorite_outline_rounded,
          maxLines: 3,
          capitalization: TextCapitalization.sentences,
        ),
      );

  Widget _buildFitnessPage() => _buildInputPage(
        icon: Icons.fitness_center_rounded,
        title: 'How is\nyour body?',
        subtitle: 'Rate your current fitness level to calibrate Body quests.',
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Couch potato',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                Text('Athletic beast',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFFFF6B6B),
                inactiveTrackColor: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                thumbColor: const Color(0xFFFF6B6B),
                overlayColor: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
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
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${_fitnessLevel.round()} / 10',
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDailyTimePage() {
    final labels = {'15': '15 min', '30': '30 min', '60': '1 hour', '120': '2+ hours'};
    final sublabels = {
      '15': 'Quick wins only',
      '30': 'Balanced growth',
      '60': 'Serious grind',
      '120': 'Full ascension mode',
    };
    return _buildInputPage(
      icon: Icons.schedule_rounded,
      title: 'How much time\ndo you have?',
      subtitle: 'Daily free time for self-improvement quests.',
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
                    ? _kAccent.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labels[time] ?? '',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                        ),
                      ),
                      Text(
                        sublabels[time] ?? '',
                        style: TextStyle(
                          color: isSelected ? _kAccent : Colors.white.withValues(alpha: 0.3),
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
                      decoration: BoxDecoration(
                        color: _kAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: _kAccent.withValues(alpha: 0.4), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
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
        title: 'Do you have\na computer?',
        subtitle: 'Ensures quests are physically accessible to you.',
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
                            ? const Color(0xFF10B981).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.laptop_mac_rounded,
                            size: 32,
                            color: _hasComputer ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yes',
                            style: TextStyle(
                              color: _hasComputer
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
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
                            ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.smartphone_rounded,
                            size: 32,
                            color: !_hasComputer ? const Color(0xFFFF6B6B) : Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No',
                            style: TextStyle(
                              color: !_hasComputer
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
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
        title: 'Your Gemini\nAPI Key',
        subtitle: 'Stored locally only. Powers personalized AI quests.',
        showNext: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key field
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _apiKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'AIza...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                  prefixIcon: Icon(Icons.key_outlined, color: _kAccent.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Link text
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                children: [
                  const TextSpan(text: 'Get your free API key at '),
                  TextSpan(
                    text: 'aistudio.google.com',
                    style: TextStyle(
                      color: _kAccent.withValues(alpha: 0.9),
                      decoration: TextDecoration.underline,
                      decorationColor: _kAccent,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(Uri.parse('https://aistudio.google.com')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Skip note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: _kAccent.withValues(alpha: 0.6), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can skip this and add your key later in Settings. Without a key, you\'ll get great generic quests.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Final AWAKEN button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(18),
                  elevation: 8,
                  shadowColor: _kAccent.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'AWAKEN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
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
                  color: _kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kAccent, size: 22),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
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
              if (showNext) _buildNextButton('Continue'),
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLines: maxLines,
        textCapitalization: capitalization,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
          prefixIcon: Icon(icon, color: _kAccent.withValues(alpha: 0.7), size: 20),
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
          backgroundColor: _kAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(18),
          elevation: 8,
          shadowColor: _kAccent.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
      ),
    );
  }
}

// ── Ambient background painter ──────────────────────────────────────────────────
class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deep space dark fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF070A14),
    );

    // Top-left indigo glow
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.1),
      size.width * 0.55,
      Paint()
        ..color = const Color(0xFF6C63FF).withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80),
    );

    // Bottom-right accent glow
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.85),
      size.width * 0.45,
      Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

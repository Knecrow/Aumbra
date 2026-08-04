import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/user_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/local_storage_service.dart';

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
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
    final userProvider = context.read<UserProvider>();
    final localStorage = LocalStorageService();

    // Save API key locally
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

    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0A0A), Colors.black],
              ),
            ),
          ),

          // Page content
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

          // Progress dots
          if (_currentPage > 0)
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(0),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Logo / title animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 3.14159 / 4,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const Text('👁️', style: TextStyle(fontSize: 36)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'AUMBRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Awaken your destiny.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 60),
            Text(
              'You\'ve been asleep long enough.\nIt\'s time to awaken.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 20,
                height: 1.6,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No competition. No leaderboards.\nNo subscriptions. Just you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const Spacer(),
            _buildNextButton('Begin Awakening'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return _buildInputPage(
      icon: '👤',
      title: 'What shall we call you?',
      subtitle: 'Your name in the system. You can skip this.',
      child: TextField(
        controller: _nameController,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Your name (optional)',
          prefixIcon: Icon(Icons.person_outline, color: Color(0xFF9E9E9E)),
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  Widget _buildCareerPage() {
    return _buildInputPage(
      icon: '💼',
      title: 'What is your path?',
      subtitle: 'Your career, study, or field. This helps craft relevant quests.',
      child: TextField(
        controller: _careerController,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'e.g. Software Engineer, Medical Student, Artist',
          prefixIcon: Icon(Icons.work_outline, color: Color(0xFF9E9E9E)),
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  Widget _buildInterestsPage() {
    return _buildInputPage(
      icon: '🎯',
      title: 'What fuels your soul?',
      subtitle: 'Your hobbies and interests. Be specific — the more detail, the better your quests.',
      child: TextField(
        controller: _interestsController,
        autofocus: true,
        maxLines: 3,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'e.g. Guitar, running, anime, cooking, photography',
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.favorite_outline, color: Color(0xFF9E9E9E)),
          ),
          alignLabelWithHint: true,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildFitnessPage() {
    return _buildInputPage(
      icon: '💪',
      title: 'How is your body?',
      subtitle: 'Rate your current fitness level. This calibrates your Body quests.',
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Couch potato',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
              Text('Athletic beast',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _fitnessLevel,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: const Color(0xFFFF6B6B),
            inactiveColor: Colors.white.withValues(alpha: 0.15),
            label: _fitnessLevel.round().toString(),
            onChanged: (val) => setState(() => _fitnessLevel = val),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.3)),
              ),
              child: Text(
                '${_fitnessLevel.round()} / 10',
                style: const TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTimePage() {
    return _buildInputPage(
      icon: '⏰',
      title: 'How much time do you have?',
      subtitle: 'Daily free time for self-improvement tasks.',
      child: Column(
        children: _dailyTimes.map((time) {
          final labels = {'15': '15 min', '30': '30 min', '60': '1 hour', '120': '2+ hours'};
          final isSelected = _dailyTime == time;
          return GestureDetector(
            onTap: () => setState(() => _dailyTime = time),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Text(labels[time] ?? '',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      )),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Color(0xFF9E9E9E), size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComputerPage() {
    return _buildInputPage(
      icon: '💻',
      title: 'Do you have a computer?',
      subtitle: 'This ensures quests are physically accessible to you.',
      child: Column(
        children: [
          const SizedBox(height: 20),
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
                          ? const Color(0xFF26de81).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _hasComputer
                            ? const Color(0xFF26de81).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('💻', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text('Yes',
                            style: TextStyle(
                              color: _hasComputer
                                  ? const Color(0xFF26de81)
                                  : Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
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
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: !_hasComputer
                            ? const Color(0xFFFF6B6B).withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('📵', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text('No',
                            style: TextStyle(
                              color: !_hasComputer
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.white.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
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
  }

  Widget _buildApiKeyPage() {
    return _buildInputPage(
      icon: '🔑',
      title: 'Your Gemini API Key',
      subtitle: 'Stored locally on your device only. Never sent to any server. Powers your personalized daily quests.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'AIza...',
              prefixIcon: Icon(Icons.key_outlined, color: Color(0xFF9E9E9E)),
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
              children: [
                const TextSpan(text: 'Get your free API key at '),
                TextSpan(
                  text: 'aistudio.google.com',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => launchUrl(Uri.parse('https://aistudio.google.com')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'You can skip this and add your key later in Settings. Without a key, you\'ll get great generic quests.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E9E9E),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
      showNext: false,
    );
  }

  Widget _buildInputPage({
    required String icon,
    required String title,
    required String subtitle,
    required Widget child,
    bool showNext = true,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: child,
              ),
            ),
            const SizedBox(height: 16),
            if (showNext) _buildNextButton('Continue'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9E9E9E),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

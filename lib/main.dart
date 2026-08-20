import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/services/database_service.dart';
import 'data/services/gemini_service.dart';
import 'data/services/firebase_service.dart';
import 'data/services/local_storage_service.dart';
import 'providers/user_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/navigation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge immersive dark UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Try to initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase config missing — app continues in offline-only mode
    debugPrint('Firebase not configured. Running in offline mode.');
  }

  runApp(const AumbraApp());
}

class AumbraApp extends StatelessWidget {
  const AumbraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create service singletons
    final dbService = DatabaseService();
    final geminiService = GeminiService();
    final firebaseService = FirebaseService();
    final localStorageService = LocalStorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(localStorage: localStorageService)
            ..loadThemePreference(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(
            db: dbService,
            firebase: firebaseService,
            localStorage: localStorageService,
          )..loadUser(),
        ),
        ChangeNotifierProxyProvider<UserProvider, QuestProvider>(
          create: (ctx) => QuestProvider(
            db: dbService,
            gemini: geminiService,
            localStorage: localStorageService,
            userProvider: ctx.read<UserProvider>(),
          ),
          update: (ctx, userProvider, previous) =>
              previous ??
              QuestProvider(
                db: dbService,
                gemini: geminiService,
                localStorage: localStorageService,
                userProvider: userProvider,
              ),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final rankColor = userProvider.currentRankColor;

    return MaterialApp(
      title: 'Aumbra',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(rankColor),
      darkTheme: buildDarkTheme(rankColor),
      themeMode: ThemeMode.dark,
      home: const _AppEntryPoint(),
    );
  }
}

class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint();

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
  bool _onboardingComplete = false;
  bool _checkingOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final localStorage = LocalStorageService();
    final complete = await localStorage.isOnboardingComplete();
    if (mounted) {
      setState(() {
        _onboardingComplete = complete;
        _checkingOnboarding = false;
      });
    }
  }

  void _onOnboardingComplete() {
    setState(() => _onboardingComplete = true);
  }

  void _onSignOut() {
    setState(() => _onboardingComplete = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingOnboarding) {
      return const _SplashScreen();
    }

    if (!_onboardingComplete) {
      return OnboardingScreen(onComplete: _onOnboardingComplete);
    }

    return MainNavigation(onSignOut: _onSignOut);
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFF5A623);
    return Scaffold(
      backgroundColor: const Color(0xFF08090C),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo mark
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.30),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: GoogleFonts.inter(
                        color: accentColor,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'AUMBRA',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 7,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AWAKENING',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.30),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
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

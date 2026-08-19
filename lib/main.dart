import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (ctx, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF00E5FF), size: 36),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'AUMBRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Awakening...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

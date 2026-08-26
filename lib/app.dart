import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/course_provider.dart';
import 'providers/quiz_provider.dart';
import 'services/ad_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/badges_screen.dart';

class GstCbtApp extends StatefulWidget {
  const GstCbtApp({super.key});

  @override
  State<GstCbtApp> createState() => _GstCbtAppState();
}

class _GstCbtAppState extends State<GstCbtApp> with WidgetsBindingObserver {
  Timer? _themeTimer;

  /// Light theme during daytime (06:00–17:59) and dark theme at night,
  /// based on the device's local time zone.
  bool _isDarkByLocalTime() {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _themeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdService.instance.onAppResume();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, _, __) {
          final isDarkMode = _isDarkByLocalTime();
          AppColors.isDark = isDarkMode;
          return MaterialApp(
            title: 'CBT',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) => AppThemeScope(
              isDark: isDarkMode,
              child: child ?? const SizedBox.shrink(),
            ),
            initialRoute: AppRoutes.splash,
            routes: {
              AppRoutes.splash: (context) => const SplashScreen(),
              AppRoutes.onboarding: (context) => const OnboardingScreen(),
              AppRoutes.home: (context) => const HomeScreen(),
              AppRoutes.practice: (context) => const PracticeScreen(),
              AppRoutes.exam: (context) => const ExamScreen(),
              AppRoutes.leaderboard: (context) => const LeaderboardScreen(),
              AppRoutes.invite: (context) => const InviteScreen(),
              AppRoutes.settings: (context) => const SettingsScreen(),
              AppRoutes.about: (context) => const AboutScreen(),
              AppRoutes.shop: (context) => const ShopScreen(),
              AppRoutes.badges: (context) => const BadgesScreen(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            ),
          );
        },
      ),
    );
  }
}
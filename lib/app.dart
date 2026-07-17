import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/course_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/practice_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/materials_screen.dart';
import 'screens/invite_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

class GstCbtApp extends StatelessWidget {
  const GstCbtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'GST CBT Prep',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.practice: (context) => const PracticeScreen(),
          AppRoutes.exam: (context) => const ExamScreen(),
          AppRoutes.leaderboard: (context) => const LeaderboardScreen(),
          AppRoutes.materials: (context) => const MaterialsScreen(),
          AppRoutes.invite: (context) => const InviteScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
          AppRoutes.about: (context) => const AboutScreen(),
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/profile_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // Show splash for 2.5 seconds, but allow skip after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _canSkip = true;
        });
      }
    });

    _timer = Timer(const Duration(milliseconds: 2500), _navigateToNext);
  }

  void _navigateToNext() {
    if (!mounted) return;
    
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.loadProfile().then((_) {
      if (profileProvider.hasProfile) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.modeSelection);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  void _skip() {
    _timer?.cancel();
    _navigateToNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Logo & Lottie
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Emblem
                  Container(
                    width: 90.0,
                    height: 90.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'GST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    'GST CBT Prep',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Practice offline. Pass once.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48.0),
                  
                  // Animated loading indicator
                  SizedBox(
                    height: 80.0,
                    child: Center(
                      child: SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Skippable indicator
            if (_canSkip)
              Positioned(
                bottom: 24.0,
                right: 24.0,
                child: TextButton(
                  onPressed: _skip,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 16.0,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

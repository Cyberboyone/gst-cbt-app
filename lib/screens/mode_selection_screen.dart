import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'home_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Choose Your Path',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Select the exam category you want to practice.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              _ModeCard(
                title: 'JAMB',
                subtitle: 'Joint Admissions and Matriculation Board',
                icon: '🎓',
                color: const Color(0xFFDCEEFF), // Sky
                onTap: () => _navigateToHome(context, 'jamb'),
              ),
              const SizedBox(height: 20),
              _ModeCard(
                title: 'WAEC',
                subtitle: 'West African Examinations Council',
                icon: '🌍',
                color: const Color(0xFFDFF5E4), // Mint
                onTap: () => _navigateToHome(context, 'waec'),
              ),
              const SizedBox(height: 20),
              _ModeCard(
                title: '100 Level',
                subtitle: 'University First Year Courses',
                icon: '🏛️',
                color: const Color(0xFFFFE8D6), // Peach
                onTap: () => _navigateToHome(context, '100_level'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context, String mode) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(selectedMode: mode)),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.textPrimary),
          ],
        ),
      ),
    );
  }
}

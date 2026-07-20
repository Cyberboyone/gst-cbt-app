import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/powered_by_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About GST CBT', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          children: [
            const SizedBox(height: 12.0),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.orange,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'GST',
                      style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, color: AppColors.navy),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(fontSize: 13.0, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            
            const Text(
              'App Purpose',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'GST CBT Prep is a specialized computer-based test training platform crafted for Nigerian university undergraduates studying General Studies (GST) courses. It provides complete offline support for taking exam simulations, reading lecture summaries, and analyzing performance metrics over time.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13.0, height: 1.45),
            ),
            const SizedBox(height: 24.0),

            const Text(
              'Key Features',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            _buildFeatureBullet('Offline Practice Mode', 'Review questions with instant answer explanations.'),
            _buildFeatureBullet('Mock Exam Timer', 'Match real CBT exam duration to build speed and accuracy.'),
            _buildFeatureBullet('Gamification Engine', 'Earn coins, accumulate XP, and achieve streak milestones.'),
            _buildFeatureBullet('Study Notes Manager', 'Download lecture summaries for off-grid reading.'),
            const SizedBox(height: 24.0),

            const Text(
              'About Siyayya',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Siyayya.com is a digital education and resources network. Our objective is to make tertiary education tools accessible, reliable, and affordable for all students.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13.0, height: 1.45),
            ),
            const SizedBox(height: 24.0),

            const Text(
              'Support & Feedback',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Encountered a bug or have questions/suggestions? Please reach out to us:',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13.0, height: 1.4),
            ),
            const SizedBox(height: 8.0),
            Text(
              AppConstants.contactEmail,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 14.0),
            ),
            
            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 16.0)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Segoe UI', fontSize: 13.0, color: AppColors.inkSoft),
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

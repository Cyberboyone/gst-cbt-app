import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:audioplayers/audioplayers.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/profile_provider.dart';
import '../providers/course_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/progress_ring.dart';
import '../widgets/powered_by_footer.dart';

class PracticeResultScreen extends StatefulWidget {
  final int totalQuestions;
  final int correctAnswers;
  final String courseCode;
  final String courseId;
  final int bestCombo;
  final int xpEarned;
  final int coinsEarned;
  final double multiplier;

  const PracticeResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.courseCode,
    required this.courseId,
    required this.bestCombo,
    required this.xpEarned,
    required this.coinsEarned,
    required this.multiplier,
  });

  @override
  State<PracticeResultScreen> createState() => _PracticeResultScreenState();
}

class _PracticeResultScreenState extends State<PracticeResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _animController.forward();
    _playCompletionSound();
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playCompletionSound() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (!settings.settings.soundOn) return;
    final score = _scorePercentage;
    if (score >= 80) {
      await _audioPlayer.play(AssetSource('sounds/applause.wav'));
    } else if (score >= 45) {
      await _audioPlayer.play(AssetSource('sounds/correct.wav'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/fail.wav'));
    }
  }

  int get _scorePercentage => widget.totalQuestions == 0
      ? 0
      : ((widget.correctAnswers / widget.totalQuestions) * 100).round();

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _shareResults(String nickname) {
    final msg = 'Hey! I just completed a ${widget.courseCode} Practice Session on the CBT App.\n'
        'Score: $_scorePercentage% (${widget.correctAnswers}/${widget.totalQuestions} correct)\n'
        'Best Combo: ${widget.bestCombo}x 🔥\n'
        'XP Earned: +${widget.xpEarned} | Coins: +${widget.coinsEarned}\n'
        'Download the app to test your prep!';
    Share.share(msg);
  }

  Future<void> _printResult(String nickname) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.nunitoRegular(),
      bold: await PdfGoogleFonts.nunitoBold(),
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CBT App - Practice Result', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20, color: PdfColors.indigo700)),
                    pw.SizedBox(height: 4),
                    pw.Text('Powered by Siyayya.com', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(dateStr, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                    pw.Text(timeStr, style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(color: PdfColors.indigo200),
            pw.SizedBox(height: 12),

            // Student info
            pw.Container(
              padding: pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Student', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(nickname, style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Course', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(widget.courseCode, style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Session Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text('Practice', style: pw.TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Score
            pw.Center(
              child: pw.Container(
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.indigo50,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('$_scorePercentage%', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 48, color: PdfColors.indigo700)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _scorePercentage >= 80 ? 'Excellent!' : (_scorePercentage >= 60 ? 'Good Job!' : (_scorePercentage >= 45 ? 'Passed' : 'Keep Practicing')),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.indigo700),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary Table
            pw.Text('Session Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.indigo700)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
              cellStyle: pw.TextStyle(fontSize: 11),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
              },
              headerAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
              },
              data: [
                ['Metric', 'Value'],
                ['Course', widget.courseCode],
                ['Questions Attempted', '${widget.totalQuestions}'],
                ['Correct Answers', '${widget.correctAnswers}'],
                ['Score', '$_scorePercentage%'],
                ['Best Combo', '${widget.bestCombo}x'],
                ['XP Earned', '+${widget.xpEarned}'],
                ['Coins Earned', '+${widget.coinsEarned}'],
                if (widget.multiplier > 1.0)
                  ['Multiplier', 'x${widget.multiplier.toStringAsFixed(1)}'],
              ],
            ),
            pw.SizedBox(height: 20),

            // Footer
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Generated by CBT App - ${dateStr} ${timeStr}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'CBT_Practice_${widget.courseCode}_$dateStr',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final nickname = profile?.nickname ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Result', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          children: [
            const SizedBox(height: 12.0),

            // Animated Score ring
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ProgressRing(
                  percentage: _scorePercentage / 100.0,
                  size: 130.0,
                  strokeWidth: 12.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_scorePercentage%',
                        style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                      Text(
                        'CORRECT',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          color: _scorePercentage >= 80 ? AppColors.accent : (_scorePercentage >= 45 ? Colors.green : Colors.orange),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),

            // Score description banner
            Container(
              decoration: BoxDecoration(
                color: _scorePercentage >= 80 ? AppColors.lavender : (_scorePercentage >= 45 ? AppColors.mint : AppColors.peach),
                borderRadius: BorderRadius.circular(16.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(_scorePercentage >= 80 ? '💯' : (_scorePercentage >= 45 ? '🏆' : '📚'), style: const TextStyle(fontSize: 24.0)),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _scorePercentage >= 80 ? 'Excellent Work!' : (_scorePercentage >= 45 ? 'Good Progress!' : 'Keep Practicing!'),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          _scorePercentage >= 80
                              ? 'Outstanding performance! You nailed most of the questions.'
                              : (_scorePercentage >= 45 ? 'Nice work! Review the ones you missed.' : 'Practice makes perfect. Try again to improve!'),
                          style: const TextStyle(fontSize: 12.0, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Session Summary
            const Text('Session Summary', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: AppColors.clayShadow,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  _buildStatRow('Course', widget.courseCode),
                  const Divider(height: 1),
                  _buildStatRow('Questions Attempted', '${widget.totalQuestions}'),
                  const Divider(height: 1),
                  _buildStatRow('Correct Answers', '${widget.correctAnswers}'),
                  const Divider(height: 1),
                  if (widget.bestCombo >= 3) ...[
                    _buildStatRow('Best Combo', '${widget.bestCombo}x 🔥'),
                    const Divider(height: 1),
                  ],
                  if (widget.multiplier > 1.0) ...[
                    _buildStatRow('Multiplier', 'x${widget.multiplier.toStringAsFixed(1)}'),
                    const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Rewards
            const Text('Rewards Earned', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(14.0)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('XP Earned', style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('+$widget.xpEarned XP', style: const TextStyle(color: AppColors.primary, fontSize: 18.0, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.sky, borderRadius: BorderRadius.circular(14.0)),
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Coins Reward', style: TextStyle(color: AppColors.inkSoft, fontSize: 11.0, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4.0),
                        Text('+${widget.coinsEarned} 🪙', style: const TextStyle(color: AppColors.primary, fontSize: 18.0, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36.0),

            // Print button (full width)
            SizedBox(
              width: double.infinity,
              height: 50.0,
              child: OutlinedButton.icon(
                onPressed: () => _printResult(nickname),
                icon: const Icon(Icons.print_rounded, color: AppColors.primary, size: 18),
                label: const Text('Print Result', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Share + Home
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareResults(nickname),
                      icon: const Icon(Icons.share_rounded, color: AppColors.accent, size: 18),
                      label: const Text('Share', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        elevation: 0,
                      ),
                      child: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),

            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 13.5, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 13.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// PDF export stubbed — pdf/printing packages removed pending proper setup
// To re-enable: add pdf, printing, flutter_pdfview back to pubspec.yaml

import 'package:flutter/material.dart';

Future<void> exportResultToPdf({
  required BuildContext context,
  required String courseCode,
  required int scorePercentage,
  required int correctAnswers,
  required int totalQuestions,
}) async {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('PDF export coming soon!'),
      duration: Duration(seconds: 2),
    ),
  );
}

// PDF export stubbed — pdf/printing packages removed pending proper setup
// To re-enable: add pdf, printing, flutter_pdfview back to pubspec.yaml

import 'package:flutter/material.dart';

class PdfExportHelper {
  static Future<void> exportResultPdf({
    required String courseCode,
    required int scorePercentage,
    required int correctAnswers,
    required int totalQuestions,
    required int timeSpentSeconds,
    required String studentName,
  }) async {
    debugPrint('PDF export coming soon for $courseCode!');
  }
}
